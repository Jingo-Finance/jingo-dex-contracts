
// File: contracts/lib/openzeppelin-contracts-4.0.0/contracts/token/ERC20/IERC20.sol



pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/CMswap/Staking/StakingLibrary.sol


pragma solidity ^0.8.19;

interface IPermissionCreated {
    function isAllowed(address userAddress) external view returns (bool);
}

library StakingLibrary {
        
    struct Position {
        uint96 nonce;
        address operator;
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
        uint256 feeGrowthInside0LastX128;
        uint256 feeGrowthInside1LastX128;
        uint128 tokensOwed0;
        uint128 tokensOwed1;
    }

    struct CreateProjectParams {
        string name;
        address stakingOrPMToken; // or positionManager for V3
        address rewardToken;
        address tokenA;
        address tokenB;
        uint24[] poolFees;
        uint256 totalRewards;
        uint8 mode;
        uint256[] lockDurations;
        uint256[] powerMultipliers;
        address projectOwner;
        uint256 startBlockReward;
        uint256 endBlockReward;
        uint256 userLockMaximum;
        uint256 poolLockMaximum;
    }

    struct PoolData {
        string name;
        address rewardToken;
        address positionManagerOrStaking;
        address token0;
        address token1;
        uint24[] fees;
        uint128 rewardPerBlock;
        uint128 totalPower;
        uint256 currentBlock;
        uint256 startBlock;
        uint256 endBlock;
    }

    function updatePool(
        uint128 rewardPerBlock,
        uint256 accRewardPerShare,
        uint256 lastRewardBlock,
        uint128 totalPower,
        uint256 startBlock,
        uint256 endBlock
    ) internal {
        uint256 currentBlock = block.number;
        if (currentBlock <= lastRewardBlock || currentBlock < startBlock) return;

        if (totalPower == 0) {
            lastRewardBlock = currentBlock;
            return;
        }

        uint256 finalBlock = endBlock == 0 ? currentBlock : (currentBlock > endBlock ? endBlock : currentBlock);
        if (finalBlock <= lastRewardBlock) return;

        uint256 blocksElapsed = finalBlock - lastRewardBlock;
        uint256 rewards = blocksElapsed * rewardPerBlock;
        accRewardPerShare += rewards * 1e12 / totalPower;
        lastRewardBlock = finalBlock;
    }


}
// File: contracts/CMswap/Staking/StakingProjectV2.sol


pragma solidity ^0.8.19;



contract StakingProjectV2 {
    struct StakeInfo {
        uint256 amountStaked;
        uint256 rewardDebt;
        uint256 stakeTimestamp;
        uint256 lockOption;
    }

    struct StakeInfoView {
        uint256 amountStaked;
        uint256 pendingReward;
        uint256 power;
        uint256 stakeTimestamp;
        uint256 lockOption;
    }

    struct CreateProjectParams {
        string name;
        address stakingOrPMToken;
        address rewardToken;
        uint128 rewardPerBlock;
        uint8 mode;
        uint256[] lockDurations;
        uint256[] powerMultipliers;
        address projectOwner;
        uint256 startBlockReward;
        uint256 endBlockReward;
        uint256 userLockMaximum;
        uint256 poolLockMaximum;
    }

    string public name;
    IERC20 public stakingToken;
    IERC20 public rewardToken;
    uint128 public rewardPerBlock;
    uint8 public mode; // 0: no lock, 1: fixed lock, 2: multiple lock options
    uint256 public accRewardPerShare;
    uint256 public lastRewardBlock;
    uint256 public totalStakedToken;
    uint128 public totalPower;
    uint256 public startBlock;
    uint256 public endBlock;
    uint256 public userLockMaximum;
    uint256 public poolLockMaximum;
    address public owner;
    bool public isPause;

    uint256[] public lockDurations; // seconds
    uint256[] public powerMultipliers; // percentage (e.g., 120 = 1.2x)
    mapping(address => StakeInfo[]) public userStakes;

    event UserAction(address indexed user, string action, uint256 value);

    error NotOwner();
    error Paused();
    error InvalidAmount();
    error StakeLimitReached();
    error InvalidIndex();
    error NoStake();
    error StillLocked();
    error ProgramRunning();
    error LowAllowance();
    error TransferFailed();
    error InvalidBlockRange();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier notPaused() {
        if (isPause) revert Paused();
        _;
    }

    constructor(CreateProjectParams memory params) {
        name = params.name;
        stakingToken = IERC20(params.stakingOrPMToken);
        rewardToken = IERC20(params.rewardToken);
        rewardPerBlock = params.rewardPerBlock;
        mode = params.mode;
        owner = params.projectOwner;
        lockDurations = params.lockDurations;
        powerMultipliers = params.powerMultipliers;
        startBlock = params.startBlockReward;
        endBlock = params.endBlockReward;
        lastRewardBlock = params.startBlockReward;
        userLockMaximum = params.userLockMaximum;
        poolLockMaximum = params.poolLockMaximum;
    }

    function cancel() external onlyOwner notPaused {
        if (block.timestamp > startBlock) revert ProgramRunning();
        uint256 balance = rewardToken.balanceOf(address(this));
        if (balance == 0) return;
        rewardPerBlock = 0;
        isPause = true;
        if (!rewardToken.transfer(msg.sender, balance)) revert TransferFailed();
        emit UserAction(msg.sender, "Cancel", balance);
    }

    function extendProgram(
        uint256 totalReward,
        uint256 newStartBlock,
        uint256 newEndBlock,
        uint256 _userLockMaximum,
        uint256 _poolLockMaximum
    ) external onlyOwner {
        if (newEndBlock <= endBlock || newEndBlock <= newStartBlock) revert InvalidBlockRange();
        if (block.number <= endBlock) revert ProgramRunning();
        StakingLibrary.updatePool(rewardPerBlock, accRewardPerShare, lastRewardBlock, totalPower, startBlock, endBlock);
        rewardPerBlock = uint128(totalReward / (newEndBlock - newStartBlock));
        startBlock = newStartBlock;
        endBlock = newEndBlock;
        if (rewardToken.allowance(msg.sender, address(this)) < totalReward) revert LowAllowance();
        if (!rewardToken.transferFrom(msg.sender, address(this), totalReward)) revert TransferFailed();
        userLockMaximum = _userLockMaximum;
        poolLockMaximum = _poolLockMaximum;
    }

    function stake(uint256 amount, uint256 option) external notPaused {
        if (amount == 0) revert InvalidAmount();

        uint256 allowed = amount;
        if (userLockMaximum > 0) {
            uint256 userTotal = _getUserTotalStaked(msg.sender);
            allowed = userLockMaximum > userTotal ? userLockMaximum - userTotal : 0;
        }
        if (poolLockMaximum > 0) {
            uint256 maxPool = poolLockMaximum > totalStakedToken ? poolLockMaximum - totalStakedToken : 0;
            allowed = allowed > maxPool ? maxPool : allowed;
        }
        if (allowed == 0) revert StakeLimitReached();

        StakingLibrary.updatePool(rewardPerBlock, accRewardPerShare, lastRewardBlock, totalPower, startBlock, endBlock);

        if (!stakingToken.transferFrom(msg.sender, address(this), allowed)) revert TransferFailed();

        uint256 power = _calculatePower(allowed, option);
        userStakes[msg.sender].push(StakeInfo({
            amountStaked: allowed,
            rewardDebt: (power * accRewardPerShare) / 1e12,
            stakeTimestamp: block.timestamp,
            lockOption: option
        }));

        totalStakedToken += allowed;
        totalPower += uint128(power);
    }

    function withdraw(uint256 index) external {
        if (index >= userStakes[msg.sender].length) revert InvalidIndex();
        StakeInfo storage user = userStakes[msg.sender][index];
        if (user.amountStaked == 0) revert NoStake();

        if (mode != 0) {
            if (block.timestamp < user.stakeTimestamp + lockDurations[user.lockOption]) revert StillLocked();
        }

        StakingLibrary.updatePool(rewardPerBlock, accRewardPerShare, lastRewardBlock, totalPower, startBlock, endBlock);

        uint256 power = _calculatePower(user.amountStaked, user.lockOption);
        uint256 pending = (power * accRewardPerShare) / 1e12 - user.rewardDebt;
        if (pending > 0) {
            if (!rewardToken.transfer(msg.sender, pending)) revert TransferFailed();
            emit UserAction(msg.sender, "Harvest", pending);
        }

        totalStakedToken -= user.amountStaked;
        totalPower -= uint128(power);

        if (!stakingToken.transfer(msg.sender, user.amountStaked)) revert TransferFailed();
        delete userStakes[msg.sender][index];
    }

    function updatePool() public {
        StakingLibrary.updatePool(rewardPerBlock, accRewardPerShare, lastRewardBlock, totalPower, startBlock, endBlock);
    }

    function _getUserTotalStaked(address userAddr) internal view returns (uint256 total) {
        StakeInfo[] storage stakes = userStakes[userAddr];
        for (uint i = 0; i < stakes.length; i++) {
            total += stakes[i].amountStaked;
        }
    }

    function _calculatePower(uint256 amount, uint256 option) internal view returns (uint256) {
        if (mode == 0 || mode == 1) return amount;
        return amount * powerMultipliers[option] / 100;
    }

    function getUserTotalStaked(address userAddr) external view returns (uint256) {
        return _getUserTotalStaked(userAddr);
    }

    function getUserPendingReward(address userAddr) external view returns (uint256 totalPending) {
        StakeInfo[] storage stakes = userStakes[userAddr];
        uint256 currentAcc = accRewardPerShare;
        uint256 currentBlock = block.number;

        if (currentBlock > lastRewardBlock && totalPower != 0) {
            uint256 finalBlock = endBlock == 0 ? currentBlock : (currentBlock > endBlock ? endBlock : currentBlock);
            uint256 blocksElapsed = finalBlock - lastRewardBlock;
            uint256 rewards = blocksElapsed * rewardPerBlock;
            currentAcc += rewards * 1e12 / totalPower;
        }

        for (uint i = 0; i < stakes.length; i++) {
            uint256 power = _calculatePower(stakes[i].amountStaked, stakes[i].lockOption);
            totalPending += (power * currentAcc / 1e12) - stakes[i].rewardDebt;
        }
    }

    function getUserAllStakes(address userAddr) external view returns (StakeInfo[] memory) {
        return userStakes[userAddr];
    }

    function getPoolInfo() external view returns (StakingLibrary.PoolData memory) {
        return StakingLibrary.PoolData({
            name: name,
            rewardToken: address(rewardToken),
            positionManagerOrStaking: address(stakingToken),
            token0: address(0),
            token1: address(0),
            fees: new uint24[](0),
            rewardPerBlock: rewardPerBlock,
            totalPower: totalPower,
            currentBlock: block.number,
            startBlock: startBlock,
            endBlock: endBlock
        });
    }
}
// File: contracts/CMswap/Staking/StakingV2Factory.sol


pragma solidity ^0.8.19;




contract StakingFactoryV2 {
    address public admin;
    address[] public allProjects;
    mapping(address => bool) public whitelist;
    address public feeToken;
    uint256 public feeAmount;
    bool public isPublic;
    address public feeReceiver;
    address public permissionAddress;

    event ProjectCreated(address indexed project, string name);
    event WhitelistUpdated(address indexed addr, bool allowed);

    constructor(address _feeToken, uint256 _feeAmount, bool _isPublic, address _feeReceiver, address _permissionAddress) {
        admin = msg.sender;
        whitelist[msg.sender] = true;
        feeToken = _feeToken;
        feeAmount = _feeAmount;
        isPublic = _isPublic;
        feeReceiver = _feeReceiver;
        permissionAddress = _permissionAddress;
    }

    error NotWhitelisted();
    error NotAdmin();
    error InvalidBlockRange();
    error ZeroReward();
    error LowAllowance();
    error TransferFailed();

    modifier onlyWhitelisted() {
        bool isAllowedByPermission = permissionAddress != address(0) && IPermissionCreated(permissionAddress).isAllowed(msg.sender);
        if (!whitelist[msg.sender] && !isPublic && !isAllowedByPermission) revert NotWhitelisted();
        _;
    }

    modifier onlyAdmin() {
        if (admin != msg.sender) revert NotAdmin();
        _;
    }

    function setWhitelist(address addr, bool allowed) external onlyAdmin {
        whitelist[addr] = allowed;
        emit WhitelistUpdated(addr, allowed);
    }

    function setFeeToken(address _newAddr) external onlyAdmin {
        feeToken = _newAddr;
    }

    function setFeeAmount(uint256 _newAmount) external onlyAdmin {
        feeAmount = _newAmount;
    }

    function setPublic(bool _status) external onlyAdmin {
        isPublic = _status;
    }

    function setFeeReceiver(address _newAddr) external onlyAdmin {
        feeReceiver = _newAddr;
    }

    function createProject(StakingLibrary.CreateProjectParams calldata params) external onlyWhitelisted returns (address project) {
        if (params.endBlockReward <= params.startBlockReward) revert InvalidBlockRange();
        if (params.totalRewards == 0) revert ZeroReward();
        if (params.tokenA != address(0)) revert InvalidBlockRange(); // Ensure tokenA is zero for V2

        uint256 totalBlock = params.endBlockReward - params.startBlockReward;
        uint128 rewardPerBlock = uint128(params.totalRewards / totalBlock);

        if (feeAmount > 0) {
            IERC20 _feeToken = IERC20(feeToken);
            if (_feeToken.allowance(msg.sender, address(this)) < feeAmount) revert LowAllowance();
            if (!_feeToken.transferFrom(msg.sender, feeReceiver, feeAmount)) revert TransferFailed();
        }

        StakingProjectV2.CreateProjectParams memory v2Params = StakingProjectV2.CreateProjectParams({
            name: params.name,
            stakingOrPMToken: params.stakingOrPMToken,
            rewardToken: params.rewardToken,
            rewardPerBlock: rewardPerBlock,
            mode: params.mode,
            lockDurations: params.lockDurations,
            powerMultipliers: params.powerMultipliers,
            projectOwner: params.projectOwner,
            startBlockReward: params.startBlockReward,
            endBlockReward: params.endBlockReward,
            userLockMaximum: params.userLockMaximum,
            poolLockMaximum: params.poolLockMaximum
        });

        project = address(new StakingProjectV2(v2Params));

        IERC20 rewardToken = IERC20(params.rewardToken);
        if (rewardToken.allowance(msg.sender, address(this)) < params.totalRewards) revert LowAllowance();
        if (!rewardToken.transferFrom(msg.sender, project, params.totalRewards)) revert TransferFailed();

        allProjects.push(project);
        emit ProjectCreated(project, params.name);
        return project;
    }

    function getAllProjects() external view returns (address[] memory) {
        return allProjects;
    }

    function getProjects(uint256 offset, uint256 limit) external view returns (address[] memory pagedProjects) {
        uint256 total = allProjects.length;
        if (offset >= total) return new address[](0);
        uint256 size = limit > total - offset ? total - offset : limit;
        pagedProjects = new address[](size);
        for (uint256 i = 0; i < size; i++) {
            pagedProjects[i] = allProjects[offset + i];
        }
    }

    function getProjectsCount() external view returns (uint256) {
        return allProjects.length;
    }
}
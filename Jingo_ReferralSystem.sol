// SPDX-License-Identifier: UNLICENSE

/*
   ___ _                    ______ _                            
  |_  (_)                   |  ___(_)                           
    | |_ _ __   __ _  ___   | |_   _ _ __   __ _ _ __   ___ ___ 
    | | | '_ \ / _` |/ _ \  |  _| | | '_ \ / _` | '_ \ / __/ _ \
/\__/ / | | | | (_| | (_) | | |   | | | | | (_| | | | | (_|  __/
\____/|_|_| |_|\__, |\___/  \_|   |_|_| |_|\__,_|_| |_|\___\___|
                __/ |                                           
               |___/                                            

WEBSITE: https://jingo.finance
TWITTER: https://x.com/JingoFinance
TELEGRAM https://t.me/JingoFinance

*/
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
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

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: contracts/CMswap/RefSystem/refV2.sol



pragma solidity ^0.8.0;




contract Jingo_ReferralSystem is Ownable {
    using SafeMath for uint256;

    struct Referral {
        address referral;
        uint256 timestamp;
    }

    struct Reward {
        address rewardToken;
        uint256 amount;
        uint256 timestamp;
        bool claimed;
    }

    struct RewardBatch {
        address user;
        address rewardToken;
        uint256 amount;
    }

    struct RemainingReward {
        address rewardToken;
        uint256 amount;
    }

    // Mappings
    mapping(address => Referral[]) public referrals;
    mapping(address => mapping(address => Reward[])) public userRewards;
    mapping(address => bool) public proxies;
    mapping(address => bool) public admins;
    mapping(address => address) public referralToReferrer;
    mapping(address => address[]) public userRewardTokens;
    address[] public allReferrers;
    mapping(address => uint256) public referrerIndex;

    uint256 public rewardDuration = 90 days;
    uint256 public maxOffset = 50;
    uint256 public maxBatchsize = 20;

    // Events
    event ReferralAdded(address indexed referrer, address indexed referral, uint256 timestamp);
    event ReferralRemoved(address indexed referrer, address indexed referral);
    event RewardDistributed(address indexed user, address indexed rewardToken, uint256 amount, uint256 timestamp);
    event RewardBatchDistributed(address indexed caller, uint256 batchSize, uint256 timestamp);
    event RewardClaimed(address indexed user, address indexed rewardToken, uint256 amount);
    event RewardReclaimed(address indexed user, address indexed rewardToken, uint256 amount, address indexed to);
    event ProxyAdded(address indexed proxy, address indexed admin);
    event ProxyRemoved(address indexed proxy, address indexed admin);
    event AdminAdded(address indexed admin, address indexed addedBy);
    event AdminRemoved(address indexed admin, address indexed removedBy);
    event UserRegistered(address indexed user, address indexed referrer);
    event ReferrerTransferred(address indexed referral, address indexed oldReferrer, address indexed newReferrer);

    modifier onlyAdmin() {
        require(admins[msg.sender] || owner() == msg.sender, "Caller is not an admin");
        _;
    }

    modifier onlyProxy() {
        require(proxies[msg.sender] || admins[msg.sender] || owner() == msg.sender, "Caller is not a proxy or admin");
        _;
    }

    constructor() Ownable(msg.sender) {}

    function addAdmin(address _admin) external onlyOwner {
        require(_admin != address(0), "Invalid address");
        require(!admins[_admin], "Address is already an admin");
        admins[_admin] = true;
        emit AdminAdded(_admin, msg.sender);
    }

    function setRewardDuration(uint256 _duration) external onlyAdmin {
        rewardDuration = _duration;
    }

    function setMaxOffset(uint256 _newOffset) external onlyAdmin {
        maxOffset = _newOffset;
    }

    function setMaxBatchsize(uint256 _newBatchsize) external onlyAdmin {
        maxBatchsize = _newBatchsize;
    }

    function removeAdmin(address _admin) external onlyOwner {
        require(_admin != address(0), "Invalid address");
        require(admins[_admin], "Address is not an admin");
        admins[_admin] = false;
        emit AdminRemoved(_admin, msg.sender);
    }

    function addProxy(address _proxy) external onlyAdmin {
        require(_proxy != address(0), "Invalid address");
        require(!proxies[_proxy], "Address is already a proxy");
        proxies[_proxy] = true;
        emit ProxyAdded(_proxy, msg.sender);
    }

    function removeProxy(address _proxy) external onlyAdmin {
        require(_proxy != address(0), "Invalid address");
        require(proxies[_proxy], "Address is not a proxy");
        proxies[_proxy] = false;
        emit ProxyRemoved(_proxy, msg.sender);
    }

    function _removeReferralFromReferrer(address _referrer, address _referral) internal {
        Referral[] storage refList = referrals[_referrer];
        for (uint256 i = 0; i < refList.length; i++) {
            if (refList[i].referral == _referral) {
                if (i < refList.length - 1) {
                    refList[i] = refList[refList.length - 1];
                }
                refList.pop();
                emit ReferralRemoved(_referrer, _referral);
                break;
            }
        }
        if (refList.length == 0 && referrerIndex[_referrer] > 0) {
            uint256 index = referrerIndex[_referrer].sub(1);
            if (index < allReferrers.length - 1) {
                allReferrers[index] = allReferrers[allReferrers.length - 1];
                referrerIndex[allReferrers[index]] = index.add(1);
            }
            allReferrers.pop();
            referrerIndex[_referrer] = 0;
        }
    }

    function setReferral(address _referrer, address _referral) external onlyProxy {
        require(_referrer != _referral, "Referrer and referral cannot be the same");
        require(_referrer != address(0) && _referral != address(0), "Invalid address");
        address oldReferrer = referralToReferrer[_referral];
        if (oldReferrer != address(0) && oldReferrer != _referrer) {
            _removeReferralFromReferrer(oldReferrer, _referral);
        }
        referrals[_referrer].push(Referral({referral: _referral, timestamp: block.timestamp}));
        referralToReferrer[_referral] = _referrer;
        if (referrerIndex[_referrer] == 0) {
            allReferrers.push(_referrer);
            referrerIndex[_referrer] = allReferrers.length;
        }
        emit ReferralAdded(_referrer, _referral, block.timestamp);
        if (oldReferrer != address(0) && oldReferrer != _referrer) {
            emit ReferrerTransferred(_referral, oldReferrer, _referrer);
        }
    }

    function register(address _referrer) external {
        require(_referrer != address(0) && msg.sender != address(0), "Invalid address");
        require(_referrer != msg.sender, "Cannot refer yourself");
        require(referralToReferrer[msg.sender] == address(0), "User already registered");
        referrals[_referrer].push(Referral({referral: msg.sender, timestamp: block.timestamp}));
        referralToReferrer[msg.sender] = _referrer;
        if (referrerIndex[_referrer] == 0) {
            allReferrers.push(_referrer);
            referrerIndex[_referrer] = allReferrers.length;
        }
        emit UserRegistered(msg.sender, _referrer);
    }

    function addDistributeRewardByProxy(address _user, address _rewardToken, uint256 _amount) external onlyProxy {
        require(_user != address(0) && _rewardToken != address(0), "Invalid address");
        require(_amount > 0, "Amount must be greater than 0");
        IERC20(_rewardToken).transferFrom(msg.sender, address(this), _amount);
        if (!isRewardTokenExists(_user, _rewardToken)) {
            userRewardTokens[_user].push(_rewardToken);
        }
        userRewards[_user][_rewardToken].push(Reward({
            rewardToken: _rewardToken,
            amount: _amount,
            timestamp: block.timestamp,
            claimed: false
        }));
        emit RewardDistributed(_user, _rewardToken, _amount, block.timestamp);
    }

    function distributeRewardBatch(RewardBatch[] calldata _rewards) external onlyProxy {
        require(_rewards.length > 0, "Batch cannot be empty");
        require(_rewards.length <= maxBatchsize, "Batch size exceeds limit");
        for (uint256 i = 0; i < _rewards.length; i++) {
            require(_rewards[i].user != address(0) && _rewards[i].rewardToken != address(0), "Invalid address");
            require(_rewards[i].amount > 0, "Amount must be greater than 0");
            IERC20(_rewards[i].rewardToken).transferFrom(msg.sender, address(this), _rewards[i].amount);
            if (!isRewardTokenExists(_rewards[i].user, _rewards[i].rewardToken)) {
                userRewardTokens[_rewards[i].user].push(_rewards[i].rewardToken);
            }
            userRewards[_rewards[i].user][_rewards[i].rewardToken].push(Reward({
                rewardToken: _rewards[i].rewardToken,
                amount: _rewards[i].amount,
                timestamp: block.timestamp,
                claimed: false
            }));
            emit RewardDistributed(_rewards[i].user, _rewards[i].rewardToken, _rewards[i].amount, block.timestamp);
        }
        emit RewardBatchDistributed(msg.sender, _rewards.length, block.timestamp);
    }

    function removeDistributeRewardByProxy(address _user, address _rewardToken, uint256 _amount) external onlyProxy {
        require(_user != address(0) && _rewardToken != address(0), "Invalid address");
        require(_amount > 0, "Amount must be greater than 0");
        require(IERC20(_rewardToken).balanceOf(address(this)) >= _amount, "Insufficient contract balance");
        IERC20(_rewardToken).transfer(msg.sender, _amount);
        emit RewardDistributed(_user, _rewardToken, _amount, block.timestamp);
    }

    function reclaimExpiredReward(address _user, address _rewardToken, address _to) external onlyProxy {
        require(_user != address(0) && _rewardToken != address(0) && _to != address(0), "Invalid address");
        uint256 expiredAmount = _getExpiredAmount(_user, _rewardToken);
        require(expiredAmount > 0, "No expired rewards to reclaim");
        require(IERC20(_rewardToken).balanceOf(address(this)) >= expiredAmount, "Insufficient contract balance");
        Reward[] storage rewards = userRewards[_user][_rewardToken];
        uint256 remainingAmount = expiredAmount;
        for (uint256 i = 0; i < rewards.length && remainingAmount > 0; i++) {
            if (!rewards[i].claimed && block.timestamp > rewards[i].timestamp.add(rewardDuration)) {
                if (rewards[i].amount <= remainingAmount) {
                    remainingAmount = remainingAmount.sub(rewards[i].amount);
                    rewards[i].claimed = true;
                    IERC20(_rewardToken).transfer(_to, rewards[i].amount);
                    emit RewardReclaimed(_user, _rewardToken, rewards[i].amount, _to);
                } else {
                    rewards[i].amount = rewards[i].amount.sub(remainingAmount);
                    IERC20(_rewardToken).transfer(_to, remainingAmount);
                    emit RewardReclaimed(_user, _rewardToken, remainingAmount, _to);
                    remainingAmount = 0;
                }
            }
        }
    }

    function claimAllRemainingReward() external {
        address[] memory rewardTokens = userRewardTokens[msg.sender];
        for (uint256 i = 0; i < rewardTokens.length; i++) {
            address rewardToken = rewardTokens[i];
            uint256 claimableAmount = _getClaimableAmount(msg.sender, rewardToken);
            if (claimableAmount > 0) {
                require(IERC20(rewardToken).balanceOf(address(this)) >= claimableAmount, "Insufficient contract balance");
                _claimReward(msg.sender, rewardToken, claimableAmount);
            }
        }
    }

    function getUserRewards(address _user, uint256 _page, uint256 _offsetInput) public view returns (RemainingReward[] memory) {
        require(_offsetInput <= maxOffset, "Offset exceeds maximum limit");
        require(_user != address(0), "Invalid user address");

        address[] memory rewardTokens = userRewardTokens[_user];
        uint256 totalTokens = rewardTokens.length;
        if (totalTokens == 0) return new RemainingReward[](0);

        uint256 start = _page.mul(_offsetInput);
        if (start >= totalTokens) return new RemainingReward[](0);

        uint256 end = start.add(_offsetInput) > totalTokens ? totalTokens : start.add(_offsetInput);
        RemainingReward[] memory result = new RemainingReward[](end.sub(start));

        for (uint256 i = start; i < end; i++) {
            address token = rewardTokens[i];
            uint256 totalAmount = _getClaimableAmount(_user, token);
            result[i.sub(start)] = RemainingReward({
                rewardToken: token,
                amount: totalAmount
            });
        }

        return result;
    }

    function getTotalRef(address _referrer) public view returns (uint256) {
        return referrals[_referrer].length;
    }

    function getRefferal(address _referrer, uint256 _page, uint256 _offset) public view returns (Referral[] memory) {
        require(_offset <= maxOffset, "Offset exceeds maximum limit");
        uint256 totalRefs = referrals[_referrer].length;
        if (totalRefs == 0) return new Referral[](0);
        uint256 start = _page.mul(_offset);
        if (start >= totalRefs) return new Referral[](0);
        uint256 end = start.add(_offset) > totalRefs ? totalRefs : start.add(_offset);
        Referral[] memory result = new Referral[](end.sub(start));
        for (uint256 i = start; i < end; i++) {
            result[i.sub(start)] = referrals[_referrer][i];
        }
        return result;
    }

    function getReferrer(address _referral) public view returns (address) {
        return referralToReferrer[_referral];
    }

    function getReferrers(uint256 _page, uint256 _offset) public view returns (address[] memory) {
        require(_offset <= maxOffset, "Offset exceeds maximum limit");
        uint256 totalReferrers = allReferrers.length;
        if (totalReferrers == 0) return new address[](0);
        uint256 start = _page.mul(_offset);
        if (start >= totalReferrers) return new address[](0);
        uint256 end = start.add(_offset) > totalReferrers ? totalReferrers : start.add(_offset);
        address[] memory result = new address[](end.sub(start));
        for (uint256 i = start; i < end; i++) {
            result[i.sub(start)] = allReferrers[i];
        }
        return result;
    }

    function getTotalReferrers() public view returns (uint256) {
        return allReferrers.length;
    }

    function getRewardTokenAtIndex(address _user, uint256 _index) public view returns (address) {
        require(_index < userRewardTokens[_user].length, "Invalid token index");
        return userRewardTokens[_user][_index];
    }

    function getRewardTokensCount(address _user) public view returns (uint256) {
        return userRewardTokens[_user].length;
    }

    function isRewardTokenExists(address _user, address _rewardToken) internal view returns (bool) {
        for (uint256 i = 0; i < userRewardTokens[_user].length; i++) {
            if (userRewardTokens[_user][i] == _rewardToken) {
                return true;
            }
        }
        return false;
    }

    function _getClaimableAmount(address _user, address _rewardToken) internal view returns (uint256) {
        uint256 total = 0;
        Reward[] storage rewards = userRewards[_user][_rewardToken];
        for (uint256 i = 0; i < rewards.length; i++) {
            if (!rewards[i].claimed && block.timestamp <= rewards[i].timestamp.add(rewardDuration)) {
                total = total.add(rewards[i].amount);
            }
        }
        return total;
    }

    function _getExpiredAmount(address _user, address _rewardToken) internal view returns (uint256) {
        uint256 total = 0;
        Reward[] storage rewards = userRewards[_user][_rewardToken];
        for (uint256 i = 0; i < rewards.length; i++) {
            if (!rewards[i].claimed && block.timestamp > rewards[i].timestamp.add(rewardDuration)) {
                total = total.add(rewards[i].amount);
            }
        }
        return total;
    }

    function _claimReward(address _user, address _rewardToken, uint256 _amount) internal {
        Reward[] storage rewards = userRewards[_user][_rewardToken];
        uint256 remainingAmount = _amount;
        for (uint256 i = 0; i < rewards.length && remainingAmount > 0; i++) {
            if (!rewards[i].claimed) {
                if (rewards[i].amount <= remainingAmount) {
                    remainingAmount = remainingAmount.sub(rewards[i].amount);
                    rewards[i].claimed = true;
                    IERC20(_rewardToken).transfer(_user, rewards[i].amount);
                    emit RewardClaimed(_user, _rewardToken, rewards[i].amount);
                } else {
                    rewards[i].amount = rewards[i].amount.sub(remainingAmount);
                    IERC20(_rewardToken).transfer(_user, remainingAmount);
                    emit RewardClaimed(_user, _rewardToken, remainingAmount);
                    remainingAmount = 0;
                }
            }
        }
    }
}
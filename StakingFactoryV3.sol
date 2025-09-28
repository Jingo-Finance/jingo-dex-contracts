
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
// File: contracts/lib/interfaces/v3-periphery/IERC165.sol



pragma solidity >=0.7.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: contracts/lib/interfaces/v3-periphery/IERC721.sol



pragma solidity >=0.7.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
      * - `from` cannot be the zero address.
      * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// File: contracts/lib/interfaces/v3-periphery/IERC721Metadata.sol



pragma solidity >=0.7.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: contracts/lib/interfaces/v3-periphery/IERC721Enumerable.sol



pragma solidity >=0.7.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// File: contracts/lib/interfaces/v3-periphery/IPoolInitializer.sol


pragma solidity >=0.7.5;
pragma abicoder v2;

/// @title Creates and initializes V3 Pools
/// @notice Provides a method for creating and initializing a pool, if necessary, for bundling with other methods that
/// require the pool to exist.
interface IPoolInitializer {
    /// @notice Creates a new pool if it does not exist, then initializes if not initialized
    /// @dev This method can be bundled with others via IMulticall for the first action (e.g. mint) performed against a pool
    /// @param token0 The contract address of token0 of the pool
    /// @param token1 The contract address of token1 of the pool
    /// @param fee The fee amount of the v3 pool for the specified token pair
    /// @param sqrtPriceX96 The initial square root price of the pool as a Q64.96 value
    /// @return pool Returns the pool address based on the pair of tokens and fee, will return the newly created pool address if necessary
    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);
}

// File: contracts/lib/interfaces/v3-periphery/IPeripheryPayments.sol


pragma solidity >=0.7.5;

/// @title Periphery Payments
/// @notice Functions to ease deposits and withdrawals of ETH
interface IPeripheryPayments {
    /// @notice Unwraps the contract's WETH9 balance and sends it to recipient as ETH.
    /// @dev The amountMinimum parameter prevents malicious contracts from stealing WETH9 from users.
    /// @param amountMinimum The minimum amount of WETH9 to unwrap
    /// @param recipient The address receiving ETH
    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable;

    /// @notice Refunds any ETH balance held by this contract to the `msg.sender`
    /// @dev Useful for bundling with mint or increase liquidity that uses ether, or exact output swaps
    /// that use ether for the input amount
    function refundETH() external payable;

    /// @notice Transfers the full amount of a token held by this contract to recipient
    /// @dev The amountMinimum parameter prevents malicious contracts from stealing the token from users
    /// @param token The contract address of the token which will be transferred to `recipient`
    /// @param amountMinimum The minimum amount of token required for a transfer
    /// @param recipient The destination address of the token
    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable;
}

// File: contracts/lib/interfaces/v3-periphery/IPeripheryImmutableState.sol


pragma solidity >=0.5.0;

/// @title Immutable state
/// @notice Functions that return immutable state of the router
interface IPeripheryImmutableState {
    /// @return Returns the address of the Uniswap V3 factory
    function factory() external view returns (address);

    /// @return Returns the address of WETH9
    function WETH9() external view returns (address);
}

// File: contracts/lib/interfaces/v3-periphery/PoolAddress.sol


pragma solidity >=0.5.0;

/// @title Provides functions for deriving a pool address from the factory, tokens, and the fee
interface PoolAddress {
    /// @notice The identifying key of the pool
    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    /// @notice Returns PoolKey: the ordered tokens with the matched fee levels
    /// @param tokenA The first token of a pool, unsorted
    /// @param tokenB The second token of a pool, unsorted
    /// @param fee The fee level of the pool
    /// @return Poolkey The pool details with ordered token0 and token1 assignments
    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external pure returns (PoolKey memory);

    /// @notice Deterministically computes the pool address given the factory and PoolKey
    /// @param factory The Uniswap V3 factory contract address
    /// @param key The PoolKey
    /// @return pool The contract address of the V3 pool
    function computeAddress(address factory, PoolKey memory key) external pure returns (address pool);
}

// File: contracts/lib/interfaces/v3-periphery/INonfungiblePositionManager.sol


pragma solidity >=0.7.5;

/// @title Non-fungible token for positions
/// @notice Wraps Uniswap V3 positions in a non-fungible token interface which allows for them to be transferred
/// and authorized.
interface INonfungiblePositionManager is
    IPoolInitializer,
    IPeripheryPayments,
    IPeripheryImmutableState,
    IERC721Metadata,
    IERC721Enumerable
{
    /// @notice Emitted when liquidity is increased for a position NFT
    /// @dev Also emitted when a token is minted
    /// @param tokenId The ID of the token for which liquidity was increased
    /// @param liquidity The amount by which liquidity for the NFT position was increased
    /// @param amount0 The amount of token0 that was paid for the increase in liquidity
    /// @param amount1 The amount of token1 that was paid for the increase in liquidity
    event IncreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    /// @notice Emitted when liquidity is decreased for a position NFT
    /// @param tokenId The ID of the token for which liquidity was decreased
    /// @param liquidity The amount by which liquidity for the NFT position was decreased
    /// @param amount0 The amount of token0 that was accounted for the decrease in liquidity
    /// @param amount1 The amount of token1 that was accounted for the decrease in liquidity
    event DecreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    /// @notice Emitted when tokens are collected for a position NFT
    /// @dev The amounts reported may not be exactly equivalent to the amounts transferred, due to rounding behavior
    /// @param tokenId The ID of the token for which underlying tokens were collected
    /// @param recipient The address of the account that received the collected tokens
    /// @param amount0 The amount of token0 owed to the position that was collected
    /// @param amount1 The amount of token1 owed to the position that was collected
    event Collect(uint256 indexed tokenId, address recipient, uint256 amount0, uint256 amount1);

    /// @notice Returns the position information associated with a given token ID.
    /// @dev Throws if the token ID is not valid.
    /// @param tokenId The ID of the token that represents the position
    /// @return nonce The nonce for permits
    /// @return operator The address that is approved for spending
    /// @return token0 The address of the token0 for a specific pool
    /// @return token1 The address of the token1 for a specific pool
    /// @return fee The fee associated with the pool
    /// @return tickLower The lower end of the tick range for the position
    /// @return tickUpper The higher end of the tick range for the position
    /// @return liquidity The liquidity of the position
    /// @return feeGrowthInside0LastX128 The fee growth of token0 as of the last action on the individual position
    /// @return feeGrowthInside1LastX128 The fee growth of token1 as of the last action on the individual position
    /// @return tokensOwed0 The uncollected amount of token0 owed to the position as of the last computation
    /// @return tokensOwed1 The uncollected amount of token1 owed to the position as of the last computation
    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    /// @notice Creates a new position wrapped in a NFT
    /// @dev Call this when the pool does exist and is initialized. Note that if the pool is created but not initialized
    /// a method does not exist, i.e. the pool is assumed to be initialized.
    /// @param params The params necessary to mint a position, encoded as `MintParams` in calldata
    /// @return tokenId The ID of the token that represents the minted position
    /// @return liquidity The amount of liquidity for this position
    /// @return amount0 The amount of token0
    /// @return amount1 The amount of token1
    function mint(MintParams calldata params)
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    /// @notice Increases the amount of liquidity in a position, with tokens paid by the `msg.sender`
    /// @param params tokenId The ID of the token for which liquidity is being increased,
    /// amount0Desired The desired amount of token0 to be spent,
    /// amount1Desired The desired amount of token1 to be spent,
    /// amount0Min The minimum amount of token0 to spend, which serves as a slippage check,
    /// amount1Min The minimum amount of token1 to spend, which serves as a slippage check,
    /// deadline The time by which the transaction must be included to effect the change
    /// @return liquidity The new liquidity amount as a result of the increase
    /// @return amount0 The amount of token0 to acheive resulting liquidity
    /// @return amount1 The amount of token1 to acheive resulting liquidity
    function increaseLiquidity(IncreaseLiquidityParams calldata params)
        external
        payable
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    /// @notice Decreases the amount of liquidity in a position and accounts it to the position
    /// @param params tokenId The ID of the token for which liquidity is being decreased,
    /// amount The amount by which liquidity will be decreased,
    /// amount0Min The minimum amount of token0 that should be accounted for the burned liquidity,
    /// amount1Min The minimum amount of token1 that should be accounted for the burned liquidity,
    /// deadline The time by which the transaction must be included to effect the change
    /// @return amount0 The amount of token0 accounted to the position's tokens owed
    /// @return amount1 The amount of token1 accounted to the position's tokens owed
    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    /// @notice Collects up to a maximum amount of fees owed to a specific position to the recipient
    /// @param params tokenId The ID of the NFT for which tokens are being collected,
    /// recipient The account that should receive the tokens,
    /// amount0Max The maximum amount of token0 to collect,
    /// amount1Max The maximum amount of token1 to collect
    /// @return amount0 The amount of fees collected in token0
    /// @return amount1 The amount of fees collected in token1
    function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);

    /// @notice Burns a token ID, which deletes it from the NFT contract. The token must have 0 liquidity and all tokens
    /// must be collected first.
    /// @param tokenId The ID of the token that is being burned
    function burn(uint256 tokenId) external payable;
}

// File: contracts/CMswap/Staking/StakingProjectV3.sol


pragma solidity ^0.8.19;





contract StakingProjectV3 {
    struct StakeInfo {
        uint256[] tokenIds;
        uint256 liquidity;
        uint256 rewardDebt;
        uint256 stakeTimestamp;
    }

    struct CreateProjectParams {
        string name;
        address rewardToken;
        address positionManager;
        address tokenA;
        address tokenB;
        uint24[] poolFees;
        uint128 rewardPerBlock;
        address projectOwner;
        uint256 startBlockReward;
        uint256 endBlockReward;
    }

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

    string public name;
    IERC20 public rewardToken;
    INonfungiblePositionManager public positionManager;
    address public tokenA;
    address public tokenB;
    uint24[] public poolFees;
    uint128 public rewardPerBlock;
    uint256 public accRewardPerShare;
    uint256 public lastRewardBlock;
    uint128 public totalPower;
    uint256 public startBlock;
    uint256 public endBlock;
    address public owner;
    bool public isPause;

    mapping(address => StakeInfo) public userStakes;

    event UserAction(address indexed user, string action, uint256 value);

    error NotOwner();
    error Paused();
    error ProgramEnded();
    error ProgramRunning();
    error NoTokenIds();
    error InvalidPair();
    error FeeNotAllowed();
    error NoStake();
    error NoRewards();
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
        rewardToken = IERC20(params.rewardToken);
        positionManager = INonfungiblePositionManager(params.positionManager);
        tokenA = params.tokenA;
        tokenB = params.tokenB;
        poolFees = params.poolFees;
        rewardPerBlock = params.rewardPerBlock;
        owner = params.projectOwner;
        startBlock = params.startBlockReward;
        endBlock = params.endBlockReward;
        lastRewardBlock = params.startBlockReward;
    }


    function extendProgram(uint256 totalReward, uint256 newStartBlock, uint256 newEndBlock) external onlyOwner {
        if (newEndBlock <= endBlock || newEndBlock <= newStartBlock) revert InvalidBlockRange();
        if (block.number <= endBlock) revert ProgramRunning();
        StakingLibrary.updatePool(rewardPerBlock, accRewardPerShare, lastRewardBlock, totalPower, startBlock, endBlock);
        rewardPerBlock = uint128(totalReward / (newEndBlock - newStartBlock));
        startBlock = newStartBlock;
        endBlock = newEndBlock;
        if (rewardToken.allowance(msg.sender, address(this)) < totalReward) revert LowAllowance();
        if (!rewardToken.transferFrom(msg.sender, address(this), totalReward)) revert TransferFailed();
    }

    function stake(uint256[] calldata tokenIds) external notPaused {
        if (block.number >= endBlock) revert ProgramEnded();
        if (tokenIds.length == 0) revert NoTokenIds();

        StakeInfo storage user = userStakes[msg.sender];
        uint256 totalAddedLiquidity = 0;

        for (uint i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];

            (,,address token0,address token1,uint24 fee,,,uint128 liquidity,,,,) = positionManager.positions(tokenId);

            if ((token0 != tokenA || token1 != tokenB) && (token0 != tokenB || token1 != tokenA)) revert InvalidPair();
            if (!isFeeAllowed(fee)) revert FeeNotAllowed();

            positionManager.safeTransferFrom(msg.sender, address(this), tokenId);
            user.tokenIds.push(tokenId);

            totalAddedLiquidity += liquidity;
        }

        StakingLibrary.updatePool(rewardPerBlock, accRewardPerShare, lastRewardBlock, totalPower, startBlock, endBlock);

        if (user.liquidity > 0) {
            uint256 pending = (user.liquidity * accRewardPerShare) / 1e12 - user.rewardDebt;
            if (pending > 0) {
                if (!rewardToken.transfer(msg.sender, pending)) revert TransferFailed();
                emit UserAction(msg.sender, "Harvest", pending);
            }
        } else {
            user.stakeTimestamp = block.timestamp;
        }

        user.liquidity += totalAddedLiquidity;
        user.rewardDebt = (user.liquidity * accRewardPerShare) / 1e12;
        totalPower += uint128(totalAddedLiquidity);
    }

    function withdraw() external {
        StakeInfo storage user = userStakes[msg.sender];
        if (user.tokenIds.length == 0) revert NoStake();

        StakingLibrary.updatePool(rewardPerBlock, accRewardPerShare, lastRewardBlock, totalPower, startBlock, endBlock);

        uint256 power = user.liquidity;
        uint256 pending = (power * accRewardPerShare) / 1e12 - user.rewardDebt;
        if (pending > 0) {
            if (!rewardToken.transfer(msg.sender, pending)) revert TransferFailed();
            emit UserAction(msg.sender, "Harvest", pending);
        }

        totalPower -= uint128(power);

        for (uint i = 0; i < user.tokenIds.length; i++) {
            positionManager.safeTransferFrom(address(this), msg.sender, user.tokenIds[i]);
            emit UserAction(msg.sender, "Withdraw", user.tokenIds[i]);
        }

        delete userStakes[msg.sender];
    }

    function harvest() external notPaused {
        StakeInfo storage user = userStakes[msg.sender];
        if (user.tokenIds.length == 0) revert NoStake();

        StakingLibrary.updatePool(rewardPerBlock, accRewardPerShare, lastRewardBlock, totalPower, startBlock, endBlock);

        uint256 power = user.liquidity;
        uint256 pending = (power * accRewardPerShare) / 1e12 - user.rewardDebt;
        if (pending == 0) revert NoRewards();

        user.rewardDebt = (power * accRewardPerShare) / 1e12;
        if (!rewardToken.transfer(msg.sender, pending)) revert TransferFailed();
        emit UserAction(msg.sender, "Harvest", pending);
    }

    function emergencyWithdraw() external {
        StakeInfo storage user = userStakes[msg.sender];
        if (user.tokenIds.length == 0) revert NoStake();

        uint256 power = user.liquidity;
        totalPower -= uint128(power);

        for (uint i = 0; i < user.tokenIds.length; i++) {
            positionManager.safeTransferFrom(address(this), msg.sender, user.tokenIds[i]);
            emit UserAction(msg.sender, "EmergencyWithdraw", user.tokenIds[i]);
        }

        delete userStakes[msg.sender];
    }

    function isFeeAllowed(uint24 fee) internal view returns (bool) {
        for (uint i = 0; i < poolFees.length; i++) {
            if (poolFees[i] == fee) return true;
        }
        return false;
    }

    function getUserInfo(address userAddr) external view returns (
        uint256[] memory tokenIds,
        uint256 liquidity,
        uint256 pendingReward,
        uint256 power,
        uint256 stakeTimestamp
    ) {
        StakeInfo storage user = userStakes[userAddr];
        tokenIds = user.tokenIds;
        liquidity = user.liquidity;
        stakeTimestamp = user.stakeTimestamp;

        uint256 currentAcc = accRewardPerShare;
        uint256 currentBlock = block.number;

        if (currentBlock > lastRewardBlock && totalPower != 0) {
            uint256 finalBlock = endBlock == 0 ? currentBlock : (currentBlock > endBlock ? endBlock : currentBlock);
            uint256 blocksElapsed = finalBlock - lastRewardBlock;
            uint256 rewards = blocksElapsed * rewardPerBlock;
            currentAcc += rewards * 1e12 / totalPower;
        }

        power = liquidity;
        pendingReward = (power * currentAcc) / 1e12 - user.rewardDebt;
    }

    function getPoolInfo() external view returns (StakingLibrary.PoolData memory) {
        return StakingLibrary.PoolData({
            name: name,
            rewardToken: address(rewardToken),
            positionManagerOrStaking: address(positionManager),
            token0: tokenA,
            token1: tokenB,
            fees: poolFees,
            rewardPerBlock: rewardPerBlock,
            totalPower: totalPower,
            currentBlock: block.number,
            startBlock: startBlock,
            endBlock: endBlock
        });
    }

// To receive ERC721 safely
        function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
            return this.onERC721Received.selector;
        }
}
// File: contracts/CMswap/Staking/StakingV3Factory.sol


pragma solidity ^0.8.19;




contract StakingFactoryV3 {
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
    error InvalidTokenPair();
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
        if (params.tokenA == address(0)) revert InvalidTokenPair(); 
        if (params.tokenB == address(0)) revert InvalidTokenPair(); 

        uint256 totalBlock = params.endBlockReward - params.startBlockReward;
        uint128 rewardPerBlock = uint128(params.totalRewards / totalBlock);

        if (feeAmount > 0) {
            IERC20 _feeToken = IERC20(feeToken);
            if (_feeToken.allowance(msg.sender, address(this)) < feeAmount) revert LowAllowance();
            if (!_feeToken.transferFrom(msg.sender, feeReceiver, feeAmount)) revert TransferFailed();
        }

        StakingProjectV3.CreateProjectParams memory v3Params = StakingProjectV3.CreateProjectParams({
            name: params.name,
            rewardToken: params.rewardToken,
            positionManager: params.stakingOrPMToken,
            tokenA: params.tokenA,
            tokenB: params.tokenB,
            poolFees: params.poolFees,
            rewardPerBlock: rewardPerBlock,
            projectOwner: params.projectOwner,
            startBlockReward: params.startBlockReward,
            endBlockReward: params.endBlockReward
        });

        project = address(new StakingProjectV3(v3Params));

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
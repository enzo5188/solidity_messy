// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;
pragma abicoder v2;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";

library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



contract CustomSwapContract is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    IUniswapV2Router02 public  immutable uniswapRouter;
    ISwapRouter public immutable swapRouter;
    uint public admin_fee_percentage = 0;
    address[] private  StableCoinAddress;
    address public  wethAddress = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6; // Hardcoded WETH address
    address public  uniswapRouterAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Hardcoded Uniswap V3 router address
    address public  _swapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
   
    
    // Constructor
    constructor(uint256 _admin_fee_percentage) Ownable(msg.sender) {
        uniswapRouter = IUniswapV2Router02(uniswapRouterAddress);
          swapRouter = ISwapRouter(_swapRouter);
          admin_fee_percentage = _admin_fee_percentage;
          
        }
    
 
    function setAdminFEE (uint _admin_fee_percentage) external  onlyOwner  { 
        require(_admin_fee_percentage <= 100, "Influencer fee percentage must be <= 100");
        admin_fee_percentage = _admin_fee_percentage;
    }
    function getCOntractBalance () external  view returns (uint256) {
        return address(this).balance;
    }
    function getTokenBalance(address tokenAddress , address holder ) external view returns (uint256) {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(holder);
        return balance;
    }
    function addStableCoinAddress(address _StableCoinAddress) public onlyOwner {
        StableCoinAddress.push(_StableCoinAddress);
    }
    function getStableCoinAddress() public view returns (address[] memory) {
        return StableCoinAddress;
    }

    function checkAddressesInStableCoin(address address0, address address1) internal view returns (bool) {
    bool foundAddress0 = false;
    bool foundAddress1 = false;

    for (uint256 i = 0; i < StableCoinAddress.length; i++) {
        if (address0 == StableCoinAddress[i]) {
            foundAddress0 = true;
        }
        if (address1 == StableCoinAddress[i]) {
            foundAddress1 = true;
        }

        // If both addresses are found, revert
        if (foundAddress0 && foundAddress1) {
            revert("Both addresses belong to StableCoinAddress");
        }
    }

    // If address0 is found, return true; otherwise, return false
    return foundAddress0;
}



    function WithdrawTokens(address tokenToSwap)
        external onlyOwner {
        address[] memory path = new address[](2);
        path[0] = tokenToSwap;
        path[1] = address(wethAddress); 
        uint256 balance = IERC20(tokenToSwap).balanceOf(address(this));
        IERC20(tokenToSwap).approve(address(uniswapRouter), balance);
        uint[] memory amountsOut = uniswapRouter.getAmountsOut(balance, path);
        uint256 amountOutMin = amountsOut[amountsOut.length - 1];
        uniswapRouter.swapExactTokensForETH(
            balance,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp + 10
        );
}
	function withdrawAllEther() external onlyOwner {
        require(address(this).balance > 0, "No funds available for withdrawal");

        payable(owner()).transfer(address(this).balance);
    }
    function ExactETHForTokensV2(
        uint256 amountOutMin,
        address[] calldata path
    ) external payable {
        require(path.length > 0, "Path cannot be empty");
        require(msg.sender.balance >= msg.value, "Insufficient balance ");
        uint256 adminFeePercentage = admin_fee_percentage;
        uint256 adminFee = (msg.value.mul(adminFeePercentage)).div(100);
        uint256 remainingAmount = msg.value.sub(adminFee);
        uint256 deadline = block.timestamp + 10;
        require(block.timestamp <= deadline, "Transaction deadline passed");
        uniswapRouter.swapExactETHForTokens{value: remainingAmount}(
            amountOutMin,
            path,
            msg.sender,
            deadline
        );
    }
    function ExactTokensForETHV2(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path
    ) external  {
    TransferHelper.safeTransferFrom(
        path[0],
        msg.sender,
        address(this),
        amountIn
    );
        TransferHelper.safeApprove(path[0], address(uniswapRouterAddress), amountIn);
        uint[] memory amounts = uniswapRouter.swapExactTokensForETH(
            amountIn,
            amountOutMin,
            path,
            address(this),
            block.timestamp + 10
        );
        uint256 amountOut = amounts[amounts.length - 1];
          uint256 adminFeePercentage = admin_fee_percentage;
        uint256 adminFee = (amountOut.mul(adminFeePercentage)).div(100);
        uint256 remainingAmount = amountOut.sub(adminFee);
         // Send the remaining amount of ETH to msg.sender
    (bool success, ) = msg.sender.call{value: remainingAmount}("");
    require(success, "Transfer failed");
    }
   function ExactTokensForTokensV2(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path
    ) external {
    bool isFirstAddressInStableCoin = checkAddressesInStableCoin(path[0], path[1]);

    // Case 1: If the first address is in the StableCoinAddress array
    if (isFirstAddressInStableCoin) {
        // Transfer tokens from the sender to this contract
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            address(this),
            amountIn
        );

        // Calculate admin fee
        uint256 adminFee = (amountIn * admin_fee_percentage) / 100;
        uint256 remainingAmount = amountIn.sub(adminFee);

        // Approve the uniswapRouter to spend the remainingAmount
        TransferHelper.safeApprove(path[0], address(uniswapRouter), remainingAmount);

        // Execute the swapExactTokensForTokens
        uniswapRouter.swapExactTokensForTokens(
            remainingAmount,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp + 10
        );
    }

    // Case 2: If the first address is not in the StableCoinAddress array
    else {
        // Check if the second address is in the StableCoinAddress array
        bool isSecondAddressInStableCoin = checkAddressesInStableCoin(path[0], path[1]);

        // If the second address is in the StableCoinAddress array
        if (isSecondAddressInStableCoin) {
            // Transfer tokens from the sender to this contract
            TransferHelper.safeTransferFrom(
                path[0],
                msg.sender,
                address(this),
                amountIn
            );

            // Approve the uniswapRouter to spend the input amount
            TransferHelper.safeApprove(path[0], address(uniswapRouter), amountIn);

            // Execute the swapExactTokensForTokens
            uint[] memory amounts = uniswapRouter.swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                address(this),
                block.timestamp + 10
            );

            // Calculate admin fee on the output amount
            uint amountOut = amounts[amounts.length - 1];
            uint256 adminFee = (amountOut * admin_fee_percentage) / 100;
            uint256 remainingAmount = amountOut.sub(adminFee);

            // Transfer the remaining amount to the original caller
            TransferHelper.safeTransfer(path[1], msg.sender, remainingAmount);
        }
    }
}


    function ExactTokensToTokensV3(
    address tokenIn,
    address tokenOut,
    uint256 amountIn,
    uint256 amountOutMinimum,
    uint160 sqrtPriceLimitX96,
    uint24 fee
) external returns (uint256 amountOut) {
    bool isFirstAddressInStableCoin = checkAddressesInStableCoin(tokenIn, tokenOut);

    // Case 1: If the first address is in the StableCoinAddress array
    if (isFirstAddressInStableCoin) {
        // Transfer tokens from the sender to this contract
        TransferHelper.safeTransferFrom(
            tokenIn,
            msg.sender,
            address(this),
            amountIn
        );

        // Calculate admin fee
        uint256 adminFee = (amountIn * admin_fee_percentage) / 100;
        uint256 remainingAmount = amountIn.sub(adminFee);

        // Approve the swapRouter to spend the remainingAmount
        TransferHelper.safeApprove(tokenIn, address(swapRouter), remainingAmount);

        // Prepare params for ExactInputSingle call
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
        .ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: fee,
            recipient: msg.sender,
            deadline: block.timestamp + 15,
            amountIn: remainingAmount,
            amountOutMinimum: amountOutMinimum,
            sqrtPriceLimitX96: sqrtPriceLimitX96
        });

        // Execute the swap and get the output amount
        amountOut = swapRouter.exactInputSingle(params);

        // Return the output amount
        return amountOut;
    }

    // Case 2: If the first address is not in the StableCoinAddress array
    else {
        // Check if the second address is in the StableCoinAddress array
        bool isSecondAddressInStableCoin = checkAddressesInStableCoin(tokenOut, tokenIn);

        // If the second address is in the StableCoinAddress array
        if (isSecondAddressInStableCoin) {
            // Transfer tokens from the sender to this contract
            TransferHelper.safeTransferFrom(
                tokenIn,
                msg.sender,
                address(this),
                amountIn
            );

            // Approve the swapRouter to spend the input amount
            TransferHelper.safeApprove(tokenIn, address(swapRouter), amountIn);

            // Prepare params for ExactInputSingle call
            ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: fee,
                recipient: address(this),
                deadline: block.timestamp + 15,
                amountIn: amountIn,
                amountOutMinimum: amountOutMinimum,
                sqrtPriceLimitX96: sqrtPriceLimitX96
            });

            // Execute the swap and get the output amount
            amountOut = swapRouter.exactInputSingle(params);

            // Calculate admin fee on the output amount
            uint256 adminFee = (amountOut * admin_fee_percentage) / 100;
            uint256 remainingAmount = amountOut.sub(adminFee);

            // Transfer the remaining amount to the original caller
            TransferHelper.safeTransfer(tokenOut, msg.sender, remainingAmount);

            // Return the output amount
            return amountOut;
        }
    }

    // Revert if neither address is in the StableCoinAddress array
    revert("Neither address belongs to StableCoinAddress");
}

    
    function ExactEthToTokenV3(
            address tokenIn,
            address tokenOut,
            uint256 amountOutMinimum,
            uint24 fee,
            uint160 sqrtPriceLimitX96
    ) external payable {
        require(msg.value > 0, "Must pass non 0 ETH amount");
        require(msg.sender.balance >= msg.value, "Insufficient balance ");
        uint256 adminFeePercentage = admin_fee_percentage;
        uint256 adminFee = (msg.value.mul(adminFeePercentage)).div(100);
        require(msg.value >= adminFee, "Insufficient Admin Fee");
        uint256 remainingAmount = msg.value.sub(adminFee);
        uint256 deadline = block.timestamp + 15; 
        address recipient = msg.sender;
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams(
            tokenIn,
            tokenOut,
            fee,
            recipient,
            deadline,
            remainingAmount,
            amountOutMinimum,
            sqrtPriceLimitX96
        );
        ISwapRouter(swapRouter).exactInputSingle{ value: remainingAmount}(params);
    }

    function ExactTokensToETHV3(
        address tokenIn,
        uint256 amountIn,
        uint256 amountOutMinimum,
        uint24 fee,
        uint160 sqrtPriceLimitX96
    ) external  returns (uint256 amountOut) {
        TransferHelper.safeTransferFrom(
            tokenIn,
            msg.sender,
            address(this),
            amountIn
        );
        TransferHelper.safeApprove(tokenIn, address(swapRouter), amountIn);
        ISwapRouter.ExactInputSingleParams memory params = 	ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: wethAddress,
            fee: fee,
            recipient: address(this),
            deadline: block.timestamp + 15,
            amountIn: amountIn,
            amountOutMinimum: amountOutMinimum,
            sqrtPriceLimitX96: sqrtPriceLimitX96
    });
            amountOut = swapRouter.exactInputSingle(params);
            unwrapAndTransfer(amountOut); 
            return amountOut;
    }
    function unwrapAndTransfer(uint256 amount) public   {
        uint256 wethBalance = IERC20(wethAddress).balanceOf(address(this));
        require(amount <= wethBalance, "Insufficient WETH balance");
        IWETH(wethAddress).withdraw(amount);
        uint256 adminFeePercentage = admin_fee_percentage;
        uint256 adminFee = (amount.mul(adminFeePercentage)).div(100);
        uint256 remainingAmount = amount.sub(adminFee);
        (bool success, ) = msg.sender.call{value: remainingAmount}("");
        require(success, "ETH transfer failed");
    }

 
         receive() external payable { }
}
// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;

import './libraries/TickMath.sol';
import './libraries/SqrtPriceMath.sol';

contract UniswapV3PoolConverter {

    constructor() {}

    /// @dev Common checks for valid tick inputs.
    function checkTicks(int24 tickLower, int24 tickUpper) private pure {
        require(tickLower < tickUpper, 'TLU');
        require(tickLower >= TickMath.MIN_TICK, 'TLM');
        require(tickUpper <= TickMath.MAX_TICK, 'TUM');
    }

    function convertPositionLiquidity(
      // the current price
      uint160 sqrtPriceX96,
      // the current tick
      int24 tick,
      // the lower and upper tick of the position
      int24 tickLower,
      int24 tickUpper,
      // liquidity of the position
      int128 liquidityDelta,
    ) public view returns (
            int256 amount0,
            int256 amount1
        )
    {
        checkTicks(params.tickLower, params.tickUpper);

        if (params.liquidityDelta != 0) {
            if (tick < tickLower) {
                // current tick is below the passed range; liquidity can only become in range by crossing from left to
                // right, when we'll need _more_ token0 (it's becoming more valuable) so user must provide it
                amount0 = SqrtPriceMath.getAmount0Delta(
                    TickMath.getSqrtRatioAtTick(tickLower),
                    TickMath.getSqrtRatioAtTick(tickUpper),
                    liquidityDelta
                );
            } else if (tick < tickUpper) {

                amount0 = SqrtPriceMath.getAmount0Delta(
                    sqrtPriceX96,
                    TickMath.getSqrtRatioAtTick(tickUpper),
                    liquidityDelta
                );
                amount1 = SqrtPriceMath.getAmount1Delta(
                    TickMath.getSqrtRatioAtTick(tickLower),
                    sqrtPriceX96,
                    liquidityDelta
                );

            } else {
                // current tick is above the passed range; liquidity can only become in range by crossing from right to
                // left, when we'll need _more_ token1 (it's becoming more valuable) so user must provide it
                amount1 = SqrtPriceMath.getAmount1Delta(
                    TickMath.getSqrtRatioAtTick(tickLower),
                    TickMath.getSqrtRatioAtTick(tickUpper),
                    liquidityDelta
                );
            }
        }
    }

}

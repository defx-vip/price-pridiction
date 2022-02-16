// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract AggregatorV3InterfaceImpl is AggregatorV3Interface{
    
    using SafeMath for uint256;
    
    uint256 public lastPrice = 37487918563;
    
    int256 public rundPrice= 63249688919;

     function decimals() external pure override returns (uint8) {
         return 8;
     }

    function description() external pure override returns (string memory) {
        return "hello";
    }

    function version() external pure override returns (uint256) {
        return 1;
    }

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) {
            return (_roundId, (int256)(lastPrice), 1620454751, 1620454751, _roundId );
        }

    function latestRoundData()
        external
        view override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) {
            uint256 number = block.timestamp;
            number = (number % (10)).mul(10 ** 8);
            number = number.add(lastPrice).add(block.difficulty);
            int256 price = int256(number);
            return (18446744073709636774,price, 1620454751, 1620454751, 18446744073709636774 );
        }

    function setLastPrice(uint256 _lastPrice) public{
        lastPrice = _lastPrice;
    }

    function setRundPrice(int256 _rundPrice) public{
        rundPrice = _rundPrice;
    }

    function latestRound() external pure override returns(uint80 roundId) {
        return 90;
    }
   
}
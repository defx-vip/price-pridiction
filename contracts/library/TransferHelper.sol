// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0; 

library TransferHelper {

    address private constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    
    function isETH(address token) internal pure returns (bool) {
        return token == ETH_ADDRESS;
    }

    function getETH() internal pure returns (address) {
        return ETH_ADDRESS;
    }
}
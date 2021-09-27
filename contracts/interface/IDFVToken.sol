// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0; 

interface IDFVToken {

    function getSuperior(address account) external view returns (address superior);

    function mint(uint256 dftAmount, address superiorAddress) external;

    function mintToUser(uint256 dftAmount, address account, address superiorAddress) external;

    function _dftRatio() external view returns(uint256 dftRatio);
    
    function _dftTeam() external view returns(address team);

    function transfer(address to, uint256 DFVAmount) external returns (bool);

    function balanceOf(address account) external view returns (uint256 dfvAmount);
}
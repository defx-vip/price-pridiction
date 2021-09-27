// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAddressRelation {

    function bind(address user, address superior) external view returns(bool);
}
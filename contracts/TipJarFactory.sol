// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {TipJar} from "./TipJar.sol";

contract TipJarFactory {
    address[] private jars;
    mapping(address => address[]) private jarsByOwner;

    event JarCreated(
        address indexed owner,
        address indexed jar,
        uint256 targetAmount,
        uint256 unlockTime
    );

    function createJar(
        uint256 targetAmount,
        uint256 unlockTime
    ) external returns (address jarAddress) {
        TipJar jar = new TipJar(msg.sender, targetAmount, unlockTime);

        jarAddress = address(jar);
        jars.push(jarAddress);
        jarsByOwner[msg.sender].push(jarAddress);

        emit JarCreated(msg.sender, jarAddress, targetAmount, unlockTime);
    }

    function getJarCount() external view returns (uint256) {
        return jars.length;
    }

    function getJar(uint256 index) external view returns (address) {
        return jars[index];
    }

    function getOwnerJarCount(address owner) external view returns (uint256) {
        return jarsByOwner[owner].length;
    }

    function getOwnerJar(
        address owner,
        uint256 index
    ) external view returns (address) {
        return jarsByOwner[owner][index];
    }
}

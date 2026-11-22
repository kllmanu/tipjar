// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {TipJar} from "./TipJar.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract TipJarFactory is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    address[] private jars;
    mapping(address => address[]) private jarsByOwner;

    function initialize() external initializer {
        __Ownable_init(msg.sender);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    event JarCreated(
        address indexed owner,
        address indexed jar,
        string name,
        uint256 targetAmount,
        uint256 unlockTime
    );

    function createJar(
        string calldata name,
        uint256 targetAmount,
        uint256 unlockTime
    ) external returns (address jarAddress) {
        TipJar jar = new TipJar(msg.sender, name, targetAmount, unlockTime);

        jarAddress = address(jar);
        jars.push(jarAddress);
        jarsByOwner[msg.sender].push(jarAddress);

        emit JarCreated(msg.sender, jarAddress, name, targetAmount, unlockTime);
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

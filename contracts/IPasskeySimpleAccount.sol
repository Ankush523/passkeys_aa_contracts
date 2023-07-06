// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@account-abstraction/interfaces/IAccount.sol";
import "./secp256r1.sol";

interface IPasskeySimpleAccount is IAccount {

    event PassKeyAdded(bytes32 indexed keyHash, uint256 publicKeyX, uint256 publicKeyY, string keyId);
    event PassKeyDeleted(bytes32 indexed keyHash, uint256 publicKeyX, uint256 publicKeyY, string keyId);

    function getPassKey() external view returns (PassKeyId[] memory);

    function addPassKey(string calldata _keyId, uint256 _pubKeyX, uint256 _pubKeyY) external;   

    function deletePassKey(string calldata _keyId) external;
}
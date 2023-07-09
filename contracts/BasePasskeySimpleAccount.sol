// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@account-abstraction/contracts/interfaces/IAccount.sol";
import "./IPasskeySimpleAccount.sol";

abstract contract BasePasskeySimpleAccount is  IAccount, IPasskeySimpleAccount {

    mapping(bytes32 => PassKeyId) public hashedKeys;
    bytes32[] private keyHashes;

    function addPassKey(string calldata _keyId, uint256 _pubKeyX, uint256 _pubKeyY) external override {
        _addPassKey(keccak256(abi.encodePacked(_keyId)), _pubKeyX, _pubKeyY, _keyId);
    }

    function _addPassKey(bytes32 _keyHash, uint256 _pubKeyX, uint256 _pubKeyY, string calldata _keyId) internal {
        emit PassKeyAdded(_keyHash, _pubKeyX, _pubKeyY, _keyId);
        hashedKeys[_keyHash] = PassKeyId(_pubKeyX, _pubKeyY, _keyId);
        keyHashes.push(_keyHash);
    }

    function getPassKey() external view override returns (PassKeyId[] memory acceptedKeys) {
        acceptedKeys = new PassKeyId[](keyHashes.length);
        for (uint i = 0; i < keyHashes.length; i++) {
            acceptedKeys[i] = hashedKeys[keyHashes[i]];
        }
        return acceptedKeys;
    }
    
    function deletePassKey(string calldata _passKeyID) external {
        require(keyHashes.length > 1, "Not allowed to delete the last key!!");
        bytes32 selectedKeyHash = keccak256(abi.encodePacked(_passKeyID));
        PassKeyId memory selectedKey = hashedKeys[selectedKeyHash];
        if(selectedKey.pubKeyX == 0 && selectedKey.pubKeyY == 0){
            return;
        }
        delete hashedKeys[selectedKeyHash];
        for(uint i = 0; i < keyHashes.length; i++){
            if(keyHashes[i] == selectedKeyHash){
                keyHashes[i] = keyHashes[keyHashes.length - 1];
                keyHashes.pop();
            }
        }
        emit PassKeyDeleted(selectedKeyHash, selectedKey.pubKeyX, selectedKey.pubKeyY, selectedKey.keyId);
    }

}

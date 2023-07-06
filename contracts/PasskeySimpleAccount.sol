// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@account-abstraction/samples/SimpleAccount.sol";
import "./IPasskeySimpleAccount.sol";
import "./secp256r1.sol";

contract PasskeySimpleAccount is SimpleAccount, IPasskeySimpleAccount {
    mapping(bytes32 => PassKeyId) public hashedKeys;
    bytes32[] private keyHashes;

    constructor(IEntryPoint anEntryPoint) SimpleAccount(anEntryPoint)  {
    }

    function initialize(uint256 _publicKeyX, uint256 _publicKeyY, string calldata _passKeyID) public virtual initializer {
        _addPassKey(keccak256(abi.encodePacked(_passKeyID)), _publicKeyX, _publicKeyY, _passKeyID);
    }

    function addPassKey(uint256 _publicKeyX, uint256 _publicKeyY, string calldata _passKeyID) external onlyOwner {
        _addPassKey(keccak256(abi.encodePacked(_passKeyID)), _publicKeyX, _publicKeyY, _passKeyID);
    }

    function _addPassKey(bytes32 _keyHash,uint256 _publicKeyX, uint256 _publicKeyY, string calldata _passKeyID) internal {
        emit PassKeyAdded(_keyHash,_publicKeyX, _publicKeyY, _passKeyID);
        hashedKeys[_keyHash] = PassKeyId(_publicKeyX, _publicKeyY, _passKeyID);
        keyHashes.push(_keyHash);
    }

    function getPassKey() external view returns(PassKeyId[] memory acceptedKeys) {
        acceptedKeys = new PassKeyId[](keyHashes.length);
        for(uint i = 0; i< acceptedKeys.length; i++){
            acceptedKeys[i] = hashedKeys[keyHashes[i]];
        }
        return acceptedKeys;
    }

    function deletePassKey(string calldata _passKeyID) external onlyOwner{
        require(keyHashes.length > 1, "Not allowed to delete the last key!!");
        bytes32 selectedKeyHash = keccak256(abi.encodePacked(_passKeyID));
        PassKeyId memory selectedKey = hashedKeys[selectedKeyHash];
        if(selectedKey.publicKeyX == 0 && selectedKey.publicKeyY == 0){
            return;
        }
        delete hashedKeys[selectedKeyHash];
        for(uint i = 0; i < keyHashes.length; i++){
            if(keyHashes[i] == selectedKeyHash){
                keyHashes[i] = keyHashes[keyHashes.length - 1];
                keyHashes.pop();
            }
        }
        emit PassKeyDeleted(selectedKeyHash, selectedKey.publicKeyX, selectedKey.publicKeyY, selectedKey.passKeyID);
    }
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@account-abstraction/contracts/core/BaseAccount.sol";
import "@account-abstraction/contracts/samples/SimpleAccount.sol";
import "./BasePasskeySimpleAccount.sol";
import "./utils/Base64.sol";
import "./secp256r1.sol";

contract PasskeySimpleAccount is SimpleAccount, BasePasskeySimpleAccount {
    
    constructor(IEntryPoint anEntryPoint) SimpleAccount(anEntryPoint) {
    }

    function initialize(uint256 _publicKeyX, uint256 _publicKeyY, string calldata _passKeyID) public virtual initializer {
        _addPassKey(keccak256(abi.encodePacked(_passKeyID)), _publicKeyX, _publicKeyY, _passKeyID);
    }

    function _validateSignature(UserOperation calldata userOp, bytes32 userOpHash) internal override virtual returns (uint256 validationData) {
        (bytes32 keyHash, uint256 sigx, uint256 sigy, bytes memory authenticatorData, string memory clientDataJSONPre, string memory clientDataJSONPost) = 
            abi.decode(userOp.signature, (bytes32, uint256, uint256, bytes, string, string));

        string memory opHashBase64 = Base64.encode(bytes.concat(userOpHash));
        string memory clientDataJSON = string.concat(clientDataJSONPre, opHashBase64, clientDataJSONPost);
        bytes32 clientHash = sha256(bytes(clientDataJSON));
        bytes32 sigHash = sha256(bytes.concat(authenticatorData, clientHash));

        PassKeyId memory passKey = hashedKeys[keyHash];
        require(passKey.publicKeyY != 0 && passKey.publicKeyY != 0, "Key not found");

        (bool success, bytes memory data) = address(this).call(abi.encodeWithSignature("Verify(bytes32,uint,uint,uint)",passKey, sigx, sigy, uint256(sigHash)));

        require(success == true && data.length == 1 && data[0] != 0x00, "Invalid signature");
        return 0;
    }
}
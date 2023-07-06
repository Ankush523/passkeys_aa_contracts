// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import "@account-abstraction/interfaces/IEntryPoint.sol";
import "./PasskeySimpleAccount.sol";

contract PasskeySimpleAccountFactory{

    PasskeySimpleAccount public immutable accountImplementation;

    constructor(IEntryPoint entryPoint) {
        accountImplementation = new PasskeySimpleAccount(entryPoint);
    }

    function createAccount(string calldata passKeyID, uint256 publicKeyX, uint256 publicKeyY, uint256 salt) public returns (PasskeySimpleAccount){
        address userAddr = getAddress(passKeyID, publicKeyX, publicKeyY,salt);
        uint codeSize = userAddr.code.length;
        if(codeSize > 0){
            return PasskeySimpleAccount(payable(userAddr));
        }
        return PasskeySimpleAccount(payable(new ERC1967Proxy{salt : bytes32(salt)}(
                address(accountImplementation),
                abi.encodeCall(PasskeySimpleAccount.initialize,(publicKeyX, publicKeyY,passKeyID))
            )));
    }

    function getAddress(string calldata passKeyID, uint256 publicKeyX, uint256 publicKeyY,uint256 salt) public view returns (address) {
        return Create2.computeAddress(bytes32(salt),keccak256(abi.encodePacked(
            type(ERC1967Proxy).creationCode,
            abi.encode(
                address(accountImplementation),
                abi.encodeCall(PasskeySimpleAccount.initialize,(publicKeyX, publicKeyY,passKeyID))
            )
        )));
    }

}
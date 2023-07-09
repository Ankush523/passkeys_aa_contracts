// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@account-abstraction/contracts/interfaces/IEntryPoint.sol";
import "./PasskeySimpleAccount.sol";

contract PasskeySimpleAccountFactory{

    PasskeySimpleAccount public immutable accountImplementation;

    constructor(IEntryPoint entryPoint) {
        accountImplementation = new PasskeySimpleAccount(entryPoint);
    }

    function createAccount(uint256 salt, string calldata keyId, uint256 pubKeyX, uint256 pubKeyY) public returns (PasskeySimpleAccount){
        address userAddr = getAddress(salt, keyId, pubKeyX, pubKeyY);
        uint codeSize = userAddr.code.length;
        if(codeSize > 0){
            return PasskeySimpleAccount(payable(userAddr));
        }
        return PasskeySimpleAccount(payable(new ERC1967Proxy{salt : bytes32(salt)}(
                address(accountImplementation),
                abi.encodeCall(PasskeySimpleAccount.initialize,(keyId, pubKeyX, pubKeyY))
            )));
    }

    function getAddress(uint256 salt, string calldata keyId, uint256 pubKeyX, uint256 pubKeyY) public view returns (address) {
        return Create2.computeAddress(bytes32(salt),keccak256(abi.encodePacked(
            type(ERC1967Proxy).creationCode,
            abi.encode(
                address(accountImplementation),
                abi.encodeCall(PasskeySimpleAccount.initialize,(keyId, pubKeyX, pubKeyY))
            )
        )));
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Base64 {

    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

    function encode(bytes memory data) internal pure returns (string memory) {

        if (data.length == 0) return "";

        string memory table = _TABLE;

        uint256 newlength = data.length * 8 / 6;
        if (data.length % 6 > 0) {
            newlength++;
        }
        string memory result = new string(newlength);

        assembly {

            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                    mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                    resultPtr := add(resultPtr, 1)
                        mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                        resultPtr := add(resultPtr, 1)
                            mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                            resultPtr := add(resultPtr, 1)
            }
        }

        return result;
    }
}
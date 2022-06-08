// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


// 合约的继承：https://learnblockchain.cn/article/1944
contract TaiShangCodeNFT is ERC721Enumerable, Ownable{

    // Using For: https://learnblockchain.cn/docs/solidity/0.6.12/contracts/using-for.html
    using Strings for uint256;
    using HexStrings for uint160;
    using Counters for Counters.Counter;
    Counters.Counter private tokenCounter;

    // maping 类型: https://learnblockchain.cn/2017/12/27/solidity-structs
    mapping (uint256 => string) public code;
    mapping (uint256 => string) public creators;
    mapping (uint256 => bool) public verified;

    constructor() public ERC721("Tai Shang Code NFT", "TSCN") {
        // Tai Shang Voxel
    }

    // 函数可见性：https://learnblockchain.cn/docs/solidity/contracts.html#getter
    // 修改器：https://learnblockchain.cn/docs/solidity/contracts.html#modifier
    function verify(uint256 tokenId) public onlyOwner{
        // verified by owner
        verified[tokenId] = true;
    }

    // ============ PUBLIC FUNCTIONS FOR MINTING ============

    // external 会花费更少的gas费用
    function mint(string memory _uri, string memory _creators) external returns (uint256){
        uint256 _tokenId = nextTokenId();
        _safeMint(msg.sender, _tokenId);
        code[_tokenId] = _uri;
        creators[_tokenId] = _creators;
        return _tokenId;
    }

    // ============ PUBLIC READ-ONLY FUNCTIONS ============

    function getLastTokenId() external view returns (uint256) {
        return tokenCounter.current();
    }

    // ============ SUPPORTING FUNCTIONS ============

    function nextTokenId() private returns (uint256) {
        tokenCounter.increment();
        return tokenCounter.current();
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {

        string[11] memory parts;
        parts[
            0
        ] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
        parts[1] = "data resource based on: KAI Network";
        parts[2] = '</text><text x="10" y="40" class="base">';
        parts[3] = "code  id: ";
        parts[4] = '</text><text x="10" y="60" class="base">';
        parts[5] = code[tokenId];
        parts[6] = '</text><text x="10" y="80" class="base">';
        parts[7] = "creator: ";
        parts[8] = '</text><text x="10" y="100" class="base">';
        parts[9] = creators[tokenId];
        parts[10] = "</text></svg>";

        string memory output = string(
            abi.encodePacked(
            parts[0],
            parts[1],
            parts[2],
            parts[3],
            parts[4],
            parts[5],
            parts[6],
            parts[7],
            parts[8],
            parts[9]
            )
        );

        output = string(
            abi.encodePacked(
                output,
                parts[10]
                )
        );
        require(_exists(tokenId), "Nonexistent token");
        string memory name = string(abi.encodePacked('Tai Shang Code NFT #', tokenId.toString()));
        string memory description = string(abi.encodePacked(
            'A Tai Shang Code NFT token created by ', creators[tokenId],
            '. To view the code, visit https://www.arweave.net/', code[tokenId], '.if verified by offcial:', verified[tokenId]?"yes":"no"));

        return
          // https://learnblockchain.cn/docs/solidity/cheatsheet.html
          string(
              abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                          abi.encodePacked(
                              '{"name":"',
                              name,
                              '", "description":"',
                              description,
                              '", "attributes": []',
                              ', "creator":"',
                              creators[tokenId],
                              '", "image": "data:image/svg+xml;base64,',
                                Base64.encode(bytes(output)),
                              '"}'
                          )
                        )
                    )
              )
          );
    }
}

library HexStrings {
    bytes16 internal constant ALPHABET = '0123456789abcdef';

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = '0';
        buffer[1] = 'x';
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = ALPHABET[value & 0xf];
            value >>= 4;
        }
        return string(buffer);
    }
}

// File base64-sol/base64.sol@v1.1.0

/// @title Base64
/// @author Brecht Devos - <brecht@loopring.org>
/// @notice Provides functions for encoding/decoding base64
library Base64 {
    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return '';

        // load the table into memory
        string memory table = TABLE_ENCODE;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {} lt(dataPtr, endPtr) {}
            {
                // read 3 bytes
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                // write 4 characters
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }

    function decode(string memory _data) internal pure returns (bytes memory) {
        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        // load the table into memory
        bytes memory table = TABLE_DECODE;

        // every 4 characters represent 3 bytes
        uint256 decodedLen = (data.length / 4) * 3;

        // add some extra buffer at the end required for the writing
        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            // padding with '='
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            // set the actual output length
            mstore(result, decodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 4 characters at a time
            for {} lt(dataPtr, endPtr) {}
            {
               // read 4 characters
               dataPtr := add(dataPtr, 4)
               let input := mload(dataPtr)

               // write 3 bytes
               let output := add(
                   add(
                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),
                   add(
                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),
                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}

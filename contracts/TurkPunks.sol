// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TurkPunks is ERC721, ReentrancyGuard, Ownable {
   
    struct Asset {
        string name;
        string data;
    }

    Asset[] internal heads;
    Asset[] internal hairs;
    Asset[] internal eyes;
    Asset[] internal mouths;

    uint256 public mintCount;
    uint256 public MAX_SUPPLY = 11000;
    uint256 public MINT_PRICE = 0.03 ether;
    bool started = false;

    constructor() ERC721("TurkPunks", "TP") {}
    
    function withdrawToPayees(uint256 _amount) internal {
        uint256 amount = _amount;
        payable(0x3B99E794378bD057F3AD7aEA9206fB6C01f3Ee60).transfer(
            amount / 3
        ); // artist

        payable(0x575CBC1D88c266B18f1BB221C1a1a79A55A3d3BE).transfer(
            amount / 3
        ); // developer

        payable(0xBF7288346588897afdae38288fff58d2e27dd235).transfer(
            amount / 3
        ); // developer
    }
    
    
    function _mint(address _to) internal {
        require(mintCount < MAX_SUPPLY, "Sold Out!");
        _safeMint(_to, mintCount);
        mintCount++;
    }
    
    

    
    function devMint(address _to) external onlyOwner {
        _mint(_to);
    }

    function startWithPreMint(uint256 _amount) external onlyOwner {
        require(started == false);
        for (uint256 i; i < _amount; i++) {
            _mint(msg.sender);
        }
        started = true;
    }

    function mint(uint256 _amount) external payable nonReentrant {
        require(started == true, "not started");
        require(
            msg.value >= _amount * MINT_PRICE,
            "please send 0.03 ether to mint."
        );
        withdrawToPayees(msg.value);
        for (uint256 i; i < _amount; i++) {
            _mint(msg.sender);
        }
    }



    function uploadHead(Asset calldata _head) external {
        heads.push(_head);
    }

    function uploadHair(Asset calldata _hair) external {
        hairs.push(_hair);
    }

    function uploadEye(Asset calldata _eye) external {
        eyes.push(_eye);
    }

    function uploadMouth(Asset calldata _mouth) external {
        mouths.push(_mouth);
    }

    function renderRarity(uint8 rarity) internal pure returns (string memory) {
        if (rarity == 1) {
            // not rare
            return "";
        } else if (rarity == 2) {
            // rare
            return "<text y='30' x='20' class='vr'>R</text>";
        } else if (rarity == 3) {
            // very rare
            return
                "<text y='30' x='0' class='vr'>V</text><text y='30' x='20' class='vr'>R</text>";
        } else {
            return "";
        }
    }

    function renderAssetInSvg(
        uint8 x,
        uint8 y,
        string memory _base64
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "<image x='",
                    toString(x),
                    "' y='",
                    toString(y),
                    "' href='data:image/png;base64,",
                    _base64,
                    "' />"
                )
            );
    }

    function render(
        uint8 _rarity,
        string memory _hair_b64,
        string memory _eye_b64,
        string memory _head_b64,
        string memory _mouth_b64
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "<svg xmlns='http://www.w3.org/2000/svg' height='150' width='150' viewBox='0 0 150 150'><style>.vr{ font-size: 5px; fill: red; }</style><rect width='100%' height='100%' fill='white' /><svg viewBox='-7.5 -7.5 40 40'>",
                    renderRarity(_rarity),
                    renderAssetInSvg(0, 1, _head_b64),
                    renderAssetInSvg(0, 0, _hair_b64),
                    renderAssetInSvg(3, 5, _eye_b64),
                    renderAssetInSvg(7, 15, _mouth_b64),
                    "</svg></svg>"
                )
            );
    }

     function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        super.tokenURI(tokenId);
        uint256 count = 0;
        for (uint8 headIndex; headIndex < heads.length; headIndex++) {
            for (uint8 hairIndex; hairIndex < hairs.length; hairIndex++) {
                for (uint8 eyeIndex; eyeIndex < eyes.length; eyeIndex++) {
                    for (
                        uint8 mouthIndex;
                        mouthIndex < mouths.length;
                        mouthIndex++
                    ) {
                        if (count == tokenId) {
                            return
                                string(
                                    abi.encodePacked(
                                        "data:application/json;base64,",
                                        encode(
                                            bytes(
                                                abi.encodePacked(
                                                    '{"name": "TurkPunk #',
                                                    toString(tokenId),
                                                    '", "description": "tp 100% ipfs.", "image": "data:image/svg+xml;base64,',
                                                    string(
                                                        encode(
                                                            abi.encodePacked(
                                                                render(
                                                                    2,
                                                                    hairs[
                                                                        hairIndex
                                                                    ].data,
                                                                    eyes[
                                                                        eyeIndex
                                                                    ].data,
                                                                    heads[
                                                                        headIndex
                                                                    ].data,
                                                                    mouths[
                                                                        mouthIndex
                                                                    ].data
                                                                )
                                                            )
                                                        )
                                                    ),
                                                    '", "attributes": [{"trait_type": "Head", "value": "',
                                                    heads[headIndex].name,
                                                    '"}, {"trait_type": "Eyes", "value": "',
                                                    eyes[eyeIndex].name,
                                                    '"}, {"trait_type": "Hair", "value": "',
                                                    hairs[hairIndex].name,
                                                    '"}, {"trait_type": "Mouth", "value": "',
                                                    mouths[mouthIndex].name,
                                                    '"} ]  }'
                                                )
                                            )
                                        ),
                                        "#"
                                    )
                                );
                        }
                        count++;
                    }
                }
            }
        }
        return "";
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    // @title Base64
    // @author Brecht Devos - <brecht@loopring.org>
    // @notice Provides a function for encoding some bytes in base64
    function encode(bytes memory data) internal pure returns (string memory) {
        string
            memory TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

        if (data.length == 0) return "";

        // load the table into memory
        string memory table = TABLE;

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
            for {

            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)

                // read 3 bytes
                let input := mload(dataPtr)

                // write 4 characters
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(input, 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
        }

        return result;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



interface IRenderer {
    function renderImage( uint8 _b, uint8 _e, uint8 _m, uint8 _h, uint8 _r ) external view returns (string memory);
}

contract TurkPunks is ERC721, ReentrancyGuard, Ownable {
    bool public started = false;
    uint256 public mintCount;
    uint256 public MAX_SUPPLY = 0;
    uint256 public MINT_PRICE = 0.03 ether;
    
    address rendererContract = address(0);
    
    string description = "";
    
    string[] internal bodies = [
        "White Cartoon Head.png",
        "Beige Cartoon Head.png",
        "Standard Head.png",
        "Zombie Head.png",
        "Cartoon Head.png"
    ];
    string[] internal eyes = [
        "Green Eyes.png",
        "Melancholic Blue Eyes.png",
        "Green Thin Glasses.png",
        "Snake Eyes.png",
        "Red Glasses.png",
        "Purple Glasses.png",
        "Angry Black Eyes.png",
        "Yellow Bee Eyes.png",
        "Curious Blue Eyes.png",
        "Red Irregular Glasses.png",
        "Flaring Eyes.png",
        "Black Eyes.png",
        "Purple Cool Glasses.png",
        "Red Eyes.png"
    ];
    string[] internal mouths = [
        "Mop Specialist Mouth.png",
        "Orange Beard.png",
        "Blower Mouth.png",
        "Tongue Down.png",
        "Standard Mouth.png",
        "Horny Mouth.png",
        "Cool Beard.png",
        "Sad Mouth.png",
        "Tongue Left Down.png",
        "Demonic Beard.png",
        "Mouth With Lipstick.png",
        "Small Mouth With Mustache.png",
        "Cute Mouth.png",
        "Tricky Mouth.png"
    ];
    string[] internal hairs = [
        "Blonde Long Hair.png",
        "Brown Short Hair.png",
        "Black Shitty Hair.png",
        "Purple Hair.png",
        "Activist Berfo Hair.png",
        "Purple Messy Hair.png",
        "Blue Hat.png",
        "Purple Curly Hair.png",
        "Green Hair.png",
        "Brown Hair.png",
        "Red Hedgehog Hair.png",
        "Red Curly Hair.png",
        "Turquoise Hair.png",
        "Blonde Hedgehog Hair.png",
        "Red Long Hair.png",
        "Blue Hair.png",
        "Yellow Hair.png",
        "Blonde Short Hair.png"
    ];

    bytes5[] internal dnaArray;

    function createDna(
        uint8 _b, // body id
        uint8 _e, // eye id
        uint8 _m, // mouth id
        uint8 _h, // hair id
        uint8 _r // rarity | 0: usual, 1: rare, 2: very rare
    ) internal pure returns (bytes5) {
        return
            bytes5(
                bytes.concat(
                    bytes1(_b),
                    bytes1(_e),
                    bytes1(_m),
                    bytes1(_h),
                    bytes1(_r)
                )
            );
    }

    function parseDna(bytes5 _dna)
        internal
        pure
        returns (
            uint8, // body id
            uint8, // eye id
            uint8, // mouth id
            uint8, // hair id
            uint8 // rarity id
        )
    {
        return (
            uint8(_dna[0]),
            uint8(_dna[1]),
            uint8(_dna[2]),
            uint8(_dna[3]),
            uint8(_dna[4])
        );
    }

    
    function setRendererContract(address _address) external onlyOwner {
        rendererContract = _address;
    }
    
    function setDescription(string calldata _description) external onlyOwner {
        description = _description;
    }

    function renderImage(
        uint8 _b,
        uint8 _e,
        uint8 _m,
        uint8 _h,
        uint8 _r
    ) internal view returns (string memory) {
        
        if(rendererContract == address(0)) {
            return string(
                    abi.encodePacked(
                        toString(_b),
                        toString(_e),
                        toString(_m),
                        toString(_h),
                        toString(_r),
                        ".png"
                    )
                );
        } else {
            IRenderer renderer = IRenderer(rendererContract);
            return renderer.renderImage(_b, _e, _m, _h, _r);
        }
    }


    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        
        require(_exists(tokenId), "uri query for nonexistent token");
        
        bytes5 dna = dnaArray[tokenId];
        (uint8 b, uint8 e, uint8 m, uint8 h, uint8 r) = parseDna(dna);
        string memory rarity;

        if (r == 0) {
            rarity = "Usual";
        } else if (r == 1) {
            rarity = "Rare";
        } else if (r == 2) {
            rarity = "Very Rare";
        }

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "TurkPunk #',
                                toString(tokenId),
                                '", "description": "tp 100% ipfs."',
                                ', "image": "',
                                renderImage(b, e, m, h, r),
                                '", "attributes": [{"trait_type": "Head", "value": "',
                                bodies[b],
                                '"}, {"trait_type": "Eyes", "value": "',
                                eyes[e],
                                '"}, {"trait_type": "Hair", "value": "',
                                hairs[h],
                                '"}, {"trait_type": "Mouth", "value": "',
                                mouths[m],
                                '"}, {"trait_type": "Rarity", "value": "',
                                rarity,
                                '"} ]  }'
                            )
                        )
                    ),
                    "#"
                )
            );
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
        require(mintCount + _amount <= MAX_SUPPLY, "exceeds the max supply");
        withdrawToPayees(msg.value);
        for (uint256 i; i < _amount; i++) {
            _mint(msg.sender);
        }
    }

    function incrementOrderArray(bytes5[] calldata _supply) external onlyOwner {
        for (uint256 i; i < _supply.length; i++) {
            dnaArray.push(_supply[i]);
        }
        MAX_SUPPLY = dnaArray.length;
    }

    constructor() ERC721("TurkPunks", "TP") onlyOwner {}

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

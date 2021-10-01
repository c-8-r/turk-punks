// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IRenderer {
    function renderImage( uint _b, uint _e, uint _m, uint _h, uint _r ) external view returns (string memory);
}

contract DNAEncoder {
    
    uint16 dna;

    
}

contract TurkPunks is ERC721, ReentrancyGuard, Ownable {
    bool public started = false;
    uint256 public mintCount;
    uint256 public MAX_SUPPLY = 0;
    uint256 public MINT_PRICE = 0.03 ether;
    
    address rendererContract = address(0);
    
    string description = "*100% Punk*";
    string base_url = "";
    string image_format = ".png";
    
    
    string[] internal bodies = [
        "White Cartoon Head",
        "Beige Cartoon Head",
        "Standard Head",
        "Zombie Head",
        "Cartoon Head"
    ];
    string[] internal eyes = [
        "Green Eyes",
        "Melancholic Blue Eyes",
        "Green Thin Glasses",
        "Snake Eyes",
        "Red Glasses",
        "Purple Glasses",
        "Angry Black Eyes",
        "Yellow Bee Eyes",
        "Curious Blue Eyes",
        "Red Irregular Glasses",
        "Flaring Eyes",
        "Black Eyes",
        "Purple Cool Glasses",
        "Red Eyes"
    ];
    string[] internal mouths = [
        "Mop Specialist Mouth",
        "Orange Beard",
        "Blower Mouth",
        "Tongue Down",
        "Standard Mouth",
        "Horny Mouth",
        "Cool Beard",
        "Sad Mouth",
        "Tongue Left Down",
        "Demonic Beard",
        "Mouth With Lipstick",
        "Small Mouth With Mustache",
        "Cute Mouth",
        "Tricky Mouth"
    ];
    string[] internal hairs = [
        "Blonde Long Hair",
        "Brown Short Hair",
        "Black Shitty Hair",
        "Purple Hair",
        "Activist Berfo Hair",
        "Purple Messy Hair",
        "Blue Hat",
        "Purple Curly Hair",
        "Green Hair",
        "Brown Hair",
        "Red Hedgehog Hair",
        "Red Curly Hair",
        "Turquoise Hair",
        "Blonde Hedgehog Hair",
        "Red Long Hair",
        "Blue Hair",
        "Yellow Hair",
        "Blonde Short Hair"
    ];
    
    
    struct DNA {
        uint body;
        uint eye;
        uint mouth;
        uint hair;
        uint rarity;
    }
    

    uint16[] internal dnaArray;

    function encodeDna(uint body, uint eye, uint mouth, uint hair, uint rarity) public pure returns(uint16) {
        return uint16(body + (eye * 5) + (mouth * 5 * 14) + (hair * 5 * 14 * 14) + (rarity * 5 * 14 * 14 * 18));
    }
    
    

    function decodeDna(uint16 _dna) public pure returns (DNA memory){
        uint rarity = _dna / (5 * 14 * 14 * 18);
        uint hair = (_dna % (5 * 14 * 14 * 18)) / (5 * 14 * 14);
        uint mouth = (_dna % (5 * 14 * 14)) / (5 * 14);
        uint eye = (_dna % (5 * 14)) / 5;
        uint body = (_dna % 5);
        return DNA(
            body,
            eye,
            mouth,
            hair,
            rarity
        );
    }

    
    function setRendererContract(address _address) external onlyOwner {
        rendererContract = _address;
    }
    
    function setDescription(string calldata _description) external onlyOwner {
        description = _description;
    }
    
    function setBaseUrl(string calldata _base_url) external onlyOwner {
        base_url = _base_url;
    }
    
    function setImageFormat(string calldata _image_format) external onlyOwner {
        image_format = _image_format;
    }


    function renderImage(
        uint _b,
        uint _e,
        uint _m,
        uint _h,
        uint _r
    ) internal view returns (string memory) {
        
        if(rendererContract == address(0)) {
            return string(
                    abi.encodePacked(
                        base_url,
                        toString(_b),
                        toString(_e),
                        toString(_m),
                        toString(_h),
                        toString(_r),
                        image_format
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
        
        uint16 dna = dnaArray[tokenId];
        DNA memory _dna = decodeDna(dna);
        string memory rarity;

        if (_dna.rarity == 0) {
            rarity = "Usual";
        } else if (_dna.rarity == 1) {
            rarity = "Rare";
        } else if (_dna.rarity == 2) {
            rarity = "Very Rare";
        }

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "#',
                                toString(tokenId),
                                '", "description": "',description,'"',
                                ', "image": "',
                                renderImage(_dna.body, _dna.eye, _dna.mouth, _dna.hair, _dna.rarity),
                                '", "attributes": [{"trait_type": "Head", "value": "',
                                bodies[_dna.body],
                                '"}, {"trait_type": "Eyes", "value": "',
                                eyes[_dna.eye],
                                '"}, {"trait_type": "Hair", "value": "',
                                hairs[_dna.hair],
                                '"}, {"trait_type": "Mouth", "value": "',
                                mouths[_dna.mouth],
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

    function incrementOrderArray(uint16[] calldata _supply) external onlyOwner {
        for (uint256 i; i < _supply.length; i++) {
            dnaArray.push(_supply[i]);
        }
        MAX_SUPPLY = dnaArray.length;
    }

    constructor() ERC721("Turk Punks", "TP") onlyOwner {}

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

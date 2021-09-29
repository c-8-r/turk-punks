// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract TurkPunks is ERC721URIStorage, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    
    bool started = false;
    Counters.Counter public _tokenIdCounter;
    uint256 public MAX_SUPPLY = 0;
    string baseURI;
    uint256[] internal orderArray;



    // INTERNAL VIEWS
    
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
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
    
    // INTERNAL ACTIONS
    
    
    
    function incrementOrderArray(uint256[] calldata supply) public onlyOwner {
        for(uint256 i; i < supply.length; i++) {
            orderArray.push(supply[i]);
        }
        MAX_SUPPLY = orderArray.length;
    }
    
    
    function withdrawToPayees(uint256 _amount) internal {
        uint256 amount = _amount;
        payable(0x3B99E794378bD057F3AD7aEA9206fB6C01f3Ee60).transfer(
            (amount / 100) * 40
        ); // artist

        payable(0x575CBC1D88c266B18f1BB221C1a1a79A55A3d3BE).transfer(
            (amount / 100) * 40
        ); // developer

        payable(0x50D80101e43db03740ad27F2aD6bC919012dc1f9).transfer(
            (amount / 100) * 20
        ); // autism
    }
    
    
    function _mint(address _to) internal {
        require(_tokenIdCounter.current() < MAX_SUPPLY, "Sold Out!");
        _safeMint(_to, orderArray[_tokenIdCounter.current()]);
        _tokenIdCounter.increment();
    }

    
    // EXTERNAL VIEWS
    
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721URIStorage)
        returns (string memory)
    {
        require(_exists(tokenId), "not exists");
        return string(abi.encodePacked(_baseURI(), toString(tokenId), ".json"));
    }
    
    
    // EXTERNAL ACTIONS
    function mint(uint256 _amount) external payable nonReentrant {
        require(started == true, "not started");
        require(
            msg.value >= _amount * 0.03 ether,
            "please send 0.03 ether to mint."
        );
        require( _tokenIdCounter.current() + _amount <= MAX_SUPPLY, "exceeds the max supply");
        withdrawToPayees(msg.value);
        for (uint256 i; i < _amount; i++) {
            _mint(msg.sender);
        }
    }

    
    // EXTERNAL OWNER ONLY!
    
    function setBaseURI(string calldata _uri) external onlyOwner {
        baseURI = _uri;
    }
    
     // to convert onchain
    function setTokenURI(uint256 _tokenId, string calldata _tokenURI)
        external
        onlyOwner
    {
        _setTokenURI(_tokenId, _tokenURI);
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
    
    constructor(string memory _uri) ERC721("TurkPunks", "TP") onlyOwner { 
        baseURI = _uri;
    }
    
    
}

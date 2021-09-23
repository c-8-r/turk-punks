// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TurkPunks is ERC721, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter public _tokenIdCounter;
    
    uint256 MAX_SUPPLY = 11000;
    
    string baseURI;
    
    bool started = false;

    constructor(string memory _uri) ERC721("TurkPunks", "TP") {
        baseURI = _uri;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
    
    function setBaseURI(string calldata _uri) external onlyOwner {
        baseURI = _uri;
    }
    
    function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {
        return string(abi.encodePacked(super.tokenURI(tokenId), ".json"));
    }

    function _mint(address _to) internal {
        require(_tokenIdCounter.current() < MAX_SUPPLY, "Sold Out!" );
        _safeMint(_to, _tokenIdCounter.current());
        _tokenIdCounter.increment();
    }
    
    function devMint(address _to) external onlyOwner {
        _mint(_to);
    }
    
    function startWithPreMint(uint256 _amount) external onlyOwner {
        require(started == false);
        for(uint256 i; i < _amount; i++) {
            _mint(msg.sender);
        }
        started = true;
    }
    
    function mint(uint256 _amount) external payable nonReentrant {
        require(started == true, "not started");
        require(msg.value >= _amount * 0.03 ether, "please send 0.03 ether to mint.");
        withdrawToPayees(msg.value);
        for(uint256 i; i < _amount; i++) {
            _mint(msg.sender);
        }
    }

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

}

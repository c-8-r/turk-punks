// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TurkPunk is ERC721URIStorage, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter public tokenIdCounter;
    Counters.Counter public supplyCounter;
    
    mapping (uint256 => string) private assets;
    mapping(address => uint256[]) public tokensByAddress;

    uint256 public mintPrice = 1 ether;
    
    bool public openForSale = false;
    
    modifier onlyOpen() {
        require(openForSale, "Sales are not opened");
        _;
    }
    modifier onlyNotOpen() {
        require(!openForSale, "Sales are opened");
        _;
    }
    
    function openSales() external onlyOwner onlyNotOpen nonReentrant {
        openForSale = true;
    }
    
    function addAsset(string memory assetURL) external onlyOwner onlyNotOpen nonReentrant {
        assets[supplyCounter.current()] = assetURL;
        supplyCounter.increment();
    }
    
    function addMultipleAssets(string[] calldata assetURLs) external onlyOwner onlyNotOpen nonReentrant {
        for (uint256 i = 0; i < assetURLs.length; i++) {
            string memory assetURL = assetURLs[i];
            assets[supplyCounter.current()] = assetURL;
            supplyCounter.increment();
        }
    }
    
    function mint(uint256 amount) external payable onlyOpen nonReentrant {
        require(msg.value >= mintPrice.mul(amount), "not enough ethers");
        for (uint256 i = 0; i < amount; i++) {
            uint256 id = tokenIdCounter.current();
            require(id < supplyCounter.current(), "not enough punks at the rest" );
            _safeMint(msg.sender, id);
            _setTokenURI(id, assets[id]);
            tokensByAddress[msg.sender].push(id);
            tokenIdCounter.increment();
        }
    }

    function tokenURI(uint256 tokenId) public view override(ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
    
    
    function getTokenByAddress(address _address) external view returns (uint256[] memory) {
        return tokensByAddress[_address];
    }
    
    
    
    
    
    constructor() ERC721("TurkPunk", "TP") {

    }
    
    
}
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

    struct Payee {
        address wallet;
        string role;
        uint256 percentage;
    }
    
    Payee[] public payees;
    
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
    
    function addPayee(address wallet, string memory role, uint256 percentage) internal onlyNotOpen onlyOwner nonReentrant {
        Payee memory payee = Payee(wallet, role, percentage);
        payees.push(payee);
    }
    
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function withdrawToPayees() external nonReentrant onlyOwner {
        uint256 totalBalance = getBalance();
        for (uint256 i = 0; i < payees.length; i++) {
            Payee memory payee = payees[i];
            address payable to = payable(payee.wallet);
            to.transfer(totalBalance.mul(payee.percentage).div(100));    
        }
    }
    
    function transferPunk(address to, uint256 tokenId) external nonReentrant {
        require(super.ownerOf(tokenId) == msg.sender, "this punk is not yours");
        super.approve(to, tokenId);
        super.transferFrom(msg.sender, to, tokenId);
    }
    
    constructor() ERC721("TurkPunk", "TP") {
        addPayee(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, "artist", 20);
        addPayee(0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c, "developer", 40);
        addPayee(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, "daddy", 40);
    }
    
    
}

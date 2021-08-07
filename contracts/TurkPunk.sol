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
    mapping (address => uint256[]) private tokensByAddress;

    uint256 public mintPrice = 0.1 ether;
    
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
    
    modifier onlyUser() {
        require(tx.origin == msg.sender, "contracts are not allowed");
        _;
    }
    
    function openSales() external onlyOwner onlyNotOpen nonReentrant {
        openForSale = true;
    }
    
    function addAsset(string memory assetURL) external onlyOwner onlyNotOpen nonReentrant {
        assets[supplyCounter.current()] = assetURL;
        supplyCounter.increment();
    }
    
    function addMultipleAssets(string[] memory assetURLs) external onlyOwner onlyNotOpen nonReentrant {
        for (uint256 i = 0; i < assetURLs.length; i++) {
            string memory assetURL = assetURLs[i];
            assets[supplyCounter.current()] = assetURL;
            supplyCounter.increment();
        }
    }
    
    function mint(uint256 amount) external payable onlyOpen nonReentrant onlyUser {
        require(msg.value >= mintPrice.mul(amount), "not enough ethers");
        for (uint256 i = 0; i < amount; i++) {
            uint256 id = tokenIdCounter.current();
            require(id < supplyCounter.current(), "not enough punks at the rest" );
            _safeMint(msg.sender, id);
            _setTokenURI(id, assets[id]);
            tokensByAddress[msg.sender].push(id);
            tokenIdCounter.increment();
        }
        withdrawToPayees(msg.value);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
    
    
    function getTokenByAddress(address _address) external view returns (   uint256[] memory  ) {
        uint256[] storage tokens = tokensByAddress[_address];
        return tokens;
    }
    
    function addPayee(address wallet, string memory role, uint256 percentage) internal onlyNotOpen onlyOwner nonReentrant {
        Payee memory payee = Payee(wallet, role, percentage);
        payees.push(payee);
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function withdrawAllToPayees() external nonReentrant onlyOwner onlyUser {
        uint256 totalBalance = getBalance();
        for (uint256 i = 0; i < payees.length; i++) {
            Payee memory payee = payees[i];
            address payable to = payable(payee.wallet);
            to.transfer(totalBalance.mul(payee.percentage).div(100));    
        }
    }
    
    function withdrawToPayees(uint256 _amount) internal onlyUser {
        for (uint256 i = 0; i < payees.length; i++) {
            Payee memory payee = payees[i];
            address payable to = payable(payee.wallet);
            to.transfer(_amount.mul(payee.percentage).div(100));    
        }
    }
    
    
    function transferPunk(address to, uint256 tokenId) external nonReentrant {
        require(super.ownerOf(tokenId) == msg.sender, "this punk is not yours");
        super.approve(to, tokenId);
        super.transferFrom(msg.sender, to, tokenId);
    }
    
    constructor() ERC721("TurkPunk", "TP") {
        addPayee(0x3B99E794378bD057F3AD7aEA9206fB6C01f3Ee60, "a", 50);
        addPayee(0x575CBC1D88c266B18f1BB221C1a1a79A55A3d3BE, "b", 50);
    }
    
    
}

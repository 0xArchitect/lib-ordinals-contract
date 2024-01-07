// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Whitelist} from "./utils/WhiteListSigner.sol";
import {IOrdinalsPass} from "./Interfaces/IOrdinalsPass.sol";

contract LGBOrdinalsMintController is
OwnableUpgradeable,
Whitelist {
    
    struct whitelistMint {
        uint256 startTime;
        uint256 endTime;
        uint256 minPurchase;
        uint256 maxPurchase;
        uint256 costPerToken;
    }
    
    uint256 public maxSupply;
    uint256 public ownerReserved;
    uint256 public ownerMinted;
    address public designatedSigner;
    
    whitelistMint public WL1;
    whitelistMint public WL2;
    whitelistMint public WL3;
    whitelistMint public WL4;
    
    mapping(bytes => bool) public isSignatureInvalid;
    mapping(address => bool) public isAddressInvalid;
    
    IOrdinalsPass public ordinalsPass;
    
    modifier checkSupply(uint256 _amount) {
        require(_amount > 0, "Invalid Amount");
        require(_amount + ordinalsPass.getTotalSupply() <= (maxSupply - ownerReserved) + ownerMinted, "Sold out");
        _;
    }
    
    function initialize(address _designatedSigner, address ordinalsPassAddress) public initializer {
        __Ownable_init();
        __WhiteList_init();
        maxSupply = 1212;
        ownerReserved = 132;
        ownerMinted = 12;

        WL1.startTime = 1680692400;
        WL1.endTime = WL1.startTime + 7 hours;
        WL1.minPurchase = 2;
        WL1.maxPurchase = 10;
        WL1.costPerToken = 0.018 ether;
        
        WL2.startTime = WL1.startTime + 1 hours;
        WL2.endTime = WL1.endTime;
        WL2.minPurchase = 2;
        WL2.maxPurchase = 5;
        WL2.costPerToken = 0.018 ether;
        
        WL3.startTime = WL1.startTime + 1 hours;
        WL3.endTime = WL1.endTime;
        WL3.minPurchase = 2;
        WL3.maxPurchase = 10;
        WL3.costPerToken = 0.018 ether;
        
        WL4.startTime = WL1.endTime;
        WL4.endTime = WL1.endTime + 2 days;
        WL4.minPurchase = 2;
        WL4.maxPurchase = 2;
        WL4.costPerToken = 0.025 ether;
    
        designatedSigner = _designatedSigner;
        ordinalsPass = IOrdinalsPass(ordinalsPassAddress);
    }
    
    function whitelistMint1(
        uint256 tokenAmount,
        whitelist memory whitelist_
    ) external payable checkSupply(tokenAmount) {
        require(getSigner(whitelist_) == designatedSigner, "Invalid Signature");
        require(block.timestamp > WL1.startTime, "Mint didn't start");
        require(WL1.endTime > block.timestamp, "Mint expired");
        require(whitelist_.listType == 1, "Invalid List Type");
        require(whitelist_.userAddress == msg.sender, "Invalid User Address");
        require(isSignatureInvalid[whitelist_.signature] == false, "Nonce already used");
        require(whitelist_.nonce + 3 minutes > block.timestamp, "Invalid Nonce");
        require(tokenAmount * WL1.costPerToken == msg.value, "Invalid Amount");
        require(tokenAmount >= WL1.minPurchase && tokenAmount <= WL1.maxPurchase,
        "Insufficient Token Balance");
        require(isAddressInvalid[msg.sender] == false, "Already Interacted");
        isAddressInvalid[msg.sender] = true;
        isSignatureInvalid[whitelist_.signature] = true;
        ordinalsPass.mint(msg.sender, tokenAmount);
    }
    
    function whitelistMint2 (
        uint256 tokenAmount,
        whitelist memory whitelist_
    ) external payable checkSupply(tokenAmount) {
        require(getSigner(whitelist_) == designatedSigner, "Invalid Signature");
        require(block.timestamp > WL2.startTime, "Mint didn't start");
        require(WL2.endTime > block.timestamp, "Mint expired");
        require(whitelist_.listType == 2, "Invalid List Type");
        require(whitelist_.userAddress == msg.sender, "Invalid User Address");
        require(isSignatureInvalid[whitelist_.signature] == false, "Nonce already used");
        require(whitelist_.nonce + 3 minutes > block.timestamp, "Invalid Nonce");
        require(tokenAmount * WL2.costPerToken == msg.value, "Invalid Amount");
        require(tokenAmount >= WL2.minPurchase && tokenAmount <= WL2.maxPurchase,
        "Insufficient Token Balance");
        require(isAddressInvalid[msg.sender] == false, "Already Interacted");
        isAddressInvalid[msg.sender] = true;
        isSignatureInvalid[whitelist_.signature] = true;
        ordinalsPass.mint(msg.sender,tokenAmount);
    }
    
    function whitelistMint3 (
        uint256 tokenAmount,
        whitelist memory whitelist_
    ) external payable checkSupply(tokenAmount){
        require(getSigner(whitelist_) == designatedSigner, "Invalid Signature");
        require(block.timestamp > WL3.startTime, "Mint didn't start");
        require(WL3.endTime > block.timestamp, "Mint expired");
        require(whitelist_.listType == 3, "Invalid List Type");
        require(whitelist_.userAddress == msg.sender, "Invalid User Address");
        require(isSignatureInvalid[whitelist_.signature] == false, "Nonce already used");
        require(whitelist_.nonce + 3 minutes > block.timestamp, "Invalid Nonce");
        require(tokenAmount * WL3.costPerToken == msg.value, "Invalid Amount");
        require(tokenAmount >= WL3.minPurchase && tokenAmount <= WL3.maxPurchase,
        "Insufficient Token Balance");
        
        require(isAddressInvalid[msg.sender] == false, "Already Interacted");
        isAddressInvalid[msg.sender] = true;
        isSignatureInvalid[whitelist_.signature] = true;
        ordinalsPass.mint(msg.sender, tokenAmount);
    }
    
    function whitelistMint4 (
        uint256 tokenAmount,
        whitelist memory whitelist_
    ) external payable checkSupply(tokenAmount){
        require(getSigner(whitelist_) == designatedSigner, "Invalid Signature");
        require(whitelist_.listType == 4, "Invalid List Type");
        require(whitelist_.userAddress == msg.sender, "Invalid User Address");
        require(block.timestamp > WL4.startTime, "Mint didn't start");
        require(WL4.endTime > block.timestamp, "Mint expired");
        require(isSignatureInvalid[whitelist_.signature] == false, "Nonce already used");
        require(whitelist_.nonce + 3 minutes > block.timestamp, "Invalid Nonce");
        require(tokenAmount * WL4.costPerToken == msg.value, "Invalid Amount");
        require(tokenAmount >= WL4.minPurchase && tokenAmount <= WL4.maxPurchase,
        "Insufficient Token Balance");
        require(isAddressInvalid[msg.sender] == false, "Already Interacted");
        isAddressInvalid[msg.sender] = true;
        isSignatureInvalid[whitelist_.signature] = true;
        ordinalsPass.mint(msg.sender, tokenAmount);
    }
    
    function airdropTokens(address[] calldata to, uint256[] calldata amount) external onlyOwner {
        for (uint256 i=0;i<to.length;i++)
        {
            require(ordinalsPass.getTotalSupply() + amount[i] <= maxSupply, "Exceeds Max Supply");
            require(amount[i] + ownerMinted <= ownerReserved, "Exceeds Owner Reserved");
            ownerMinted += amount[i];
            ordinalsPass.mint(to[i], amount[i]);
        }
    }
    
    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    
    // Setter Functions
    function setDesignatedSigner(address _designatedSigner) external onlyOwner {
        designatedSigner = _designatedSigner;
    }
    
    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        maxSupply = _maxSupply;
    }
    
    function setOwnerReserve(uint256 _ownerReserved) external onlyOwner {
        ownerReserved = _ownerReserved;
    }
    
    function setPassAddress(address _ordinalsPass) external onlyOwner {
        ordinalsPass = IOrdinalsPass(_ordinalsPass);
    }
    
    function set_WL1(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        uint256 _costPerToken
    ) external onlyOwner {
        require(_startTime < _endTime, "Invalid times");
        
        WL1.startTime = _startTime;
        WL1.endTime = _endTime;
        WL1.minPurchase = _minPurchase;
        WL1.maxPurchase = _maxPurchase;
        WL1.costPerToken = _costPerToken;
    }
    
    function set_WL2(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        uint256 _costPerToken
    ) external onlyOwner {
        require(_startTime < _endTime, "Invalid times");
    
        WL2.startTime = _startTime;
        WL2.endTime = _endTime;
        WL2.minPurchase = _minPurchase;
        WL2.maxPurchase = _maxPurchase;
        WL2.costPerToken = _costPerToken;
    }
    
    function set_WL3(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        uint256 _costPerToken
    ) external onlyOwner {
        require(_startTime < _endTime, "Invalid times");
    
        WL3.startTime = _startTime;
        WL3.endTime = _endTime;
        WL3.minPurchase = _minPurchase;
        WL3.maxPurchase = _maxPurchase;
        WL3.costPerToken = _costPerToken;
    }
    
    function set_WL4(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _minPurchase,
        uint256 _maxPurchase,
        uint256 _costPerToken
    ) external onlyOwner {
        require(_startTime < _endTime, "Invalid times");
    
        WL4.startTime = _startTime;
        WL4.endTime = _endTime;
        WL4.minPurchase = _minPurchase;
        WL4.maxPurchase = _maxPurchase;
        WL4.costPerToken = _costPerToken;
    }
}

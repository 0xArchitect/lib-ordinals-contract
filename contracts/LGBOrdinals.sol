// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC721AUpgradeable} from "./utils/ERC721AUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IOperatorFilterRegistry} from "./OpenseaRegistries/IOperatorFilterRegistry.sol";

contract LGBOrdinals is ERC721AUpgradeable, OwnableUpgradeable {
	
	string public baseURI;
	mapping(address => bool) public isController;
	
	modifier onlyController(address from) {
		require(
			isController[from] == true,
			"Only controller can call this function."
		);
		_;
	}
	
	function initialize(string memory name, string memory symbol) external initializer {
		__Ownable_init();
		__ERC721A_init(name,symbol);
	}
	
	function mint(address _to, uint256 _tokenAmount) external onlyController(msg.sender) {
		_mint(_to, _tokenAmount);
	}
	
	function burn(uint256 _tokenId) external onlyController(msg.sender) {
		_burn(_tokenId);
	}
	
	function setBaseURI(string memory baseURI_) external onlyOwner {
		baseURI = baseURI_;
	}
	
	function _baseURI() internal view override returns (string memory) {
		return baseURI;
	}
	
	function toggleController(address _controller) external onlyOwner {
		isController[_controller] = !isController[_controller];
	}
	
	function getTotalSupply() external view returns (uint256) {
		return totalSupply();
	}
	
	error OnlyOwner();
	error AlreadyRevoked();
	
	bool private _isOperatorFilterRegistryRevoked;
	
	modifier onlyAllowedOperator(address from) {
		// Check registry code length to facilitate testing in environments without a deployed registry.
		if (!_isOperatorFilterRegistryRevoked && address(operatorFilterRegistry).code.length > 0) {
			// Allow spending tokens from addresses with balance
			// Note that this still allows listings and marketplaces with escrow to transfer tokens if transferred
			// from an EOA.
			if (from == msg.sender) {
				_;
				return;
			}
			if (!operatorFilterRegistry.isOperatorAllowed(address(this), msg.sender)) {
				revert OperatorNotAllowed(msg.sender);
			}
		}
		_;
	}
	
	modifier onlyAllowedOperatorApproval(address operator) {
		// Check registry code length to facilitate testing in environments without a deployed registry.
		if (!_isOperatorFilterRegistryRevoked && address(operatorFilterRegistry).code.length > 0) {
			if (!operatorFilterRegistry.isOperatorAllowed(address(this), operator)) {
				revert OperatorNotAllowed(operator);
			}
		}
		_;
	}
	
	/**
	 * @notice Disable the isOperatorFilterRegistryRevoked flag. OnlyOwner.
     */
	function revokeOperatorFilterRegistry() external {
		if (msg.sender != owner()) {
			revert OnlyOwner();
		}
		if (_isOperatorFilterRegistryRevoked) {
			revert AlreadyRevoked();
		}
		_isOperatorFilterRegistryRevoked = true;
	}
	
	function isOperatorFilterRegistryRevoked() public view returns (bool) {
		return _isOperatorFilterRegistryRevoked;
	}
	
	error OperatorNotAllowed(address operator);
	
	IOperatorFilterRegistry constant operatorFilterRegistry =
	IOperatorFilterRegistry(0x000000000000AAeB6D7670E522A718067333cd4E);
	
	function __OperatorFilterer_init(address subscriptionOrRegistrantToCopy, bool subscribe)
	external onlyOwner
	
	{
		// If an inheriting token contract is deployed to a network without the registry deployed, the modifier
		// will not revert, but the contract will need to be registered with the registry once it is deployed in
		// order for the modifier to filter addresses.
		if (address(operatorFilterRegistry).code.length > 0) {
			if (!operatorFilterRegistry.isRegistered(address(this))) {
				if (subscribe) {
					operatorFilterRegistry.registerAndSubscribe(address(this), subscriptionOrRegistrantToCopy);
				} else {
					if (subscriptionOrRegistrantToCopy != address(0)) {
						operatorFilterRegistry.registerAndCopyEntries(address(this), subscriptionOrRegistrantToCopy);
					} else {
						operatorFilterRegistry.register(address(this));
					}
				}
			}
		}
	}
	
	function __OperatorFiltererRegisterAndSubscribe(address subscriptionOrRegistrantToCopy)
	internal
	{
		operatorFilterRegistry.registerAndSubscribe(address(this), subscriptionOrRegistrantToCopy);
	}
	
	function __SubscribeOperatorFilterRegistry(address subscriptionOrRegistrantToCopy) internal {
		operatorFilterRegistry.subscribe(address(this), subscriptionOrRegistrantToCopy);
	}
	
	function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
		super.setApprovalForAll(operator, approved);
	}
	
	function approve(address operator, uint256 tokenId) public override onlyAllowedOperatorApproval(operator) {
		super.approve(operator, tokenId);
	}
	
	function transferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {
		super.transferFrom(from, to, tokenId);
	}
	
	function safeTransferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {
		super.safeTransferFrom(from, to, tokenId);
	}
	
	function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
	public
	override
	onlyAllowedOperator(from)
	{
		super.safeTransferFrom(from, to, tokenId, data);
	}
}

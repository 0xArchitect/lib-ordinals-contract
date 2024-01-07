// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC721AUpgradeable} from "./utils/ERC721AUpgradeable.sol";

contract dummyLGBContract is ERC721AUpgradeable {
    
    function initialize(string memory name, string memory symbol) external  {
        __ERC721A_init(name,symbol);
    }
    
    function mintToken(address _to, uint256 _tokenAmount) external  {
        _mint(_to, _tokenAmount);
    }
}

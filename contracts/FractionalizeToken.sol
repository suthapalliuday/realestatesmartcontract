// SPDX-License-Identifier: UNT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";


contract FractionalizeToken is ERC20, Ownable, ERC721Holder {

    IERC721 public collection;
    uint256 public tokenId;
    uint256 public totalShares;
    bool public initialized = false;
    // mapping (address => uint256) purchasingApprovals;

    event purchaseShare (address purchaseBy, uint256 numberOfShares);

    constructor()
        ERC20("fractionalizeToken", "FPTK")
        // ERC20Permit("fractionalizeToken")
        
    {
        // require(!initialized,"Already Initialized");
        // require(_shares > 1, "Need minimum 2 shares to fractionalize");
        // collection = IERC721(_collection);
        // collection.transferFrom(msg.sender, address(this), _tokenId);
        // tokenId = _tokenId;
        // totalShares = _shares;
        // initialized = true;
        // _mint(msg.sender, _shares);
    }


    function callApprove(address owner, address spender, uint256 amount) external {
        _approve(owner, spender, amount);
    }

    function callincreaseAllowance(address spender,uint256 amountToIncrease) external {
        increaseAllowance(spender, amountToIncrease);
    }



    function initialize(address _collection, uint256 _tokenId, uint256 _shares, address _mintTo) external onlyOwner{
        // require(!initialized,"Already Initialized");
        require(_shares > 0, "Need minimum amount to fractionalize"); 
        collection = IERC721(_collection);
        collection.transferFrom(msg.sender, address(this), _tokenId);
        tokenId = _tokenId;
        totalShares = _shares;
        initialized = true;
        _mint(_mintTo, _shares);
    }
}


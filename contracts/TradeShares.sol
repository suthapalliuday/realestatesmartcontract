// SPDX-License-Identifier: UNT
pragma solidity ^0.8.4;
import './FractionalizeToken.sol';
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TradeShares is Ownable{

    address tokenAddress;
    FractionalizeToken sharesTokens;
    uint256 public tokenPrice;
    uint256 public totalSharesSold;
    uint256 public totalSharesAvailableForBuying;


    // uint256 totalSharesAvailableForBuyingFromUsers;
    //Its an mapping variable used to store the details of users who wants to sell their shares,
    // the addresss data type s to store the address of the selling, 
    // first value in array represents the number of shares user wants to sell
    // second value in array represents the price of each share the user is proposing to sell the shares.
    mapping(address => uint256[] ) public dataAvailableForSelling;
    address[] public forIterating;
    mapping(address => bool) public presenceOfAddress;
    
    
    constructor(address _shareTokensAddress) {
        tokenAddress = _shareTokensAddress;
        sharesTokens = FractionalizeToken(_shareTokensAddress);
        
    }

    //Use this fucntion when you want to access the totalshares for an property
    function totalShares() view public returns (uint256 _totalShares) {
        return sharesTokens.balanceOf(address(this));
    }

    //Only owner can put the shares to sale initially.
    function putForSaleByAdmin(uint256 numberOfShares, uint256 priceOfEachShare) external onlyOwner{
        uint256 _totalShares = totalShares();
        require(numberOfShares <= _totalShares, "Cannot sell more than available shares");
        require(priceOfEachShare > 0 , "Price of the single share cannot be negative or zero value");
        totalSharesAvailableForBuying = totalSharesAvailableForBuying + numberOfShares;
        tokenPrice = priceOfEachShare;
    }

    //Used to purchase the tokens from the vendor/owner by users
    function purchaseSharesFromVendor() external payable returns (uint256 sharesBought){
        require(msg.sender != address(0) && msg.sender != address(this));
        require(msg.value >= tokenPrice,"Send ETH to buy shares");
        uint256 numberOfSharesToBuy = msg.value / tokenPrice;
        require(totalSharesAvailableForBuying >= numberOfSharesToBuy, "Property has insufficient shares");
        (bool sent) = sharesTokens.transfer(msg.sender,numberOfSharesToBuy);
        require(sent, "Failed to transfer token to user");
        totalSharesAvailableForBuying = totalSharesAvailableForBuying - numberOfSharesToBuy;
        totalSharesSold = totalSharesSold + numberOfSharesToBuy;
        return numberOfSharesToBuy;
    }


    /**
    * @notice Allow the owner of the contract to withdraw ETH
    */
    function withdraw() public onlyOwner{
        uint256 ownerBalance = address(this).balance;
        require(ownerBalance > 0, "Owner has no balance to withdraw");

        (bool sent,) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send user balance back to the owner");
    }

    
    //When user wants to sell the shares he has, he can try selling to the vendor, 
    // if the vendor has enough funds he can take the shares and give him the ether.
    function sellTokenToVendor (uint256 numberOfShares) external {
        uint256 userShares = sharesTokens.balanceOf((msg.sender));
        require(userShares >= numberOfShares,"You dont have those many shares to sell");
        totalSharesAvailableForBuying = totalSharesAvailableForBuying + numberOfShares;
        uint256 sellPriceInEth = numberOfShares * tokenPrice;
        uint256 tradeBalance = address(this).balance;
        require(tradeBalance >= sellPriceInEth,"Trade vendor has insuffient funds");
        (bool sent) = sharesTokens.transfer(address(this),numberOfShares);
        require(sent, "Failed to transfer tokens from user to vendor");
        (sent,) = msg.sender.call{value: sellPriceInEth}("");
        require(sent, "Failed to send ethe to the user");
        totalSharesSold = totalSharesSold - numberOfShares;
    }

    // When the user wants to sell his shares but vendor has no funds to buy it, 
    // then he can sell it to the other users by using this function
     function putForSale(uint256 numberOfShares,uint256 _userPrice) external {
         require(numberOfShares > 0,"You need to sell atleast 1 share");
        uint256 numberOfSharesUserhas = sharesTokens.balanceOf(msg.sender);
        require(numberOfShares <= numberOfSharesUserhas, "You have insufficient shares to put for sell");
        if(presenceOfAddress[msg.sender]==true){
            uint256 numberOfSharesUserAlreadyPutForSale = dataAvailableForSelling[msg.sender][0];
            require(numberOfShares <= numberOfSharesUserhas - numberOfSharesUserAlreadyPutForSale, "You have already kept some shares for sale, please check the balance and sell only available.");
            sharesTokens.callincreaseAllowance(address(this), numberOfShares);
            dataAvailableForSelling[msg.sender].push(dataAvailableForSelling[msg.sender][0]+numberOfShares);
            dataAvailableForSelling[msg.sender].push(_userPrice);
            sharesTokens.increaseAllowance(address(this), numberOfShares);
        }
        else{
            // (bool approved) = sharesTokens.approve(address(this), 100);
            sharesTokens.callApprove(msg.sender, address(this), numberOfShares);
            // require(approved, 'Failed to approve the user ${approved}');
            dataAvailableForSelling[msg.sender].push(numberOfShares);
            dataAvailableForSelling[msg.sender].push(_userPrice);
            presenceOfAddress[msg.sender] = true;
            forIterating.push(msg.sender);
        }
        // for(uint256 i=0; i<forIterating.length; i++){
        //     if(forIterating[i]==msg.sender){
        //         uint256[][] memory itemsForSale = dataAvailableForSelling[msg.sender];
        //         uint256 totalSharesPutForSale = 0;
        //         for(uint256 j = 0; j<itemsForSale.length;j++){
        //             totalSharesPutForSale = totalSharesPutForSale+dataAvailableForSelling[msg.sender][j][0];
        //         }
        //         require(numberOfShares <= numberOfSharesUserhas - totalSharesPutForSale,"You have already kept some shares for sale, please check the balance and sell only available.");
        //     }
        // }
        // dataAvailableForSelling[msg.sender].push(dataAvailableForSelling[msg.sender][0]+numberOfShares);
        // dataAvailableForSelling[msg.sender].push(_userPrice);
        // presenceOfAddress[msg.sender] = true;
        // dataToShowPublicAvailableShares.push(publicAvailableShares(numberOfShares,_userPrice));
    }

    function getAvailableShares(address sellerAddress) view public returns (uint256, uint256){
        return (dataAvailableForSelling[sellerAddress][0], dataAvailableForSelling[sellerAddress][1]);
    }

    function getAllAvailableSharesFromPublic() view public returns (address[] memory, uint256[] memory, uint256[] memory) {
        address[] memory returnAddress;
        uint256[] memory returnSharesAvailable;
        uint256[] memory returnPriceForEachShare;
        for(uint256 i= 0;i<forIterating.length;i++){
            address addressinloop = forIterating[i];
            returnAddress[i] = addressinloop;
            returnSharesAvailable[i] = dataAvailableForSelling[addressinloop][0];
            returnPriceForEachShare[i] = dataAvailableForSelling[addressinloop][1];
        }
        return (returnAddress, returnSharesAvailable, returnPriceForEachShare);
    }





    function buyFromPublic(address sellerAddress, uint256 numberOfSharesWantToBuy) external payable returns (uint256 sharesBought){
        require(presenceOfAddress[sellerAddress]==true,"The User has not posted any shares for sell");
        require(dataAvailableForSelling[sellerAddress][0] >= numberOfSharesWantToBuy,"The seller doesn't have enough shares to sell");
        uint256 priceToBuyRequiredShares = numberOfSharesWantToBuy * dataAvailableForSelling[sellerAddress][1];
        require(priceToBuyRequiredShares == msg.value,"Please send the exact amount of ether to buy the shares");
        (bool sentToContract) = sharesTokens.transferFrom(sellerAddress, msg.sender, numberOfSharesWantToBuy);
        require(sentToContract, "Token Transfer failed from seller to buyer");
        (bool sentEther, ) = sellerAddress.call{value: priceToBuyRequiredShares}("");
        require(sentEther,"Failed to transfer ether from buyer to seller");
        return numberOfSharesWantToBuy;
    }


}


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "../../lib/chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "./LibDiamond.sol";

library LibTeller {

    event ItemforSale(uint _itemId, uint _priceinETH);
    event ItemSold(uint _itemId, uint _priceinETH, uint _priceinUSD);

    struct TellerStorage {
        uint totalItemsforSale;
        mapping(uint => Item) itemIdtoItem;
        mapping(address => address) tokenAddrtoAgg;
    }

    struct Item {
        address owner;
        uint itemId;
        uint priceinEth;
        uint priceinUSD;
    }


    struct Reciept {
        address owner;
        uint itemId;
        uint priceinEth;
        uint priceinUSD;
        uint timeBought;
    }

    bytes32 constant TELLER_STORAGE_POSITION = keccak256("diamond.storage.diamond.tellerstorage");


    function tellerStorage() internal pure returns (TellerStorage storage ts){
        bytes32 position = TELLER_STORAGE_POSITION;
        assembly {
            ts.slot := position
        }
    }

    function buyItem(uint _itemId, uint _amount, address _tokenAddress) internal returns (Reciept memory _reciept) {
        TellerStorage storage ts = tellerStorage();
        uint _itemPrice = getItemPriceinUSD(_itemId);
        uint _tokenPriceinUSD = getTokenPriceinUSD(_tokenAddress);
        uint _buyAmount = _amount * _tokenPriceinUSD;
        if (_buyAmount < _itemPrice) revert("Not up to price for item");
        Item memory _item = ts.itemIdtoItem[_itemId];
        address _itemOwner = _item.owner; 
        ERC20(_tokenAddress).transferFrom(msg.sender, _itemOwner, _amount);
        _reciept = Reciept(msg.sender, _itemId, _item.priceinEth, _itemPrice,block.timestamp);
        emit ItemSold(_itemId, _item.priceinEth, _itemPrice);
    }


    function getTotalItems() internal view returns (uint _totalItems) {
        TellerStorage storage ts = tellerStorage();
        _totalItems = ts.totalItemsforSale;
    }

    function setAggregatorAddr(address _tokenAddr, address _aggAddr) internal {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        if (msg.sender != ds.contractOwner) revert ("Only owner can call this function");
        TellerStorage storage ts = tellerStorage();
        ts.tokenAddrtoAgg[_tokenAddr] = _aggAddr;
    }

    function getAggregatorAddr(address _tokenAddr) internal view returns (address _aggAddr){
        TellerStorage storage ts = tellerStorage();
        _aggAddr = ts.tokenAddrtoAgg[_tokenAddr];
    }


    function getItemforSale(uint _itemId) internal view returns (Item memory _itemforSale) {
        TellerStorage storage ts = tellerStorage();
        _itemforSale = ts.itemIdtoItem[_itemId];
    }

    function placeItemforSale(uint _priceinETH) internal {
        TellerStorage storage ts = tellerStorage();
        ts.totalItemsforSale ++;
        Item storage _item = ts.itemIdtoItem[ts.totalItemsforSale];
        _item.itemId = ts.totalItemsforSale;
        _item.priceinEth = _priceinETH;
        _item.owner = msg.sender;
        emit ItemforSale(_item.itemId, _item.priceinEth);
    }

    function getTokenPriceinUSD(address _tokenAddress) internal view returns(uint _tokenUSDPrice) {
        TellerStorage storage ts = tellerStorage();
        address _tokenUSDAgg = ts.tokenAddrtoAgg[_tokenAddress];
        address _USDTUSDAgg = ts.tokenAddrtoAgg[0xdAC17F958D2ee523a2206206994597C13D831ec7];
        require(_tokenUSDAgg != address(0), "Token Aggregator not set");
        (, int tokenUSDPrice,,,) = AggregatorV3Interface(_tokenUSDAgg).latestRoundData();
        (, int USDTUSDPrice,,,) = AggregatorV3Interface(_USDTUSDAgg).latestRoundData();
        _tokenUSDPrice = uint(tokenUSDPrice/USDTUSDPrice);
    }

    function getItemPriceinUSD(uint _itemId) internal view returns(uint _price) {
        TellerStorage storage ts = tellerStorage();
        address _aggAddr = ts.tokenAddrtoAgg[0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2];
        (, int ETHUSDPrice,,,) = AggregatorV3Interface(_aggAddr).latestRoundData();
        _price = (ts.itemIdtoItem[_itemId].priceinEth * uint(ETHUSDPrice))/1e8;
    }
}
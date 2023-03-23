// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "../../lib/chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

library LibTeller {

    address constant ETHUSDDataFeed = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address constant USDTETHDataFeed = 0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46;
    address constant USDTUSDDataFeed = 0x3E7d1eAB13ad0104d2750B8863b489D65364e32D;
    address constant USDTTokenAddress = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    event ItemforSale(uint _itemId, uint _priceinETH);
    event ItemSold(uint _itemId, uint _priceinETH, uint _priceinUSD);

    struct TellerStorage {
        uint totalItemsforSale;
        mapping(uint => Item) itemIdtoItem;
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

    function getTotalItems() internal view returns (uint _totalItems) {
        TellerStorage storage ts = tellerStorage();
        _totalItems = ts.totalItemsforSale;
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

    function getItemPriceinUSD(uint _itemId) internal view returns(uint _price) {
        TellerStorage storage ts = tellerStorage();
        (, int ETHUSDPrice,,,) = AggregatorV3Interface(ETHUSDDataFeed).latestRoundData();
        _price = ts.itemIdtoItem[_itemId].priceinEth * uint(ETHUSDPrice);
    }

    function buyItem(uint _itemId, uint _amount) internal returns (Reciept memory _reciept) {
        TellerStorage storage ts = tellerStorage();
        uint8 decimal = ERC20(USDTTokenAddress).decimals();
        uint _itemPrice = getItemPriceinUSD(_itemId);
        uint _buyAmount = _amount * (1 * 10**decimal);
        if (_buyAmount < _itemPrice) revert("Not up to price for item");
        Item memory _item = ts.itemIdtoItem[_itemId];
        address _itemOwner = _item.owner;
        IERC20(USDTTokenAddress).transferFrom(msg.sender, _itemOwner, _itemPrice);
        _reciept = Reciept(msg.sender, _itemId, _item.priceinEth, _itemPrice,block.timestamp);
        emit ItemSold(_itemId, _item.priceinEth, _itemPrice);
    }
}
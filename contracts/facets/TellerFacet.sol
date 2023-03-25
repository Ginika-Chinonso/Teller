// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "../libraries/LibTeller.sol";

contract TellerFacet {
    function getTotalItems() external view returns (uint _totalItems) {
        _totalItems = LibTeller.getTotalItems();
    }

    function placeItemforSale(uint _priceinETH) external {
        LibTeller.placeItemforSale(_priceinETH);
    }

    function getItemPriceinUSD(uint _itemId) external view returns(uint _price) {
        _price = LibTeller.getItemPriceinUSD(_itemId);
    }

    function buyItem(uint _itemId, uint _amount, address _tokenAddr) external returns (LibTeller.Reciept memory _reciept) {
        _reciept = LibTeller.buyItem(_itemId, _amount, _tokenAddr);
    }

    function getItemforSale(uint _itemId) external view returns (LibTeller.Item memory _itemforSale) {
        _itemforSale = LibTeller.getItemforSale(_itemId);
    }

    function setAggregatorAddr(address _tokenAddr, address _aggAddr) external {
        LibTeller.setAggregatorAddr(_tokenAddr, _aggAddr);
    }

    function getAggregatorAddr(address _tokenAddr) external view returns (address _aggAddr){
        _aggAddr = LibTeller.getAggregatorAddr(_tokenAddr);
    }

    function getTokenPriceinUSD(address _tokenAddress) external view returns(uint tokenUSDPrice) {
        tokenUSDPrice = LibTeller.getTokenPriceinUSD(_tokenAddress);
    }
}
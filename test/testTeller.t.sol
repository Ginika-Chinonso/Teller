// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./deployDiamond.t.sol";
import "../contracts/facets/TellerFacet.sol";
import "../contracts/Diamond.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";


contract TellerTest is DiamondDeployer {

    function testTeller() public {

        test_placeItemforSale();

        // call Tellet facet
        TellerFacet(address(diamond)).getTotalItems();
        TellerFacet(address(diamond)).getItemforSale(1);
        TellerFacet(address(diamond)).getItemPriceinUSD(1);
        TellerFacet(address(diamond)).getTokenPriceinUSD(WETH);
        vm.startPrank(0xE174c389249b0E3a4eC84d2A5667Aa4920CB77DE);
        ERC20(YFI).approve(address(diamond), 10 ether);
        TellerFacet(address(diamond)).buyItem(1, 1, YFI);
        vm.stopPrank();
    }

    function test_placeItemforSale() public {
        testDeployDiamond();
        setAggregatorAddress();
        TellerFacet(address(diamond)).placeItemforSale(2);
    }

    function test_getItemforSale() public {
        test_placeItemforSale();
        TellerFacet(address(diamond)).getItemforSale(1);
    }

    function test_getItemPriceinUSD() public {
        test_getItemforSale();
        TellerFacet(address(diamond)).getItemPriceinUSD(1);
    }

    function test_getTokenPriceinUSD() public {
        testDeployDiamond();
        setAggregatorAddress();
        TellerFacet(address(diamond)).getTokenPriceinUSD(YFI);
    }

    function test_buyItemforSale() public {
        test_placeItemforSale();
        vm.startPrank(0xE174c389249b0E3a4eC84d2A5667Aa4920CB77DE);
        ERC20(YFI).approve(address(diamond), 10 ether);
        TellerFacet(address(diamond)).buyItem(1, 1, YFI);
        vm.stopPrank();
    }

    function setAggregatorAddress() public {
        TellerFacet(address(diamond)).setAggregatorAddr(USDT, USDTUSD);
        TellerFacet(address(diamond)).setAggregatorAddr(YFI, YFIUSD);
        TellerFacet(address(diamond)).setAggregatorAddr(WETH, ETHUSD);
    }
}
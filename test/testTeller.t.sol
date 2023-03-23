// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "./deployDiamond.t.sol";
import "../contracts/facets/TellerFacet.sol";
import "../contracts/Diamond.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";


contract TellerTest is DiamondDeployer {

    function testTeller() public {

        testDeployDiamond();

        // call Tellet facet
        TellerFacet(address(diamond)).getTotalItems();
        TellerFacet(address(diamond)).placeItemforSale(1);
        TellerFacet(address(diamond)).getItemforSale(1);
        TellerFacet(address(diamond)).getItemPriceinUSD(1);
        vm.startPrank(0x0162Cd2BA40E23378Bf0FD41f919E1be075f025F);
        ERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7).approve(address(diamond), 2000 ether);
        TellerFacet(address(diamond)).buyItem(1, 2000);
        vm.stopPrank();
    }
}
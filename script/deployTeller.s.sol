// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
// import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/facets/TellerFacet.sol";
import "../lib/forge-std/src/Script.sol";
// import "../contracts/Diamond.sol";

contract deployTeller is Script, IDiamondCut {

    // Diamond address = 0x8b696741eff7bcbea3ee21f8583c9f8c9dbcea69
    // Diamond cut address = 0xe764aab3e83a805b9be9d44e9e5a2156a6bafdb0
    // Diamond loupe address = 0x2cc3fff5b5acde26270b5399ac342c16fbccdf3c


    //contract types of facets to be deployed
    address diamond = 0x8B696741eff7bcBEA3eE21f8583C9f8c9dbCea69;
    address dCutFacet = 0xe764aab3E83A805b9bE9D44E9e5a2156A6bAFDB0;
    // DiamondLoupeFacet dLoupe;
    // address contractOwner = 0xe97a4C739b738e57539566547c3757ecb1bA223a;
    OwnershipFacet ownerF;
    TellerFacet tellerF;


    function run() external {

        uint256 deployer = vm.envUint("ACC1_PRIVATE_KEY");

        vm.startBroadcast(deployer);

        //deploy facets
        // dCutFacet = new DiamondCutFacet();
        // diamond = new Diamond(contractOwner, address(dCutFacet));
        // dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        tellerF = new TellerFacet();

        //upgrade diamond with facets

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](2);

        // cut[0] = (
        //     FacetCut({
        //         facetAddress: address(dLoupe),
        //         action: FacetCutAction.Add,
        //         functionSelectors: generateSelectors("DiamondLoupeFacet")
        //     })
        // );

        cut[0] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(tellerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("TellerFacet")
            })
        );

        //upgrade diamond
        IDiamondCut(diamond).diamondCut(cut, address(0x0), "");

        //call a function
        DiamondLoupeFacet(diamond).facetAddresses();

        vm.stopBroadcast();
    }

    function generateSelectors(string memory _facetName)
        internal
        returns (bytes4[] memory selectors)
    {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}

// SPDX-License-Identifier: MIT

// Here’s an example of how we can create smart contracts in Solidity for a EnviroTrack+:
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract EcoTokenNFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct EcoToken {
        uint256 id;
        string projectDescription;
        string emissionReductionMethod;
        string validationDetails;
    }

    mapping(uint256 => EcoToken) private _ecoTokens;

    constructor() ERC721("EcoTokenNFT", "ETNFT") {}

    function createEcoToken(
        string memory projectDescription,
        string memory emissionReductionMethod,
        string memory validationDetails
    ) external returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _safeMint(msg.sender, newTokenId);

        EcoToken memory newEcoToken = EcoToken({
            id: newTokenId,
            projectDescription: projectDescription,
            emissionReductionMethod: emissionReductionMethod,
            validationDetails: validationDetails
        });

        _ecoTokens[newTokenId] = newEcoToken;
        return newTokenId;
    }

    function getEcoToken(uint256 tokenId)
        external
        view
        returns (
            uint256,
            string memory,
            string memory,
            string memory
        )
    {
        EcoToken memory ecoToken = _ecoTokens[tokenId];
        return (
            ecoToken.id,
            ecoToken.projectDescription,
            ecoToken.emissionReductionMethod,
            ecoToken.validationDetails
        );
    }
}

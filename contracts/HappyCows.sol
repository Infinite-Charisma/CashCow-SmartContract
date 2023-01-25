// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./interfaces/IMilkToken.sol";

contract HappyCows is Ownable, ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address private ownerAddr;
    uint256 public blockNumber;
    uint256 public price;
    string public baseURI;

    IMilkToken tokenMilk;

    constructor(
        uint256 _blockNumber,
        IMilkToken _tokenMilk,
        string memory _baseURI,
        address _ownerAddr
    ) ERC721("Happy Cows", "HCN") {
        blockNumber = _blockNumber;
        tokenMilk = _tokenMilk;
        baseURI = _baseURI;
        price = 10000;
        ownerAddr = _ownerAddr;
    }

    function buyBlindBox(string memory _metaHash, address contractAddress)
        public
        returns (uint256)
    {
        require(msg.sender != address(0), "Mint Address can't be zero address");
        require(block.number >= blockNumber, "Blindbox Sale is not started");
        require(_tokenIds.current() <= 1000, "All NFTs are sold");
        require(
            tokenMilk.balanceOf(msg.sender) >= price * 10**18,
            "Balance of Milk token is not enought to buy BlindBox"
        );

        tokenMilk.transferFrom(msg.sender, ownerAddr, price * 10**18);

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, _metaHash);

        if (!isApprovedForAll(msg.sender, contractAddress)) {
            setApprovalForAll(contractAddress, true);
        }
        return newItemId;
    }

    function setOwnerAddr(address _ownerAddr) public onlyOwner {
        require(
            _ownerAddr != address(0),
            "Owner Address can't be zero address"
        );
        ownerAddr = _ownerAddr;
    }

    function getOwnerAddr() public view onlyOwner returns (address) {
        return ownerAddr;
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function setBlockNumber(uint256 _blockNumber) public onlyOwner {
        blockNumber = _blockNumber;
    }

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

    function transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) external onlyOwner {
        transferFrom(_from, _to, _tokenId);
    }

    function getBlockNumber() external view returns (uint256) {
        return block.number;
    }

    function totalSupply() external view returns (uint256) {
        return (_tokenIds.current());
    }

    function getTokenFullURI(uint256 tokenId)
        external
        view
        returns (string memory)
    {
        string memory _baseURI = baseURI;
        string memory _tokenURI = tokenURI(tokenId);

        return string(abi.encodePacked(_baseURI, _tokenURI));
    }

    function getBaseURI() external view returns (string memory) {
        string memory _baseURI = baseURI;
        return _baseURI;
    }

    function fetchMyNfts() external view returns (uint256[] memory) {
        uint256 tokenCount = 0;
        uint256 _totalSupply = _tokenIds.current();
        for (uint256 i = 0; i < _totalSupply; i++) {
            if (ownerOf(i + 1) == msg.sender) {
                tokenCount++;
            }
        }

        uint256[] memory tokenIds = new uint256[](tokenCount);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < _totalSupply; i++) {
            if (ownerOf(i + 1) == msg.sender) {
                tokenIds[currentIndex] = i + 1;
                currentIndex++;
            }
        }

        return tokenIds;
    }
}

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./BridgeWatersToken.sol";

contract BridgeWatersNFTPlatform is IERC721Receiver {
    using SafeMath for uint256;
    struct NFTListing {
        address owner;
        address nftAddress;
        uint256 tokenId;
        address FractionalToken;
        uint256 totalShares;
        uint256 pricePerShare;
    }

    address public owner;
    uint256 public platformFee;
    mapping(address => NFTListing[]) private nFTListings;
    mapping(address => mapping(uint256 => uint256)) public nftListingIndex;

    event NFTListed(
        address indexed owner,
        address indexed nftContract,
        uint256 tokenId
    );
    event SharesPurchased(
        address indexed buyer,
        address indexed nftContract,
        uint256 tokenId,
        uint256 sharesPurchased
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    error TotalSharesMustBeGreaterThanZero();
    error PricePerShareMustBeGreaterThanZero();
    error NFTIsAlreadyListed();
    error NotNFTOwner();
    error NFTListingDoesNotExist();
    error InvalidNumberOfSharesToPurchase();
    error InsufficientFundsSent();
    error InsufficientSharesToTransfer();

    constructor() {
        owner = msg.sender;
    }

    function listNFT(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _totalShares,
        uint256 _pricePerShare
    ) external {
        IERC721 nftContract = IERC721(_nftAddress);

        if (_totalShares < 0) revert TotalSharesMustBeGreaterThanZero();

        if (_pricePerShare < 0) revert PricePerShareMustBeGreaterThanZero();

        nftListingIndex[_nftAddress][_tokenId] = nFTListings[msg.sender].length;

        BridgeWatersToken fractionalToken = new BridgeWatersToken();

        if (listing.owner == address(0)) revert NFTIsAlreadyListed();

        if (nftContract.ownerOf(_tokenId) != msg.sender) revert NotNFTOwner();

        nFTListings[_nftAddress].push(
            NFTListing(
                msg.sender,
                _nftAddress,
                _tokenId,
                _pricePerShare,
                _totalShares
            )
        );

        nftContract.safeTransferFrom(msg.sender, address(this), _tokenId);

        emit NFTListed(msg.sender, _nftAddress, _tokenId);
    }

    function purchaseNFT(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _sharesToPurchase
    ) external payable {
        NFTListing storage listing = nftListingIndex[_nftAddress][_tokenId];

        if (listing.owner == address(0)) revert NFTListingDoesNotExist();

        if (_sharesToPurchase < 0 && _sharesToPurchase >= listing.totalShares)
            revert InvalidNumberOfSharesToPurchase();

        if (msg.value <= _sharesToPurchase.mul(listing.pricePerShare))
            revert InsufficientFundsSent();

        uint256 _nftListingIndex = nftListingIndex[_nftAddress][_tokenId];

        BridgeWatersToken fractionalToken = new BridgeWatersToken();

        uint256 _platformFee = msg.value.mul(platformFee).div(1000);
        uint256 purchaseValue = msg.value.sub(platformFee);

        listing.totalShares = listing.totalShares.sub(_sharesToPurchase);

        // Transfer fractional tokens instead of the entire NFT
        fractionalToken.transfer(msg.sender, _sharesToPurchase);

        emit NFTListed(msg.sender, _nftAddress, _tokenId);
    }

    function transferNFT(
        address _nftContract,
        uint256 _tokenId,
        address _to,
        uint256 _sharesToTransfer
    ) external {
        NFTListing storage listing = nftListingIndex[_nftContract][_tokenId];
        if (listing.owner == address(0)) revert NFTListingDoesNotExist();

        listing.fractionalToken.transferFrom(
            msg.sender,
            _to,
            _sharesToTransfer
        );
    }
}

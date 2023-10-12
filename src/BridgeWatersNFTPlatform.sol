pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BridgeWatersNFTPlatform {
    using SafeMath for uint256;

    address public owner;
    uint256 public platformFee;
    mapping(address => mapping(uint256 => NFTListing)) public nftListings;

    struct NFTListing {
        address owner;
        address nftContract;
        uint256 tokenId;
        ERC20 fractionalToken;
        uint256 totalShares;
        uint256 pricePerShare;
    }

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

    function listNFT(
        address _nftContract,
        uint256 _tokenId,
        uint256 _totalShares,
        uint256 _pricePerShare
    ) external {
        if (_totalShares < 0) revert TotalSharesMustBeGreaterThanZero();

        if (_pricePerShare < 0) revert PricePerShareMustBeGreaterThanZero();

        NFTListing storage listing = nftListings[_nftContract][_tokenId];

        if (listing.owner == address(0)) revert NFTIsAlreadyListed();

        ERC721 nft = ERC721(_nftContract);

        if (nft.ownerOf(_tokenId) != msg.sender) revert NotNFTOwner();

        listing.owner = msg.sender;
        listing.nftContract = _nftContract;
        listing.tokenId = _tokenId;
        listing.totalShares = _totalShares;
        listing.pricePerShare = _pricePerShare;

        nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        emit NFTListed(msg.sender, _nftContract, _tokenId);
    }

    function purchaseNFT(
        address _nftContract,
        uint256 _tokenId,
        uint256 _sharesToPurchase
    ) external payable {
        NFTListing storage listing = nftListings[_nftContract][_tokenId];

        if (listing.owner == address(0)) revert NFTListingDoesNotExist();

        if (_sharesToPurchase < 0 && _sharesToPurchase >= listing.totalShares)
            revert InvalidNumberOfSharesToPurchase();

        if (msg.value <= _sharesToPurchase.mul(listing.pricePerShare))
            revert InsufficientFundsSent();

        uint256 _platformFee = msg.value.mul(platformFee).div(1000);
        uint256 purchaseValue = msg.value.sub(platformFee);

        listing.totalShares = listing.totalShares.sub(_sharesToPurchase);

        // Transfer fractional tokens instead of the entire NFT
        listing.fractionalToken.transfer(msg.sender, _sharesToPurchase);

        emit NFTListed(msg.sender, _nftContract, _tokenId);
    }

    function transferNFT(
        address _nftContract,
        uint256 _tokenId,
        address _to,
        uint256 _sharesToTransfer
    ) external {
        NFTListing storage listing = nftListings[_nftContract][_tokenId];
        if (listing.owner == address(0)) revert NFTListingDoesNotExist();

        listing.fractionalToken.transferFrom(
            msg.sender,
            _to,
            _sharesToTransfer
        );
    }
}

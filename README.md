# Fractional NFT Marketplace

## description:

This is the smart contracts for a platform that enables users to tokenize and list their NFT assets, allowing other users to purchase fractions (shares) of these NFTs. The platform is built on Ethereum and uses ERC721 standard for NFTs and ERC20 for fractional ownership.

### Features

- Users can tokenize and list their NFT assets on the platform
- Other users can purchase fractions of these NFTs
- The purchase amount is distributed between the user and the platform, with the platform receiving 0.1% of all amount accumulated from sales
- Fractional ownership can be transferred to another user
- Payments are made in ether

### Functions

- listNFT(): Allows users to tokenize and list their NFT assets.

- purchaseNFT(): Allows users to purchase fractions of listed NFTs.

  ### How It Works

- Tokenizing and Listing NFTs: Users can tokenize their assets and list them on the platform using the listNFT() function. The function mints a new NFT based on the ERC721 standard and sets a price for each token.

- Purchasing Fractions of NFTs: Other users can purchase fractions of these NFTs using the purchaseNFT() function. The function checks if the NFT is for sale and if the sent value matches the price. It then transfers 0.1% of the purchase amount to the platform and the remaining amount to the user. A new ERC20 token is minted to represent the fractional ownership of the NFT.

- Transferring Fractional Ownership: The transferFraction() function allows users to transfer their fractional ownership of an NFT to another user.

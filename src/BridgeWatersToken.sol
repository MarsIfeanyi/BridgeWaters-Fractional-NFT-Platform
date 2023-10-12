// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BridgeWatersToken is ERC20 {
    address owner;

    constructor() ERC20("BridgeWaters Token", "BWT") {
        owner = msg.sender;
        _mint(msg.sender, 1_000_000e18);
    }

    error NotOwner();

    function burn(address _from) public {
        if (msg.sender != owner) revert NotOwner();

        _burn(_from, balanceOf(_from));
    }
}

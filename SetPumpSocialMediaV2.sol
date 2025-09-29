// SPDX-License-Identifier: UNLICENSE

/*
   ___ _                    ______ _                            
  |_  (_)                   |  ___(_)                           
    | |_ _ __   __ _  ___   | |_   _ _ __   __ _ _ __   ___ ___ 
    | | | '_ \ / _` |/ _ \  |  _| | | '_ \ / _` | '_ \ / __/ _ \
/\__/ / | | | | (_| | (_) | | |   | | | | | (_| | | | | (_|  __/
\____/|_|_| |_|\__, |\___/  \_|   |_|_| |_|\__,_|_| |_|\___\___|
                __/ |                                           
               |___/                                            
WEBSITE: https://jingo.finance
TWITTER: https://x.com/JingoFinance
TELEGRAM https://t.me/JingoFinance

*/

pragma solidity ^0.8.0;

interface IPumpInterface {
    function creator(address user) external view returns (address);
}

// Struct to store social media links
struct Social {
    string fbURL;
    string xURL;
    string telegramURL;
    string websiteURL;
}

contract SetPumpSocialMediaV2 {
    address public bkgaLiteFactoryAddr;
    address public bkgaProFactoryAddr;
    address public owner;

    // Mapping from LP address to its social media links
    mapping(address => Social) public socials;

    // Track suspended creators (they cannot modify any LP)
    mapping(address => bool) public isCreatorSuspended;

    // Track frozen LPs (social media cannot be updated)
    mapping(address => bool) public isLpFrozen;

    constructor(address _bkgaProFactoryAddr,address _bkgaLiteFactoryAddr) {
        bkgaLiteFactoryAddr = _bkgaLiteFactoryAddr;
        bkgaProFactoryAddr = _bkgaProFactoryAddr;
        owner = msg.sender;
    }

    // Modifier to restrict access to contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // Allow the LP creator to update social media if not suspended or frozen
    function setSocialMedia(
        address _lpAddr,
        string memory fb,
        string memory x,
        string memory telegram,
        string memory website
    ) external {
        address creatorAddr = IPumpInterface(bkgaLiteFactoryAddr).creator(_lpAddr);
        if(creatorAddr == address(0)){
            creatorAddr = IPumpInterface(bkgaProFactoryAddr).creator(_lpAddr);
        }

        require(msg.sender == creatorAddr, "You're not the creator");
        require(!isCreatorSuspended[creatorAddr], "Creator is suspended");
        require(!isLpFrozen[_lpAddr], "This LP is frozen, can't change socials media");

        socials[_lpAddr] = Social(fb, x, telegram, website);
    }

    function getCreator(address _lpAddr) external view returns (address) {
        address creatorAddr = IPumpInterface(bkgaLiteFactoryAddr).creator(_lpAddr);
        if(creatorAddr == address(0)){
            creatorAddr = IPumpInterface(bkgaProFactoryAddr).creator(_lpAddr);
        }
        return creatorAddr;
    }

    // Admin override to update LP social media, bypassing restrictions
    function setSocialMediaByAdmin(
        address _lpAddr,
        string memory fb,
        string memory x,
        string memory telegram,
        string memory website
    ) external onlyOwner {
        socials[_lpAddr] = Social(fb, x, telegram, website);
    }

    // Permanently suspend a creator address
    function suspendCreator(address creatorAddr) external onlyOwner {
        require(creatorAddr != address(0), "Invalid creator address");
        isCreatorSuspended[creatorAddr] = true;
    }

    // Freeze a specific LP from being modified
    function freezeLp(address lpAddr) external onlyOwner {
        require(lpAddr != address(0), "Invalid LP address");
        isLpFrozen[lpAddr] = true;
    }

    // Unfreeze a specific LP
    function unfreezeLp(address lpAddr) external onlyOwner {
        require(lpAddr != address(0), "Invalid LP address");
        isLpFrozen[lpAddr] = false;
    }

    // Remove suspension from a creator
    function unsuspendCreator(address creatorAddr) external onlyOwner {
        require(creatorAddr != address(0), "Invalid creator address");
        isCreatorSuspended[creatorAddr] = false;
    }

  
}
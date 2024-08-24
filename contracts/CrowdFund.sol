// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

contract CrowdFund {

    struct Campaign {
        string title;
        string description;
        address payable benefactor;
        uint goal;
        uint deadline;
        uint amountRaised;
        bool ended;
    }

    address public owner;
    uint256 public campaignId;

    mapping(uint256 => Campaign) public campaigns;

    bool internal locked;

    event CampaignCreated(string title, uint256 goal, uint256 deadline);
    event DonationReceived(uint campaign, address donor, uint256 amount);
    event CampaignEnded(string message, uint when, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    constructor() {
        owner = msg.sender;
    }

    function createCampaign(
        string memory _title, 
        string memory _description,
        address payable _benefactor,
        uint256 _goal,
        uint256 _deadline) external {

            require(_goal > 0, "The goal must be greater than zero");
            require(_benefactor != address(0), "Invalid address");

            uint deadline_ = block.timestamp + _deadline;

            campaigns[campaignId] = Campaign({
                title: _title,
                description: _description,
                benefactor: _benefactor,
                goal: _goal,
                deadline: deadline_,
                amountRaised: 0,
                ended: false
            });

            campaignId++;

            emit CampaignCreated(_title, _goal, _deadline);
    }

    function donate(uint256 _campaignId) external payable noReentrant {
        // use storage to persist campaign to state
        Campaign storage campaign = campaigns[_campaignId];

        // check if it's past the deadline or if the campaign has ended
        require(block.timestamp < campaign.deadline, "The campaign has ended");
        require(!campaign.ended, "The campaign has ended");

        campaign.amountRaised += msg.value;

        emit DonationReceived(_campaignId, msg.sender, msg.value);
    }

    function endCampaign(uint256 _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];

        require(block.timestamp >= campaign.deadline, "Campaign is still ongoing");
        require(!campaign.ended, "Campaign has ended already");

        // end the campaign
        campaign.ended = true;

        // send the money to the benefactor
        campaign.benefactor.transfer(campaign.amountRaised);

        emit CampaignEnded("Campaign has ended", campaign.deadline, campaign.amountRaised);
    }

    function withdrawLeftover() external onlyOwner noReentrant {
        uint balance = address(this).balance;
        require(balance > 0, "Nothing left to withdraw");
        payable(owner).transfer(balance);
    }
}

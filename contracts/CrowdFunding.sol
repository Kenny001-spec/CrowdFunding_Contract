// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public owner;
    uint256 public goal;
    uint256 public raisedAmount;
    uint256 public deadline;
    bool public goalReached;
    bool public campaignEnded;
    
    mapping(address => uint256) public contributions;
    
    event ContributionReceived(address contributor, uint256 amount);
    event GoalReached(uint256 totalAmount);
    event FundsWithdrawn(uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier campaignActive() {
        require(block.timestamp < deadline, "Campaign has ended");
        require(!campaignEnded, "Campaign is no longer active");
        _;
    }

    constructor(uint256 _goal, uint256 _durationInDays) {
        require(_goal > 0, "Goal must be greater than 0");
        require(_durationInDays > 0, "Duration must be greater than 0");
        
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + (_durationInDays * 1 days);
    }

    receive() external payable {
        contribute();
    }
    
    function contribute() public payable campaignActive {
        require(msg.sender != address(0), "Zero address not allowed");
        require(msg.value > 0, "Contribution must be greater than 0");
        require(raisedAmount + msg.value <= goal, "Cannot exceed goal amount");
        
        contributions[msg.sender] += msg.value;
        raisedAmount += msg.value;
        
        emit ContributionReceived(msg.sender, msg.value);
        
        if (raisedAmount >= goal) {
            goalReached = true;
            emit GoalReached(raisedAmount);
        }
    }

    function withdraw() external onlyOwner {
        require(goalReached, "Goal has not been reached");
        require(!campaignEnded, "Funds have already been withdrawn");
        require(address(this).balance >= raisedAmount, "Insufficient contract balance");
        
        campaignEnded = true;
        uint256 amount = raisedAmount;
        
        (bool sent, ) = payable(owner).call{value: amount}("");
        require(sent, "Failed to send Ether");
        
        emit FundsWithdrawn(amount);
    }
    
    function getRemainingTime() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }
    
    function getCampaignStatus() public view returns (
        uint256 _goal,
        uint256 _raisedAmount,
        uint256 _deadline,
        bool _goalReached,
        bool _campaignEnded
    ) {
        return (
            goal,
            raisedAmount,
            deadline,
            goalReached,
            campaignEnded
        );
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProjectFundraiser {
    address public manager;
    uint256 public fundingGoal;
    uint256 public totalContributions;
    uint256 public campaignDeadline;
    bool public goalMet;
    bool public fundraiserClosed;
    
    mapping(address => uint256) public supporterContributions;
    
    event NewContribution(address contributor, uint256 amount);
    event GoalAchieved(uint256 totalFunds);
    event FundsWithdrawn(uint256 totalAmount);
    
    modifier onlyManager() {
        require(msg.sender == manager, "Access restricted");
        _;
    }
    
    modifier fundraiserOngoing() {
        require(block.timestamp < campaignDeadline, "Fundraiser period is over");
        require(!fundraiserClosed, "Fundraiser has already concluded");
        _;
    }

    constructor(uint256 _fundingGoal, uint256 _durationInDays) {
        require(_fundingGoal > 0, "Funding goal must be greater than zero");
        require(_durationInDays > 0, "Duration must be greater than zero");

        manager = msg.sender;
        fundingGoal = _fundingGoal;
        campaignDeadline = block.timestamp + (_durationInDays * 1 days);
    }

    receive() external payable {
        contribute();
    }
    
    function contribute() public payable fundraiserOngoing {
        require(msg.sender != address(0), "Contributor address cannot be zero");
        require(msg.value > 0, "Contribution must be greater than zero");
        require(totalContributions + msg.value <= fundingGoal, "Contribution has exceed goal");

        supporterContributions[msg.sender] += msg.value;
        totalContributions += msg.value;
        
        emit NewContribution(msg.sender, msg.value);
        
        if (totalContributions >= fundingGoal) {
            goalMet = true;
            emit GoalAchieved(totalContributions);
        }
    }

    function withdrawFunds() external onlyManager {
        require(goalMet, "Funding goal not yet achieved");
        require(!fundraiserClosed, "Funds already withdrawn");

        fundraiserClosed = true;
        uint256 amountToWithdraw = totalContributions;

        (bool successful, ) = payable(manager).call{value: amountToWithdraw}("");
        require(successful, "Withdrawal failed");

        emit FundsWithdrawn(amountToWithdraw);
    }
    
    function remainingTime() public view returns (uint256) {
        if (block.timestamp >= campaignDeadline) {
            return 0;
        }
        return campaignDeadline - block.timestamp;
    }
    
    function getFundraiserStatus() public view returns (
        uint256 _goal,
        uint256 _contributed,
        uint256 _deadline,
        bool _goalMet,
        bool _closed
    ) {
        return (
            fundingGoal,
            totalContributions,
            campaignDeadline,
            goalMet,
            fundraiserClosed
        );
    }
}

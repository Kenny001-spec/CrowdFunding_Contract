import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { ethers } from "hardhat";

const DurationTime = 2;
const fundingGoal = ethers.parseEther("1");

const CrowdfundingModule = buildModule("CrowdfundingModule", (m) => {
  const goal = m.getParameter("goal", fundingGoal);
  const deadline = m.getParameter("deadline", DurationTime);

  const Crowdfunding = m.contract("Crowdfunding", [deadline, goal]);

  return { Crowdfunding };
});

export default CrowdfundingModule;
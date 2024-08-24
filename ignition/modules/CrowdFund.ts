import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const CrowdFundModule = buildModule("CrowdFund", (m) => {

  const crowdFund = m.contract("CrowdFund");

  return { crowdFund };
});

export default CrowdFundModule;

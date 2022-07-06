const hre = require("hardhat");

async function main() {
    const contributionContract = await hre.ethers.getContractFactory("ContributionContract");
    const contributionContractInstance = await contributionContract.deploy();

    await contributionContractInstance.deployed();

    console.log("ContributionContract deployed to:", contributionContractInstance.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
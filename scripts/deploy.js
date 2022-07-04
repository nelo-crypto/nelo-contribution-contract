const hre = require("hardhat");

async function main() {
    const buyContract = await hre.ethers.getContractFactory("BuyContract");
    const buyContractInstance = await buyContract.deploy();

    await buyContractInstance.deployed();

    console.log("BuyContract deployed to:", buyContractInstance.address);

    buyContractInstance.runRouterApprovals()
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
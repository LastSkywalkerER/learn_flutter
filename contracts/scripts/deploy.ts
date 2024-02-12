import hre from "hardhat";

async function main() {
    const contract = await hre.viem.deployContract("ToDoList");

    console.log(
        `Address ${contract.address}`
    );

    await hre.run("verify:verify", {
        address: contract.address,
        constructorArguments: [],
    });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

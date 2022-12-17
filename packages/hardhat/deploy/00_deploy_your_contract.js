// deploy/00_deploy_your_contract.js

const { ethers } = require("hardhat");

const localChainId = "31337";

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  console.log("chainId", chainId);

  await deploy("Dataflix", {
    from: deployer,
    args: ["Dataflix-Dao", "DFLX", "https://dflx.io"],
    log: true,
    waitConfirmations: chainId === localChainId ? 0 : 5,
  });

  // Getting a previously deployed contract
  const Dataflix = await ethers.getContract("Dataflix", deployer);

  const result = await Dataflix.addDatasource(
    "test-source",
    "ipfs.io/foo/bar",
    ethers.utils.parseUnits("1", "ether"),
    0,
  );
  console.log("result", result);

  /*
    await Dataflix.transferOwnership(
      "ADDRESS_HERE"
    );
    //const Dataflix = await ethers.getContractAt('Dataflix', "0xaAC799eC2d00C013f1F11c37E654e59B0429DF6A") //<-- if you want to instantiate a version of a contract at a specific address!
  */

  /*
  //If you want to send value to an address from the deployer
  const deployerWallet = ethers.provider.getSigner()
  await deployerWallet.sendTransaction({
    to: "0x34aA3F359A9D614239015126635CE7732c18fDF3",
    value: ethers.utils.parseEther("0.001")
  })
  */

  /*
  //If you want to send some ETH to a contract on deploy (make your constructor payable!)
  const dataflix = await deploy("Dataflix", [], {
  value: ethers.utils.parseEther("0.05")
  });
  */

  /*
  //If you want to link a library into your contract:
  // reference: https://github.com/austintgriffith/dataflix/blob/using-libraries-example/packages/hardhat/scripts/deploy.js#L19
  const dataflix = await deploy("Dataflix", [], {}, {
   LibraryName: **LibraryAddress**
  });
  */

  // try {
  //   if (chainId !== localChainId) {
  //     await run("verify:verify", {
  //       address: Dataflix.address,
  //       contract: "contracts/Dataflix.sol:Dataflix",
  //       constructorArguments: [],
  //     });
  //   }
  // } catch (error) {
  //   console.error(error);
  // }
};
module.exports.tags = ["Dataflix"];

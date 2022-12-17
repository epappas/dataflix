const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("My Dapp", function () {
  let myContract;

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before((done) => {
    setTimeout(done, 2000);
  });

  describe("Dataflix", function () {
    it("Should deploy YourContract", async function () {
      const YourContract = await ethers.getContractFactory("Dataflix");

      myContract = await YourContract.deploy();
    });
  });
});

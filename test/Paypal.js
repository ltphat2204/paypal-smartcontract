const { expect } = require("chai");
const hre = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("Get name", function () {
    async function deployPaypal() {
        const paypal = await hre.ethers.deployContract("Paypal");
        return {paypal};
    }

    it("Should return Anonymous User", async function () {
        const anonymousAccount = "0xF10a97F9b8128CBf4bd25e5F7B40ED136FF5cf36";
        const anonymousAccountName = "Anonymous User";

        const { paypal } = await loadFixture(deployPaypal);

        expect(await paypal.getName(anonymousAccount)).to.equal(anonymousAccountName);
    });

    it("Should return the name of user", async function () {
        const alexanderAccount = "0x6c938de5AD7Fb563A96a8a949CfdD3E82d48CE95";
        const alexanderAccountName = "Alexander";

        const { paypal } = await loadFixture(deployPaypal);
        // Can not set name to the specified account
        paypal.addName(alexanderAccountName, {from: alexanderAccount})

        expect(await paypal.getName(alexanderAccount)).to.equal(alexanderAccountName);
    })
});
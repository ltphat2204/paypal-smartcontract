const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("Paypal", (m) => {
    const paypal = m.contract("Paypal");
  
    return { paypal };
});
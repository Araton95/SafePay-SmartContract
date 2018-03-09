var Agreement = artifacts.require("./Agreement.sol");

module.exports = function(deployer) {
  deployer.deploy(Agreement);
};

var Scheduler = artifacts.require("./Scheduler.sol");
module.exports = function(deployer) {
  var chores = [1,2,3,4,5,6]
  var housemates = [1,2]
  deployer.deploy(Scheduler, chores, housemates);
};

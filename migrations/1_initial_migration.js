const Migrations = artifacts.require("Migrations");
const UserManagement = artifacts.require("UserManagement");
const StockManagement = artifacts.require("StockManagement");
var file_path = `${__dirname}/../path.json`;
var path = require(file_path);
var fs = require("fs");

module.exports = function (deployer, network, accounts) {
  deployer
    .then(function() {
      return deployer.deploy(Migrations);
    })
    .then(function() {
      return deployer.deploy(UserManagement)
    })
    .then(function(contract) {
      path.UserManagementaddraddr = contract.address;
      return deployer.deploy(StockManagement, contract.address);
    })
    .then(function (contract) {
			path.StockManagementaddr = contract.address;

			fs.writeFile(file_path, JSON.stringify(path, null, 2), function (err) {
				if (err) return console.log(err);
				console.log(JSON.stringify(path));
				console.log("writing to " + file_path);
			});
		});
  
};

// The object 'Contracts' will be injected here, which contains all data for all contracts, keyed on contract name:
// Contracts['HelloWorld'] = {
//  abi: [],
//  address: "0x..",
//  endpoint: "http://...."
// }

// Create an instance of the smart contract, passing it as a property, 
// which allows web3js to interact with it.
function TaskChain(Contract) {
    this.web3 = null;
    this.instance = null;
    this.Contract = Contract;
    console.log("LOAD Success");
}

// Initialize the `Coin` object and create an instance of the web3js library, 
TaskChain.prototype.init = function () {
    // The initialization function defines the interface for the contract using 
    // the web3js contract object and then defines the address of the instance 
    // of the contract for the `Coin` object.

    // Create a new Web3 instance using either the Metamask provider
    // or an independent provider created as the endpoint configured for the contract.
    this.web3 = new Web3(
        (window.web3 && window.web3.currentProvider) ||
        new Web3.providers.HttpProvider(this.Contract.endpoint));

    // Create the contract interface using the ABI provided in the configuration.
    var contract_interface = this.web3.eth.contract(this.Contract.abi);

    // Create the contract instance for the specific address provided in the configuration.
    this.instance = contract_interface.at(this.Contract.address);
};

//create new User
TaskChain.prototype.createNewUser = function () {
    var that = this;

    // Get input values for userName and userType
    var userName = $("#userName").val();
    var userType = $("#userType").val();
    console.log("Username:", userName);
    console.log("Usertype:", userType);

    //calls new User function, adds to blockchain
    this.instance.newUser(
        userName,
        userType,
        {
            from: window.web3.eth.accounts[0], gas: 1000000, gasPrice: 100000, gasLimit: 100000
        },
        // If there's an error, log it
        function (error, txHash) {
            if (error) {
                console.log("error1", error);
            }
            // If success then wait for confirmation of transaction
            // with utility function and clear form values while waiting
            else {
                that.waitForReceipt(txHash, function (receipt) {
                    if (receipt.status) {
                        $("#userName").val("");
                        showStatus("User " + userName + " created!")
                    }
                    else {
                        console.log("error in user");
                        showStatus("error in user create")
                    }
                });
            }
        }
    )
}

//upgrades user to new user tier
TaskChain.prototype.upgradeUser = function (hash, cb) {
    var that = this;
    console.log("this check")
    //upgrades user tier
    this.instance.updateUserTier(
        { from: window.web3.eth.accounts[0], gas: 1000000, gasPrice: 100000, gasLimit: 100000 },
        function (error, _success) {
            if (error) {
                console.log(error);
            }
            else {
                console.log("SUCCESS!", _success);
                showStatus("Transaction Complete!");
            }
        })
}

//creates a new arbitrator class to user calling function
TaskChain.prototype.createArb = function (hash, cb) {
    var that = this;
    console.log("this check")

    //records address of account calling
    var address = window.web3.eth.accounts[0];

    this.instance.appointArbitrator(
        { from: window.web3.eth.accounts[0], gas: 1000000, gasPrice: 100000, gasLimit: 100000 },
        function (error, txHash) {
            if (error) {
                console.log(error);
                showStatus(error);
            }
            else {
                that.waitForReceipt(txHash, function (receipt) {
                    if (receipt !== null) {
                        console.log("success");
                        showStatus("Transaction Completed")
                    }
                    else {
                        console.log("receipt error");
                        showStatus("Transaction Failure")

                    }
                });
            }
        }
    )
}

// Waits for receipt of transaction
TaskChain.prototype.waitForReceipt = function (hash, cb) {
    var that = this;

    // Checks for transaction receipt using web3 library method
    this.web3.eth.getTransactionReceipt(hash, function (err, receipt) {
        if (err) {
            console.log("Transaciton Receipt Error");
            error(err);
        }
        if (receipt !== null) {
            // Transaction went through
            if (cb) {
                console.log("receipt1");
                cb(receipt);
                console.log("receipt2");
            }
        } else {
            // Try again in 2 second
            console.log("receipt2");
            window.setTimeout(function () { that.waitForReceipt(hash, cb); }, 2000);
        }
    });
}

//calls user structure
TaskChain.prototype.isUser = function (hash, cb) {
    var that = this;

    // Get input values
    var userAddress = $("#userCheckAddress").val();
    if (!isValidAddress(userAddress)) {
        showStatus("Please enter a valid address");
        return;
    }
    console.log("UserAddress", userAddress);

    this.instance.getUser(
        userAddress,
        function (error, userStruct) {
            if (error) {
                console.log(error);
            }
            else {
                console.log(userStruct);
                $("#message").text(userStruct);
            }
        }
    )
}

//calls user structure
TaskChain.prototype.getUserIndex = function (hash, cb) {
    var that = this;
    // Get input values
    var userIndex = $("#userIndex").val();
    console.log("userIndex: ", userIndex);

    this.instance.getUserIndex(
        userIndex,
        function (error, userAddress) {
            if (error) {
                console.log(error);
            }
            else {
                console.log(userAddress);
                $("#userAddressRetrieve").text(userAddress);
            }
        }
    )
}

//calls user structure
TaskChain.prototype.getUserCount = function (hash, cb) {
    var that = this;
    console.log("part1: Pre Count")
    this.instance.getUserCount(
        function (error, userCount) {
            if (error) {
                console.log(error);
            }
            else {
                console.log(userCount);
                $("#userNumberRetrieve").text(userCount);
            }
        }
    )
}

// creates new admin user, only called by rootadmin
TaskChain.prototype.appAdmin = function () {
    var that = this;
    console.log("PreLoadCheck")
    // Get input values, the address
    var address = $("#adminAddress").val();
    console.log("address: ", address);
    if (!isValidAddress(address)) {
        showStatus("Please enter a valid address");
        return;
    }
    //appoints admin
    this.instance.createAdmin(
        address,
        { from: window.web3.eth.accounts[0], gas: 1000000, gasPrice: 100000, gasLimit: 100000 },
        console.log("Load1"),
        function (error, txHash) {
            console.log("Error Load")
            if (error) {
                console.log("Error: ", error);
            }
            else {
                console.log("Else1");
                that.waitForReceipt(txHash, function (receipt) {
                    console.log("Reciept Load");
                    if (receipt.status == 1) {
                        console.log("success");
                        showStatus("Transaction Complete");
                    }
                    else {
                        console.log("receipt error");

                    }
                });
            }
        }
    )
}

//demotes admin
TaskChain.prototype.demAdmin = function () {
    var that = this;
    console.log("this check")

    // Get input values, the address
    var address = $("#adminAddress").val();
    if (!isValidAddress(address)) {
        showStatus("Please enter a valid address");
        return;
    }
    console.log("address: ", address);


    // gets address, msg.sender, and demotes
    this.instance.createAdmin(
        address,
        { from: window.web3.eth.accounts[0], gas: 1000000, gasPrice: 100000, gasLimit: 100000 },
        console.log("Preload"),
        function (error, txHash) {
            console.log("Load1")
            if (error) {
                console.log("Error: ", error);
            }
            else {
                console.log("Load2");
                that.waitForReceipt(txHash, function (receipt) {
                    console.log("Reciept");
                    if (receipt.status == 1) {
                        console.log("success");
                        showStatus("Transaction Complete");
                    }
                    else {
                        console.log("receipt error");
                    }
                });
            }
        }
    )
}

//restricts accounts, called by admins
TaskChain.prototype.restrictAccount = function () {
    var that = this;
    console.log("Preload")

    // Get input values, the address
    var address = $("#restrictAccountAddress").val();
    console.log(address);
    if (!isValidAddress(address)) {
        showStatus("Please enter a valid address");
        return;
    }

    this.instance.restrictAccount(
        address,
        { from: window.web3.eth.accounts[0], gas: 1000000, gasPrice: 100000, gasLimit: 100000 },
        console.log("Preload"),
        function (error, txHash) {
            console.log("Load1")
            if (error) {
                console.log("Error: ", error);
            }
            else {
                console.log("Load2");
                that.waitForReceipt(txHash, function (receipt) {
                    console.log("Reciept");
                    if (receipt.status == 1) {
                        console.log("success");
                        showStatus("Transaction Complete");
                    }
                    else {
                        console.log("receipt error");

                    }
                });
            }
        }
    )
}

//restores resctricted account
TaskChain.prototype.restoreAccount = function () {
    var that = this;
    console.log("Preload")

    // Get input values, the address
    var address = $("#restrictAccountAddress").val();
    if (!isValidAddress(address)) {
        showStatus("Please enter a valid address");
        return;
    }
    console.log("address: ", address);

    // Check the balance from the address 
    this.instance.restoreAccount(
        address,
        { from: window.web3.eth.accounts[0], gas: 1000000, gasPrice: 100000, gasLimit: 100000 },
        console.log("Load1"),
        function (error, txHash) {
            console.log("Load2")
            if (error) {
                console.log("Error: ", error);
            }
            else {
                console.log("Load3");
                that.waitForReceipt(txHash, function (receipt) {
                    console.log("Reciept");
                    if (receipt.status == 1) {
                        console.log("success");
                        showStatus("Transaction Complete");
                    }
                    else {
                        console.log("receipt error");

                    }
                });
            }
        }
    )
}

TaskChain.prototype.createContract = function () {
    var that = this;
    console.log("this check")
    // Get input values, the address  
    var address = window.web3.eth.accounts[0];
    var contractTitle = $("#contractName").val();
    var msgValue = $("#msgValue").val();
    var quota = $("#quota").val();
    var tasktier = $("#taskTier").val();
    let newHex = ethers.utils.formatBytes32String(contractTitle);
    console.log("address: ", address);
    console.log("Key: ", newHex);
    console.log("Contract Title", contractTitle);
    console.log("tasktier: ", tasktier);
    console.log("quota: ", quota);
    console.log("value: ", msgValue);

    // Check the balance from the address 
    this.instance.createContract(
        newHex,
        contractTitle,
        tasktier,
        quota,
        msgValue,
        { from: window.web3.eth.accounts[0], value: msgValue, gas: 1000000, gasPrice: 100000, gasLimit: 100000 },
        console.log("error1"),
        function (error, txHash) {
            console.log("erorrrr")
            console.log(error);
            if (error) {
                console.log("error2");
                console.log(error);
            }
            else {
                console.log("elsechain");
                that.waitForReceipt(txHash, function (receipt) {
                    console.log("error3");
                    if (receipt.status == 1) {
                        console.log("success");
                        $("#completeWorkAddress").val("");
                        showStatus("Transaction Complete!");

                    }
                    else {
                        console.log("receipt error");
                        showStatus("Transaction Error!");

                    }
                });
            }
        }
    )
}


//calls contract structure
TaskChain.prototype.getContract = function (hash, cb) {
    var that = this;

    // Get input values
    var key = $("#contractKey").val();

    console.log("contract key: ", key);

    this.instance.getContract(key,
        function (error, contractStruct) {
            if (error) {
                console.log(error);
            }
            else {
                console.log(contractStruct);
                $("#ContractInfoRetrieve").text(contractStruct);
                $("#contractKey").val("");
            }
        })
}


//calls contract structure
TaskChain.prototype.getContractAtIndex = function (hash, cb) {
    var that = this;

    // Get input values
    var contractIndex = $("#contractIndex").val();

    console.log("contract key: ", contractIndex);

    this.instance.getContractAtIndex(contractIndex,
        function (error, contractStruct) {
            if (error) {
                console.log(error);
            }
            else {
                console.log(contractStruct);
                $("#ContractKeyRetrieve").text(contractStruct);
                $("#contractIndex").val("");
            }
        })
}


TaskChain.prototype.completeWork = function () {
    var that = this;
    console.log("this check")

    // Get input values, the address
    var address = $("#completeWorkAddress").val();
    var newAddress = { from: window.web3.eth.accounts[0] };
    console.log("sender addrewss", newAddress);

    console.log(address);

    // Check the balance from the address 
    this.instance.completeWork(
        address,
        { from: window.web3.eth.accounts[0], gas: 1000000, gasPrice: 100000, gasLimit: 100000 },
        console.log("error1"),
        function (error, txHash) {
            console.log("erorrrr")
            if (error) {
                console.log("error2");
                console.log(error);
            }
            else {
                console.log("elsechain");
                that.waitForReceipt(txHash, function (receipt) {
                    console.log("error3");
                    if (receipt.status == 1) {
                        console.log("success");
                        $("#completeWorkAddress").val("");
                        showStatus("Transaction Complete!");
                    }
                    else {
                        console.log("receipt error");
                        showStatus("Transaction Error!");

                    }
                });
            }
        }
    )
}

TaskChain.prototype.reviewWork = function () {
    var that = this;
    console.log("this check")

    // Get input values, the address
    var address = $("#reviewAddress").val();
    var key = $("#contractKeyReview").val();
    var passFailVal = $("#reviewPassFail").val();
    console.log("boolValue", passFailVal);


    console.log("address", address);
    console.log("key", key);
    console.log("passFail", passFailVal);


    if (!isValidAddress(address)) {
        showStatus("Please enter a valid address");
        return;
    }
    console.log(address);

    // Check the balance from the address 
    this.instance.reviewWork(passFailVal, key, address, { from: window.web3.eth.accounts[0], gas: 1000000, gasPrice: 100000, gasLimit: 100000 },
        console.log("error1"),
        function (error, txHash) {
            console.log("erorrrr")
            if (error) {
                console.log("error2");
                console.log(error);
            }
            else {
                console.log("elsechain");
                that.waitForReceipt(txHash, function (receipt) {
                    console.log("error3");
                    if (receipt.status == 1) {
                        console.log("success");
                        $("#reviewAddress").val("");
                        showStatus("Complete!");
                    }
                    else {
                        console.log("receipt error");
                        console.log(receipt);
                        showStatus("error");

                    }
                });
            }
        }
    )
}


TaskChain.prototype.arbitrateWork = function () {
    var that = this;
    console.log("this check")

    // Get input values, the address
    var address = $("#contractArbAdd").val();
    var workerAddress = $("#workerArbAdd").val();
    var passFail = $("#arbitrateWork").val();


    if (!isValidAddress(workerAddress)) {
        showStatus("Please enter a valid address");
        return;
    }
    console.log(address);

    // Check the balance from the address 
    this.instance.arbitrateWork(passFail, workerAddress, address, { from: window.web3.eth.accounts[0], gas: 1000000, gasPrice: 100000, gasLimit: 100000 },
        console.log("error1"),
        function (error, txHash) {
            console.log("erorrrr")
            if (error) {
                console.log("error2");
                console.log(error);
            }
            else {
                console.log("elsechain");
                that.waitForReceipt(txHash, function (receipt) {
                    console.log("error3");
                    if (receipt.status == 1) {
                        console.log("success");
                        $("#contractArbAdd").val("");
                        $("#workerArbAdd").val("");
                    }
                    else {
                        console.log("receipt error");

                    }
                });
            }
        }
    )
}

//upgrades user to new user tier
TaskChain.prototype.transferEscrow = function (hash, cb) {
    var that = this;
    console.log("this check")

    //address of caller
    var key = $("#escrowCashKey").val();

    //upgrades user tier
    this.instance.transferEscrow(key, { from: window.web3.eth.accounts[0], gas: 1000000, gasPrice: 100000, gasLimit: 100000 },
        function (error, txHash) {
            if (error) {
                console.log(error);
            }
            else {
                that.waitForReceipt(txHash, function (receipt) {
                    if (receipt !== null) {
                        console.log("success");
                        showStatus("Transaction Completed!")
                    }
                    else {
                        console.log("receipt error");
                        showStatus("Error in Transaction")

                    }
                });
            }
        }
    )
}

//upgrades user to new user tier
TaskChain.prototype.workCashOut = function (hash, cb) {
    var that = this;
    console.log("this check")

    //address of caller
    var address = window.web3.eth.accounts[0];

    //upgrades user tier
    this.instance.cashOut({ from: window.web3.eth.accounts[0], gas: 1000000, gasPrice: 100000, gasLimit: 100000 },
        function (error, txHash) {
            if (error) {
                console.log(error);
            }
            else {
                that.waitForReceipt(txHash, function (receipt) {
                    if (receipt !== null) {
                        console.log("success");
                        showStatus("Transaction Completed!")
                    }
                    else {
                        console.log("receipt error");
                        showStatus("Error in Transaction")
                    }
                });
            }
        }
    )
}



//upgrades user to new user tier
TaskChain.prototype.checkContractBal = function (hash, cb) {
    var that = this;
    console.log("this check")

    //address of caller
    var address = window.web3.eth.accounts[0];

    //upgrades user tier
    this.instance.checkContractBal({ from: window.web3.eth.accounts[0], gas: 1000000, gasPrice: 100000, gasLimit: 100000 },
        function (error, balance) {
            if (error) {
                console.log(error);
            }
            else {
                console.log(balance.toNumber());
                $("#contractBalanceMessage").text(balance.toNumber());
            }
        })
}

//upgrades user to new user tier
TaskChain.prototype.closeContractTag = function (hash, cb) {
    var that = this;
    console.log("this check")

    //address of caller
    var address = window.web3.eth.accounts[0];
    var key = $("#closeContractKey").val();

    //upgrades user tier
    this.instance.closeContract(key, { from: window.web3.eth.accounts[0], gas: 1000000, gasPrice: 100000, gasLimit: 100000 },
        function (error, txHash) {
            if (error) {
                console.log(error);
            }
            else {
                that.waitForReceipt(txHash, function (receipt) {
                    if (receipt !== null) {
                        console.log("success");
                        showStatus("Transaction Completed!")
                    }
                    else {
                        console.log("receipt error");
                        showStatus("Error in Transaction")
                    }
                });
            }
        }
    )
}

// Check if it has the basic requirements of an address
function isValidAddress(address) {
    return /^(0x)?[0-9a-f]{40}$/i.test(address);
}

// Basic validation of amount. Bigger than 0 and typeof number
function isValidAmount(amount) {
    return amount > 0 && typeof Number(amount) == 'number';
}

// Bind functions to the buttons defined in app.html
TaskChain.prototype.bindButtons = function () {
    var that = this;

    $(document).on("click", "#createUser", function () {
        console.log('usertryClick')
        that.createNewUser();
        console.log('UserClick')
    });

    $(document).on("click", "#getUserCountBtn", function () {
        console.log('usertryClick')
        that.isUser();
        console.log('UserClick')
    });

    $(document).on("click", "#getUserAtIndexBtn", function () {
        console.log('usertryClick')
        that.getUserIndex();
        console.log('UserClick')
    });

    $(document).on("click", "#getUserNumberBtn", function () {
        console.log('usertryClick')
        that.getUserCount();
        console.log('UserClick')
    });

    $(document).on("click", "#updateUserTier", function () {
        console.log('usertryClick')
        that.upgradeUser();
        console.log('UserClick')
    });

    $(document).on("click", "#appointArbitrator", function () {
        console.log('usertryClick')
        that.createArb();
        console.log('UserClick')
    });

    $(document).on("click", "#createAdmin", function () {
        console.log('usertryClickAdmin')
        that.appAdmin();
        console.log('UserClick')
    });

    $(document).on("click", "#demoteAdmin", function () {
        console.log('usertryClickAdmin')
        that.demAdmin();
        console.log('UserClick')
    });

    $(document).on("click", "#restrictAccount", function () {
        console.log('usertryClickAdmin')
        that.restrictAccount();
        console.log('UserClick')
    });

    $(document).on("click", "#restoreAccount", function () {
        console.log('usertryClickAdmin')
        that.restoreAccount();
        console.log('UserClick')
    });

    $(document).on("click", "#createContract", function () {
        console.log('usertryClickAdmin')
        that.createContract();
        console.log('UserClick')
    });


    $(document).on("click", "#getContractAtIndex", function () {
        console.log('usertryClickAdmin')
        that.getContractAtIndex();
        console.log('UserClick')
    });

    $(document).on("click", "#completeWork", function () {
        console.log('usertryClickAdmin')
        that.completeWork();
        console.log('UserClick')
    });

    $(document).on("click", "#getContractAtKey", function () {
        console.log('usertryClickAdmin')
        that.getContract();
        console.log('UserClick')
    });

    $(document).on("click", "#transferEscrow", function () {
        console.log('usertryClickAdmin')
        that.transferEscrow();
        console.log('UserClick')
    });

    $(document).on("click", "#reviewWork", function () {
        console.log('usertryClickAdmin')
        that.reviewWork();
        console.log('UserClick')
    });

    $(document).on("click", "#workCashOut", function () {
        console.log('usertryClickAdmin')
        that.workCashOut();
        console.log('UserClick')
    });

    $(document).on("click", "#arbitratorCashOut", function () {
        console.log('usertryClickAdmin')
        that.arbitratorCashOut();
        console.log('UserClick')
    });

    $(document).on("click", "#closeContractButton", function () {
        console.log('close contract')
        that.closeContractTag();
        console.log('UserClick Close Contract')
    });

    $(document).on("click", "#checkContractBal", function () {
        console.log('usertryClickAdmin')
        that.checkContractBal();
        console.log('UserClick')
    });

}

function showStatus(text) {
    alert(text);
}

// Create the instance of the `TaskChain` object 
TaskChain.prototype.onReady = function () {
    this.bindButtons();
    this.init();
};

if (typeof (Contracts) === "undefined") var Contracts = { TaskChain: { abi: [] } };
var task = new TaskChain(Contracts['TaskChain']);

$(document).ready(function () {
    task.onReady();
});

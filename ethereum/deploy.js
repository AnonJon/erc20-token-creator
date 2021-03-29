const HDWalletProvider = require("truffle-hdwallet-provider");
const Web3 = require("web3");
const compiledToken = require("./build/ERC20Basic.json");

const provider = new HDWalletProvider(process.env.mnemonic, process.env.infura);

const web3 = new Web3(provider);

const deploy = async () => {
  const accounts = await web3.eth.getAccounts();

  console.log("Attempting to deploy from account", accounts[0]);
  const result = await new web3.eth.Contract(compiledToken.abi)
    .deploy({
      data: "0x" + compiledToken.evm.bytecode.object,
      arguments: [1000],
    }) // add 0x bytecode
    .send({ from: accounts[0] }); // remove 'gas'

  console.log("interface", compiledToken.abi);
  console.log("Contract deployed to", result.options.address);
};

deploy();

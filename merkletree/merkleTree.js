const express = require("express");
const app = express();
const port = 4000;

const { MerkleTree } = require("merkletreejs");
// const ethers = require("ethers");
const keccak256 = require("keccak256");
// inputs: array of users' addresses and quantity
// each item in the inputs array is a block of data
// Alice, Bob and Carol's data respectively
// const inputs = [
//   {
//     address: "0x70997970c51812dc3a010c7d01b50e0d17dc79c8",
//     quantity: 1,
//   },
//   {
//     address: "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
//     quantity: 2,
//   },
//   {
//     address: "0x90F79bf6EB2c4f870365E785982E1f101E93b906",
//     quantity: 1,
//   },
// ];
const inputs = [
  "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
  "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266",
  "0x90F79bf6EB2c4f870365E785982E1f101E93b906",
  "0x23CA0c2219de2C5A6bf13B66897303c2766f3DE5",
  "0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF",
];

// create leaves from users' address and quantity
// const leaves = inputs.map((x) =>
//   ethers.utils.solidityKeccak256(
//     ["address", "uint256"],
//     [x.address, x.quantity]
//   )
// );
const leaves = inputs.map((addr) => keccak256(addr));

// create a Merkle tree
const tree = new MerkleTree(leaves, keccak256, { sort: true });
console.log(tree.toString());

const allowCrossDomain = function (req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Methods", "GET,PUT,POST,DELETE");
  res.header(
    "Access-Control-Allow-Headers",
    "Content-Type, Authorization, access_token"
  );

  if ("OPTIONS" === req.method) {
    res.sendStatus(200);
  } else {
    next();
  }
};
app.use(allowCrossDomain);

// console.log(leaves);
// const proofs = leaves.map((leave) => tree.getHexProof(leave));
// console.log(proofs);

app.get("/", (req, res) => {
  const address = req.query.address;
  console.log(address);
  var proof;
  var quantity = 2;
  // inputs.forEach(function (value, index) {
  //   console.log(value);
  //   if (value.address === address) {
  //     console.log("Match!");
  //     proof = tree.getHexProof(leaves[index]);
  //     quantity = value.quantity;
  //   }
  // });
  proof = tree.getHexProof(keccak256(address));
  console.log("Proof: " + proof);
  res.json({ proof: proof, quantity: quantity });
});

console.log(tree.getHexProof(leaves[1]));

const root = tree.getHexRoot();
console.log("merkle Root: " + root);

app.listen(port, () => console.log("Server Start!"));

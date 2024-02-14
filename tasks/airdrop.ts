import fs from "fs";
import path from "path";
import { createWalletClient, http, parseAbi, parseEther } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { avalancheFuji } from "viem/chains";

interface AirdropTransaction {
  index: number;
  wallets: `0x${string}`[];
  amount: number;
}

const RPC_URL = "http://127.0.0.1:8545";
const CHAIN = avalancheFuji;
const FOLDER_PATH = "tasks/airdrop-files";
const TRANSACTION_FILE_MATCH =
  /Transaction (\d+) - ([+-]?([0-9]*[.])?[0-9]+)\.csv/;
const AIRDROP_ABI = parseAbi([
  "function airdrop(address[] calldata wallets, uint256 amount) external",
]);
const SHOE_ADDRESS = "0xF5B2C85473d3e162ab3eA1658E03791C3e59ca2e";

const account = privateKeyToAccount(
  process.env.AIRDROP_PRIVATE_KEY! as `0x${string}`
);

const client = createWalletClient({
  account,
  transport: http(RPC_URL),
  chain: CHAIN,
});

const files = fs.readdirSync(FOLDER_PATH);

const transactions: AirdropTransaction[] = [];

files.forEach((file) => {
  const match = file.match(TRANSACTION_FILE_MATCH);

  if (match) {
    const filePath = path.join(FOLDER_PATH, file);
    const fileContent = fs.readFileSync(filePath, "utf-8");

    const index = parseInt(match[1]);
    const amount = parseFloat(match[2]);

    transactions.push({
      index,
      wallets: fileContent.split("\n") as `0x${string}`[],
      amount,
    });
  }
});

console.log(`Airdropping ${transactions.length} transactions...\n`);

for (let i = 0; i < transactions.length; i++) {
  const transaction = transactions[i];
  const wallets = transaction.wallets;

  console.log(
    `${transaction.index}: Airdropping ${transaction.amount} to ${wallets.length} wallets`
  );

  await client
    .writeContract({
      address: SHOE_ADDRESS,
      abi: AIRDROP_ABI,
      functionName: "airdrop",
      args: [wallets, parseEther(transaction.amount.toString())],
    })
    .then((tx) => {
      console.log(`    ✅ Transaction ${transaction.index} sent: ${tx}`);
    })
    .then(() => new Promise((resolve) => setTimeout(resolve, 1000)))
    .catch((error) => {
      console.error(`    ❌ Transaction ${transaction.index} failed: ${error}`);
    });
}

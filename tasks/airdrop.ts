import fs from "fs";
import path from "path";
import { createWalletClient, http, parseAbi, parseEther } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { avalancheFuji } from "viem/chains";

interface AirdropTransaction {
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

    const amount = parseFloat(match[2]);

    transactions.push({
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
    `${i}: Airdropping ${transaction.amount} to ${wallets.length} wallets`
  );

  await client
    .writeContract({
      address: "0x538B1C712606D18241a3dF7629ca10164445b2c5",
      abi: AIRDROP_ABI,
      functionName: "airdrop",
      args: [wallets, parseEther(transaction.amount.toString())],
    })
    .then((tx) => {
      console.log(`    ✅ Transaction ${i} sent: ${tx}`);
    })
    .catch((error) => {
      console.error(`    ❌ Transaction ${i} failed: ${error}`);
    });
}

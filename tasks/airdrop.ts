import fs from "fs";
import path from "path";
import {
  createPublicClient,
  createWalletClient,
  http,
  parseAbi,
  parseEther,
} from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { avalancheFuji } from "viem/chains";

interface AirdropTransaction {
  index: number;
  wallets: `0x${string}`[];
  amount: number;
  filePath: string;
}

const RPC_URL = process.env.FUJI_RPC;
const CHAIN = avalancheFuji;
const FOLDER_PATH = "tasks/airdrop-files";
const TRANSACTION_FILE_MATCH =
  /Transaction (\d+) - ([+-]?([0-9]*[.])?[0-9]+)\.csv/;
const AIRDROP_ABI = parseAbi([
  "function airdrop(address[] calldata wallets, uint256 amount) external",
]);
const SHOE_ADDRESS = "0xcF3891177C07dcdF36c5359aad2Ed7583A8C8093";

const account = privateKeyToAccount(
  process.env.AIRDROP_PRIVATE_KEY! as `0x${string}`
);

const client = createWalletClient({
  account,
  transport: http(RPC_URL),
  chain: CHAIN,
});

const publicClient = createPublicClient({
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
      filePath,
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
      gas: 15_000_000n,
    })
    .then((tx) =>
      publicClient.waitForTransactionReceipt({
        hash: tx,
      })
    )
    .then((receipt) => {
      if (receipt.status === "success") {
        console.log(
          `    ✅ Transaction ${transaction.index} sent: ${receipt.transactionHash}`
        );
        fs.renameSync(
          transaction.filePath,
          transaction.filePath.replace("airdrop-files", "airdropped-files")
        );
      } else {
        console.error(
          `    ❌ Transaction ${transaction.index} failed: ${receipt.transactionHash}`
        );
      }
    })
    .catch((error) => {
      console.error(`    ❌ Transaction ${transaction.index} failed: ${error}`);
    });
}

import fs from "fs";
import path from "path";
import { parse } from "csv-parse";

const FOLDER_PATH = "tasks/airdrop-files";
const TOTAL_AIRDROP_FILE_NAME = "Airdrop Total.csv";
const TRANSACTION_FILE_MATCH =
  /Transaction (\d+) - ([+-]?([0-9]*[.])?[0-9]+)\.csv/;

interface AirdropLine {
  address: string;
  amount: number;
}

function processCSVFile() {
  const lines: AirdropLine[] = [];

  fs.createReadStream(path.join(FOLDER_PATH, TOTAL_AIRDROP_FILE_NAME))
    .pipe(parse({ delimiter: ",", from_line: 1 }))
    .on("data", function (row) {
      lines.push(parseCSVLine(row));
    })
    .on("end", function () {
      prepareAirdropFiles(lines);

      checkAirdroppedAmount();
    });
}

function parseCSVLine(line: string[]): AirdropLine {
  const [address, amount] = line;
  if (!address || !amount) {
    throw new Error(`Invalid line: ${line}`);
  }
  return {
    address: address.trim(),
    amount: parseFloat(amount.trim()),
  };
}

function prepareAirdropFiles(lines: AirdropLine[]) {
  let fileIndex = 0;

  const differentAmounts = new Set(lines.map((line) => line.amount));

  differentAmounts.forEach((amount) => {
    const filteredLines = lines.filter((line) => line.amount === amount);

    writeTransactionFile(
      filteredLines.map((line) => line.address),
      amount,
      fileIndex++
    );
  });
}

function writeTransactionFile(
  wallets: string[],
  amount: number,
  index: number
) {
  const fileContent = wallets.map((wallet) => `${wallet}`).join("\n");
  const fileName = path.join(
    FOLDER_PATH,
    `Transaction ${index} - ${amount}.csv`
  );

  fs.writeFileSync(fileName, fileContent);
}

function clearTransactionFiles() {
  const files = fs.readdirSync(FOLDER_PATH);

  files.forEach((file) => {
    const filePath = path.join(FOLDER_PATH, file);

    const match = file.match(TRANSACTION_FILE_MATCH);
    if (match) {
      fs.unlinkSync(filePath);
    }
  });
}

function checkAirdroppedAmount() {
  const files = fs.readdirSync(FOLDER_PATH);

  let totalSum = 0;

  files.forEach((file) => {
    const match = file.match(TRANSACTION_FILE_MATCH);

    if (match) {
      const filePath = path.join(FOLDER_PATH, file);
      const fileContent = fs.readFileSync(filePath, "utf-8");

      const lines = fileContent.split("\n").length;
      const amount = parseInt(match[2]);

      totalSum += amount * lines;
    }
  });

  console.log("Total token airdroped:", totalSum);
}

clearTransactionFiles();

processCSVFile();

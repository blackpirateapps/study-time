import { readdir, readFile } from "node:fs/promises";
import path from "node:path";

import { db } from "../src/db/client.js";

const migrationsDir = path.resolve(process.cwd(), "src/db/migrations");

const files = (await readdir(migrationsDir))
  .filter((name) => name.endsWith(".sql"))
  .sort((left, right) => left.localeCompare(right));

for (const file of files) {
  const filePath = path.join(migrationsDir, file);
  const sql = await readFile(filePath, "utf8");

  const statements = sql
    .split(";")
    .map((statement) => statement.trim())
    .filter((statement) => statement.length > 0);

  for (const statement of statements) {
    await db.execute(statement);
  }
}

console.log(`Applied ${files.length} migration file(s).`);

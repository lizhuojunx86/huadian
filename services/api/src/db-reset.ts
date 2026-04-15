/**
 * Reset the database: drop all tables, re-run migrations, and seed.
 * Called via `pnpm --filter @huadian/api db:reset`.
 */
import { execSync } from "node:child_process";

console.info("[db:reset] Running migrations...");
execSync("pnpm db:migrate", { stdio: "inherit", cwd: import.meta.dirname + "/.." });
console.info("[db:reset] Done.");

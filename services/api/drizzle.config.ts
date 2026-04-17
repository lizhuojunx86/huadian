import { defineConfig } from "drizzle-kit";

export default defineConfig({
  schema: "../../packages/db-schema/src/schema/*",
  out: "./migrations",
  dialect: "postgresql",
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
  verbose: true,
  strict: true,
});

/**
 * Codegen script: export all zod schemas to JSON Schema files under schema/.
 * Run via: pnpm --filter @huadian/shared-types codegen
 */
import { writeFileSync, mkdirSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { zodToJsonSchema } from "zod-to-json-schema";

import { personSchema } from "./person.js";

const __dirname = dirname(fileURLToPath(import.meta.url));
const schemaDir = resolve(__dirname, "../schema");

mkdirSync(schemaDir, { recursive: true });

const schemas: Record<string, ReturnType<typeof zodToJsonSchema>> = {
  person: zodToJsonSchema(personSchema, "Person"),
};

for (const [name, schema] of Object.entries(schemas)) {
  const path = resolve(schemaDir, `${name}.json`);
  writeFileSync(path, JSON.stringify(schema, null, 2) + "\n");
  console.info(`[codegen] wrote ${path}`);
}

console.info(`[codegen] ${Object.keys(schemas).length} schema(s) exported.`);

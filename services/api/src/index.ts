import { createServer } from "node:http";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

import { loadFilesSync } from "@graphql-tools/load-files";
import { mergeTypeDefs } from "@graphql-tools/merge";
import { drizzle } from "drizzle-orm/postgres-js";
import { createSchema, createYoga } from "graphql-yoga";
import postgres from "postgres";

import { createContext, type GraphQLContext } from "./context.js";
import { resolvers } from "./resolvers/index.js";

const __dirname = dirname(fileURLToPath(import.meta.url));
const SCHEMA_DIR = join(__dirname, "schema");

// Load SDL the same way scripts/merge-schema.ts does so that runtime and
// the snapshot never drift. Architect R-2(a) wiring.
const typeDefs = mergeTypeDefs(
  loadFilesSync(join(SCHEMA_DIR, "**/*.graphql"), {
    extensions: ["graphql"],
    recursive: true,
    globOptions: {
      ignore: [join(SCHEMA_DIR, "__snapshot__/**/*.graphql")],
    },
  }),
  {
    sort: true,
    throwOnConflict: true,
    useSchemaDefinition: true,
  },
);

const schema = createSchema<GraphQLContext>({ typeDefs, resolvers });

// Phase 0 DB handle. Resolvers throw NOT_IMPLEMENTED before touching
// this, so postgres.js only opens a pool lazily on first query; an
// invalid DATABASE_URL does not prevent the server from starting.
const sql = postgres(
  process.env.DATABASE_URL ?? "postgres://stub@127.0.0.1:5433/stub",
  { max: 1, onnotice: () => undefined },
);
const db = drizzle(sql);

const yoga = createYoga({
  schema,
  context: () => createContext({ db, tracer: null }),
});

const server = createServer(yoga);

const port = Number(process.env.PORT ?? 4000);
server.listen(port, () => {
  console.info(`GraphQL API running at http://localhost:${port.toString()}/graphql`);
});

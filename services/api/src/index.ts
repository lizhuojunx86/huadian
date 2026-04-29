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

// DB handle. postgres.js opens the pool lazily on first query, so an
// invalid DATABASE_URL does not prevent the server from starting; the
// failure surfaces only when a resolver issues a query.
//
// The fallback URL points at the local docker-compose Postgres with the
// project-wide dev credentials (mirrors services/api/tests/* and
// services/api/scripts/* defaults). Earlier this fallback was the
// `stub@stub` placeholder from T-P0-003 (when every resolver threw
// NOT_IMPLEMENTED). After T-P0-007 (person query) and T-P0-028 (triage
// queries) wired real DB reads, that placeholder caused
// 'role "stub" does not exist' on every request when DATABASE_URL was
// not exported by the dev shell — surfaced by Sprint K Stage 3 FE e2e.
const FALLBACK_DEV_DATABASE_URL =
  "postgres://huadian:huadian_dev@127.0.0.1:5433/huadian";

const databaseUrl = process.env.DATABASE_URL ?? FALLBACK_DEV_DATABASE_URL;
if (!process.env.DATABASE_URL) {
  console.warn(
    `[api] DATABASE_URL not set; using dev fallback ${FALLBACK_DEV_DATABASE_URL}. ` +
      "Export DATABASE_URL for non-dev environments.",
  );
}

const sql = postgres(databaseUrl, { max: 1, onnotice: () => undefined });
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

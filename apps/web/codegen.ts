/**
 * graphql-codegen configuration for @huadian/web.
 *
 * Reads the merged SDL snapshot from services/api and generates
 * typed documents (client-preset) for frontend GraphQL queries.
 *
 * Regenerate: pnpm --filter @huadian/web codegen
 */
import type { CodegenConfig } from "@graphql-codegen/cli";

const config: CodegenConfig = {
  overwrite: true,
  schema: "../../services/api/src/schema/__snapshot__/schema.graphql",
  documents: ["lib/graphql/queries/**/*.ts"],
  generates: {
    "./lib/graphql/generated/": {
      preset: "client",
      config: {
        scalars: {
          DateTime: "string",
          UUID: "string",
          JSON: "unknown",
          PositiveInt: "number",
        },
        useTypeImports: true,
        enumsAsTypes: true,
      },
    },
  },
};

export default config;

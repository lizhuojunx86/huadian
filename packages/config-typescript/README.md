# @huadian/config-typescript

Shared TypeScript configurations for the HuaDian monorepo.

## Available configs

| Config | Use case | Example consumer |
|--------|----------|-----------------|
| `tsconfig.base.json` | Library packages | `packages/shared-types`, `packages/db-schema` |
| `tsconfig.nextjs.json` | Next.js apps | `apps/web` |
| `tsconfig.node.json` | Node.js services | `services/api` |

## Usage

In your sub-package `tsconfig.json`:

```json
{
  "extends": "@huadian/config-typescript/tsconfig.node.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src"]
}
```

## Important

- **DO NOT** extend the root `tsconfig.json` or root `tsconfig.base.json` — those are for IDE indexing only.
- All sub-packages **MUST** extend one of the configs in this package.
- See ADR-007 §R-2 for rationale.

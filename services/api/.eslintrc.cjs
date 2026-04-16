/** @type {import("eslint").Linter.Config} */
module.exports = {
  root: true,
  extends: [require.resolve("@huadian/config-eslint/node")],
  parserOptions: {
    project: true,
    tsconfigRootDir: __dirname,
  },
  ignorePatterns: [
    "drizzle.config.ts",
    "codegen.ts",
    "scripts/**",
    "src/__generated__/**",
  ],
};

/** @type {import("eslint").Linter.Config} */
module.exports = {
  root: true,
  extends: [require.resolve("@huadian/config-eslint/nextjs")],
  parserOptions: {
    project: true,
    tsconfigRootDir: __dirname,
  },
};

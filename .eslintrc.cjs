/** @type {import("eslint").Linter.Config} */
module.exports = {
  root: true,
  extends: [require.resolve("@huadian/config-eslint")],
  parserOptions: {
    tsconfigRootDir: __dirname,
  },
};

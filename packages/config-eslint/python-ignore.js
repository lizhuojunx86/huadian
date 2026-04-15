/**
 * ESLint config that tells ESLint to ignore Python files and directories.
 * Used in workspaces that contain Python code (e.g., services/pipeline).
 * Python linting is handled by ruff, not ESLint.
 *
 * @type {import("eslint").Linter.Config}
 */
module.exports = {
  ignorePatterns: [
    "*.py",
    "**/*.py",
    "__pycache__/",
    ".venv/",
    ".ruff_cache/",
    ".pytest_cache/",
  ],
};

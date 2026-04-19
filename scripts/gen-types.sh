#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# HuaDian — Cross-language type generation
#
# Flow (ADR-007 §四):
#   1. TS zod → JSON Schema  (packages/shared-types/schema/*.json)
#   2. JSON Schema → Pydantic (services/pipeline/src/huadian_pipeline/generated/)
#
# Products must be committed. CI step 4 (codegen:verify) checks
# that `git diff --exit-code` is clean after running this script.
# ============================================================

SCHEMA_DIR="packages/shared-types/schema"
PYDANTIC_OUT="services/pipeline/src/huadian_pipeline/generated"

echo "[gen-types] Step 1: zod → JSON Schema"
pnpm --filter @huadian/shared-types codegen

echo "[gen-types] Step 2: JSON Schema → Pydantic"
mkdir -p "$PYDANTIC_OUT"

# Generate Pydantic models from each JSON Schema file
for schema_file in "$SCHEMA_DIR"/*.json; do
  [ -f "$schema_file" ] || continue
  base="$(basename "$schema_file" .json)"
  # Sanitize hyphens to underscores for valid Python module names
  module="${base//-/_}"
  output_file="$PYDANTIC_OUT/${module}.py"

  uv run --project services/pipeline \
    datamodel-codegen \
      --input "$schema_file" \
      --input-file-type jsonschema \
      --output "$output_file" \
      --output-model-type pydantic_v2.BaseModel \
      --target-python-version 3.12 \
      --use-standard-collections \
      --use-union-operator

  echo "  → $output_file"
done

# Clean up any dash-case files that datamodel-codegen may have left behind;
# Python cannot import modules with hyphens in their names.
find "$PYDANTIC_OUT" -maxdepth 1 -name '*-*.py' -delete 2>/dev/null || true

# Generate __init__.py that re-exports all generated models
init_file="$PYDANTIC_OUT/__init__.py"
echo '"""Auto-generated Pydantic models from shared-types JSON Schema. DO NOT EDIT."""' > "$init_file"
for py_file in "$PYDANTIC_OUT"/*.py; do
  [ -f "$py_file" ] || continue
  module="$(basename "$py_file" .py)"
  [[ "$module" == "__init__" ]] && continue
  echo "from .${module} import *" >> "$init_file"
done

echo "[gen-types] Done. ${PYDANTIC_OUT}/ updated."
echo "[gen-types] Remember to commit the generated files."

#!/usr/bin/env bash
# Privacy guard (ADR-040): block commits that would re-introduce
# domain-sensitive values into the public repo.
#
# Layer 1 — mapping-free pattern rules (always on):
#   * real-looking 药品批准文号 (国药准字 + digits). The desensitized
#     placeholder form 国药准字Z〔已脱敏〕 does NOT match.
# Layer 2 — optional local denylist (.privacy-denylist.txt, gitignored,
#   one literal term per line, '#' comments allowed). Maintained by the
#   user on their machine only; NEVER committed (it would itself be a
#   sensitive-value list). See ADR-040 §5.
#
# Only STAGED ADDED lines are checked, so removing a sensitive value
# (a redaction commit) always passes.
set -euo pipefail

added=$(git diff --cached --unified=0 --no-color | grep '^+' | grep -v '^+++' || true)
[ -z "$added" ] && exit 0

fail=0

if printf '%s\n' "$added" | grep -qE '国药准字[A-Z]?[0-9]{4,}'; then
  echo "✖ privacy guard: staged diff adds a real-looking 药品批准文号 (国药准字+数字)." >&2
  echo "  Redact to 国药准字X〔已脱敏〕 form before committing (ADR-040)." >&2
  fail=1
fi

if [ -f .privacy-denylist.txt ]; then
  while IFS= read -r term; do
    [ -z "$term" ] && continue
    case "$term" in '#'*) continue ;; esac
    if printf '%s\n' "$added" | grep -qF -- "$term"; then
      echo "✖ privacy guard: staged diff adds a denylisted term (see local .privacy-denylist.txt)." >&2
      fail=1
    fi
  done < .privacy-denylist.txt
fi

exit $fail

#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${TESSERA_V8_BASE_URL:-https://raw.githubusercontent.com/besciaddict/stopwords/tessera-v8-codex-delivery/tessera-v8-builder}"
EXPECTED_SHA256="690963d5637acd7e489ed6b8eb6b4835ffd4c590142f0c44170b3f6e0d566e50"
REQUIRED_BRANCH="tessera-v8-binding-architecture"
METADATA="${TESSERA_GLAUX_METADATA:-/Users/dorrenrodriguez/glaux/metadata.txt}"
REPO="${TESSERA_REPO:-/Users/dorrenrodriguez/Documents/Codex/2026-07-05/run-and-troubleshoot/outputs/tessera_v7_worktree}"
WORK="${TESSERA_V8_DELIVERY_DIR:-${TMPDIR:-/tmp}/tessera-v8-architect-delivery}"
MODE="${1:-install}"

fail() { printf '\nERROR: %s\n' "$*" >&2; exit 1; }
command -v curl >/dev/null 2>&1 || fail "curl is required"
command -v python3 >/dev/null 2>&1 || fail "python3 is required"

rm -rf "$WORK"
mkdir -p "$WORK/parts" "$WORK/extracted"

printf 'Downloading TESSERA v8 architect builder...\n'
for n in 0 1 2 3 4 5 6 7 8; do
  p=$(printf '%03d' "$n")
  curl -fsSL --retry 3 --connect-timeout 20 \
    "$BASE_URL/parts/part_${p}.b64" \
    -o "$WORK/parts/part_${p}.b64"
done
cat "$WORK"/parts/part_*.b64 > "$WORK/builder.tar.xz.b64"

python3 - "$WORK/builder.tar.xz.b64" "$WORK/TESSERA_V8_ARCHITECT_BUILDER_PORTABLE.tar.xz" "$EXPECTED_SHA256" <<'PY'
import base64, hashlib, pathlib, sys
src, dst, expected = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), sys.argv[3]
raw = base64.b64decode(src.read_bytes(), validate=True)
dst.write_bytes(raw)
actual = hashlib.sha256(raw).hexdigest()
if actual != expected:
    raise SystemExit(f"SHA-256 mismatch: expected {expected}, got {actual}")
print(f"Verified archive SHA-256: {actual}")
PY

python3 - "$WORK/TESSERA_V8_ARCHITECT_BUILDER_PORTABLE.tar.xz" "$WORK/extracted" <<'PY'
import pathlib, sys, tarfile
archive, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
with tarfile.open(archive, 'r:xz') as tf:
    root = out.resolve()
    for member in tf.getmembers():
        target = (out / member.name).resolve()
        if root != target and root not in target.parents:
            raise SystemExit(f"unsafe archive path: {member.name}")
    try:
        tf.extractall(out, filter='data')
    except TypeError:
        tf.extractall(out)
print(out)
PY

BUILDER="$WORK/extracted/TESSERA_V8_ARCHITECT_BUILDER_PORTABLE"
[[ -f "$BUILDER/build_architect_pack.py" ]] || fail "builder extraction failed"

if [[ "$MODE" == "download" || "$MODE" == "download-only" ]]; then
  printf '\nBuilder extracted to:\n%s\n\nRead:\n%s\n' "$BUILDER" "$BUILDER/START_HERE_CODEX.md"
  exit 0
fi

[[ -f "$METADATA" ]] || fail "GLAUx metadata not found: $METADATA (set TESSERA_GLAUX_METADATA)"
python3 - <<'PY' || fail "PyYAML is required in the active Python environment"
import yaml
PY

PACK="$WORK/TESSERA_V8_ARCHITECT_REGISTRY_PACK"
printf 'Building architect registry pack from %s...\n' "$METADATA"
(
  cd "$BUILDER"
  TESSERA_GLAUX_METADATA="$METADATA" \
  TESSERA_ARCHITECT_PACK_OUT="$PACK" \
  python3 build_architect_pack.py
)

printf 'Validating architect registry pack...\n'
python3 "$PACK/tools/validate_architect_pack.py" \
  --pack "$PACK" \
  --metadata "$METADATA"

if [[ "$MODE" == "build" || "$MODE" == "build-only" ]]; then
  printf '\nValidated pack created at:\n%s\n' "$PACK"
  exit 0
fi

[[ -d "$REPO" ]] || fail "TESSERA repository not found: $REPO (set TESSERA_REPO)"
git -C "$REPO" rev-parse --is-inside-work-tree >/dev/null 2>&1 || fail "not a git worktree: $REPO"
CURRENT_BRANCH=$(git -C "$REPO" branch --show-current)
if [[ "$CURRENT_BRANCH" != "$REQUIRED_BRANCH" ]]; then
  cat >&2 <<EOF

ERROR: TESSERA worktree is on branch '$CURRENT_BRANCH'.
The architect pack may only be installed on '$REQUIRED_BRANCH'.
Run:
  git -C "$REPO" switch "$REQUIRED_BRANCH"
Then rerun this installer.
EOF
  exit 2
fi

DEST="$REPO/tessera_stylometry/v8/registries/architect_pack_20260730_v1"
if [[ -e "$DEST" ]]; then
  fail "destination already exists: $DEST. Audit it; do not overwrite architect registries silently."
fi

printf 'Installing into %s...\n' "$REPO"
python3 "$PACK/tools/install_into_tessera_repo.py" \
  --pack "$PACK" \
  --repo "$REPO"

cat <<EOF

TESSERA v8 architect registry pack installed successfully.
Repository: $REPO
Destination: $DEST

Binding next steps for Codex:
1. Read $DEST/CODEX_INSTALLATION_DIRECTIVE.md
2. Run the pack validator against $METADATA
3. Do NOT run the full GLAUx foundation/campaign yet.
4. Resolve the critical/high implementation audit findings and Phase 7-10 test gates first.
5. Never redesign or alter architect-authored registry contents.
EOF

# TESSERA v8 Architect Registry Pack — Binding Codex Handoff

This branch temporarily hosts the architect-authored TESSERA v8 registry builder. It is a delivery channel only; the unrelated `stopwords` repository must not be modified beyond this dedicated branch.

## Execute the installer

```bash
curl -fsSL \
  https://raw.githubusercontent.com/besciaddict/stopwords/tessera-v8-codex-delivery/tessera-v8-builder/install.sh \
  | bash
```

The installer:

1. downloads all nine archive chunks;
2. reconstructs the portable builder;
3. verifies SHA-256 `690963d5637acd7e489ed6b8eb6b4835ffd4c590142f0c44170b3f6e0d566e50`;
4. builds the populated registry pack from `/Users/dorrenrodriguez/glaux/metadata.txt`;
5. validates the pack;
6. requires branch `tessera-v8-binding-architecture`;
7. installs the pack into the local TESSERA worktree.

Default worktree:

```text
/Users/dorrenrodriguez/Documents/Codex/2026-07-05/run-and-troubleshoot/outputs/tessera_v7_worktree
```

Override paths when necessary:

```bash
TESSERA_REPO=/absolute/path/to/tessera \
TESSERA_GLAUX_METADATA=/absolute/path/to/metadata.txt \
curl -fsSL \
  https://raw.githubusercontent.com/besciaddict/stopwords/tessera-v8-codex-delivery/tessera-v8-builder/install.sh \
  | bash
```

Download and extract without building or installing:

```bash
curl -fsSL \
  https://raw.githubusercontent.com/besciaddict/stopwords/tessera-v8-codex-delivery/tessera-v8-builder/install.sh \
  | bash -s -- download
```

## Binding restrictions

- Codex builds; Codex does not redesign.
- Do not edit architect-authored historical judgments, target membership, bundles, priors, corpus definitions, passage locators, or Missing Sender specifications.
- Do not run a full GLAUx foundation or campaign until the critical/high implementation-audit findings and Phase 7–10 test gates are resolved.
- Never invent token offsets or token-count reconciliation exceptions.
- Preserve GLAUx-only evidence, offline execution, target exclusion, typed evidence semantics, no global lexical deletion, and sealed-v7 immutability.

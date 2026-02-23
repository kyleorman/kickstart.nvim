# Blockers (must fix before coding)

No blockers

# Ambiguities or missing requirements (questions)

- For Copilot when Node is missing, do you want a one-time INFO notice (current plan) or fully silent disable?
- On NixOS without a given system LSP binary, is a one-time `lspconfig` "cmd not executable" warning acceptable, or should that also be suppressed?

# Minimal patch suggestions to `plan.md` (do not rewrite whole plan)

- In Step 4 Test 3, avoid `string.find(..., 'mason')` (can false-positive); check exact Mason bin path (`vim.fn.stdpath('data') .. '/mason/bin'`) instead.
- In Step 3, use `vim.notify_once(...)` for the missing-Node message to guarantee a single warning per session.
- In manual verification step 1, clarify expected behavior for missing system LSP binaries ("no hard errors" vs "no warnings at all") to match intended acceptance criteria.

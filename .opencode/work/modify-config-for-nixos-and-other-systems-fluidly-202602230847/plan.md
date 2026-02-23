# Goal

Make the Neovim configuration work fluidly on both NixOS and non-Nix systems by implementing platform-aware Mason/LSP configuration that gracefully handles Mason's incompatibility with NixOS's non-FHS environment, while suppressing noisy Copilot/Node startup warnings.

# Non-goals

- Converting the entire config to Nix/home-manager (must remain portable to non-Nix systems)
- Adding nix-ld system-level modifications (out of scope for user config)
- Replacing Mason entirely (useful on non-Nix systems)
- Modifying formatter/linter behavior (out of scope unless currently broken)
- Creating documentation files
- Introducing runtime override flags

# Constraints

- **Languages**: Lua only
- **Neovim version**: 0.10+ (based on kickstart.nvim patterns)
- **Style**: Follow kickstart.nvim conventions
- **Portability**: Config must continue working unchanged on standard Linux, macOS, Windows
- **NixOS detection**: Must be reliable and not cause issues on other systems
- **Single source of truth**: Keep Mason setup in existing `init.lua`

# Definition of Done

- [ ] `nvim --headless -c "q"` runs without LSP startup errors on NixOS
- [ ] NixOS detection utility works correctly
- [ ] Mason does not inject PATH on NixOS (`PATH = 'skip'`), but remains usable manually
- [ ] Mason auto-install is disabled on NixOS, unchanged on non-Nix
- [ ] Copilot warnings are suppressed when Node is unavailable
- [ ] Non-Nix systems: existing Mason behavior is completely unchanged

# Step Plan

## Step 1: Create NixOS detection utility module

**Files to create:**
- `lua/custom/utils/platform.lua` (new)

**Changes:**
- Create a utility module with `M.is_nixos()` function
- Detection method: Check for `/etc/NIXOS` file existence (canonical NixOS indicator)

**Implementation:**
```lua
-- lua/custom/utils/platform.lua
local M = {}

function M.is_nixos()
  return vim.fn.filereadable('/etc/NIXOS') == 1
end

return M
```

**Validation:**
```lua
-- In Neovim:
-- :lua print(require('custom.utils.platform').is_nixos())
-- NixOS: true | Non-Nix: false
```

**Risk notes:** File check is synchronous but minimal overhead; `/etc/NIXOS` is the documented way to detect NixOS.

---

## Step 2: Modify Mason setup in init.lua for NixOS compatibility

**Files to modify:**
- `init.lua` (line ~485, the Mason plugin spec)

**Changes:**
- Set `PATH = 'skip'` on NixOS to prevent Mason from prepending its binaries to PATH
- Keep Mason usable manually (users can still run `:Mason` to install tools)
- Disable `mason-tool-installer` auto-install on NixOS

**Implementation:**
```lua
-- Around line 485, replace:
{ 'mason-org/mason.nvim', opts = {} },

-- With:
{ 'mason-org/mason.nvim', opts = function()
  local is_nixos = require('custom.utils.platform').is_nixos()
  return {
    PATH = is_nixos and 'skip' or 'prepend',
  }
end },
```

For `mason-tool-installer` (around line 807):
```lua
-- Replace the setup call to conditionally install tools
require('mason-tool-installer').setup {
  ensure_installed = require('custom.utils.platform').is_nixos() and {} or ensure_installed
}
```

**Validation:**
- On non-NixOS: `:Mason` shows installed tools, PATH contains Mason bin
- On NixOS: `:Mason` opens without error, Mason bin not in PATH

**Risk notes:** On NixOS, users must install LSP tools via system packages; Mason tools won't be found automatically.

---

## Step 3: Suppress noisy Copilot/Node startup warnings

**Files to modify:**
- `lua/custom/plugins/copilot.lua`

**Changes:**
- Wrap setup in pcall with graceful failure when Node unavailable
- Suppress error notifications, log to `:messages` only
- Keep existing functionality when Node is available

**Implementation:**
```lua
config = function(_, opts)
  local ok, copilot = pcall(require, 'copilot')
  if not ok then
    return
  end
  -- Check for node before attempting setup
  if vim.fn.executable('node') ~= 1 then
    vim.notify('[copilot] Node.js not found in PATH. Copilot disabled.', vim.log.levels.INFO)
    return
  end
  local setup_ok, err = pcall(copilot.setup, opts)
  if not setup_ok then
    vim.notify('[copilot] Setup failed: ' .. tostring(err), vim.log.levels.WARN)
  end
end,
```

**Validation:**
- On NixOS without Node: single INFO notification, no error spam
- With Node available: Copilot works normally

**Risk notes:** May hide legitimate setup errors; ensure they're logged to `:messages`.

---

## Step 4: Integration testing

**Validation commands:**
```bash
# Test 1: Headless startup (both platforms)
nvim --headless -c "lua print('OK')" -c "q" 2>&1 | grep -v "^OK$"
# Expected: no output (no errors)

# Test 2: NixOS detection
nvim --headless -c "lua print(require('custom.utils.platform').is_nixos())" -c "q" 2>&1
# NixOS: prints "true" | Non-Nix: prints "false"

# Test 3: Mason PATH mode (non-NixOS only)
nvim --headless -c "lua print(string.find(vim.env.PATH or '', 'mason') and 'mason-in-path' or 'no-mason')" -c "q" 2>&1
# Non-Nix: "mason-in-path" | NixOS: "no-mason"
```

**Manual verification:**
1. Open a markdown file on NixOS without system `marksman`: `:LspInfo` should show no errors, just no client attached
2. Open same file on non-NixOS: `:LspInfo` should show marksman attached
3. Run `:Mason` on both platforms — should open UI without errors

---

# Risks & Backout Strategy

## Risks

| Risk | Mitigation |
|------|------------|
| Detection false positives | `/etc/NIXOS` is authoritative on NixOS |
| Breaking existing non-Nix setups | All changes gated behind `is_nixos()` checks; default behavior unchanged |
| Missing system LSPs on NixOS | Graceful degradation — no LSP attached rather than error spam |
| Copilot suppression hides real errors | Log to `:messages` for debugging |

## Backout

If issues arise:
1. Remove `lua/custom/utils/` directory
2. In `init.lua`, revert Mason opts to `{ 'mason-org/mason.nvim', opts = {} }`
3. In `init.lua`, revert `mason-tool-installer` setup to use original `ensure_installed`
4. In `lua/custom/plugins/copilot.lua`, revert to original config function

Changes are minimal and localized; removal is straightforward.

---

# Reference: Required Nix Packages (for NixOS users)

```nix
# Example packages for home-manager or configuration.nix
environment.systemPackages = with pkgs; [
  # LSP servers
  marksman
  rust-analyzer
  clang-tools
  pyright
  lua-language-server
  yaml-language-server

  # Formatters (if using conform.nvim)
  stylua
  clang-tools
  black
  isort
  shfmt
  yamlfmt

  # Linters (if using nvim-lint)
  ruff

  # Copilot dependency
  nodejs
];
```

---

# File Summary

| File | Action | Purpose |
|------|--------|---------|
| `lua/custom/utils/platform.lua` | Create | NixOS detection |
| `init.lua` | Modify | Mason PATH mode + conditional auto-install |
| `lua/custom/plugins/copilot.lua` | Modify | Graceful Node failure handling |

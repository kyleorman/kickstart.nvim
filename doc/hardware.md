# Hardware workflows

## SVLS project config
- Copy `doc/svls.toml.example` to your project root as `.svls.toml`.
- Set include paths and defines to match your build system.
- Turn on the built-in svls linter if you want svlint-based checks.

## Linting tools
- SystemVerilog / Verilog: install `verilator` so `nvim-lint` can run it.
- VHDL: install `ghdl` for `nvim-lint` VHDL checks.
- Python: `ruff` is installed via Mason; check `:Mason` if it is missing.

## clangd compile commands
- CMake: `cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`
- Link the file into the project root: `ln -s build/compile_commands.json .`
- Non-CMake: `bear -- make` (or `intercept-build -- make`)

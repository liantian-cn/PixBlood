# Repository Guidelines

## Architecture & Project Structure

PixBlood targets the Blood Death Knight specialization. Use Python 3.13 and PySide6. Keep the design minimal: one project, one rotation, one configuration. Do not introduce multiple rotations or configuration profiles.

- `pix/capture.py`: screenshot algorithms and capture worker.
- `pix/matrix.py`: pixel decoding algorithms.
- `pix/context.py`: turn matrixd data into Python objects.
- `pix/keyboard.py`: keyboard driver.
- `pix/rotation.py`: user-authored rotation.
- `pix/action.py`: action objects and the sequential Action worker.
- `pix/ui.py`: complete PySide6 UI implementation.
- `pix/main.py`: application entry point. `pix/test_captura.py`: one-shot capture diagnostic.
- `pix/lua/`: WoW addon; `core/` contains initialization and configuration, `ui/` contains display components, and `cells/` contains numbered indicators. Fonts and textures live alongside Lua components.
- `layout.md`: cell positions and meanings. `.context/`: accumulated experience and experiment notes; verify historical paths against the current tree.

Python modules implement the third-edition plan. Preserve these module boundaries as implementation proceeds.

## Development & Validation Commands

- `uv sync --python 3.13`: synchronize the local environment and development dependencies.
- `uv run python -m pix.main`: designated application entry point; use Python 3.13.
- `uv run python -m pix.test_captura`: capture and locate once without sending keys.
- `uv run pyright pix`: check types in basic mode.
- `uv run python -m compileall pix`: check Python syntax without launching the application.
- `git diff --check`: check patch whitespace.

Dependencies are maintained in `pyproject.toml` and `uv.lock` using uv. No build pipeline or automated test framework is configured. For addon validation, install the contents of `pix/lua/` into WoW's `Interface/AddOns/PixBlood/`, then use `/reload` in game.

## Coding Style & Naming

Use four-space indentation and LF line endings. For Python, use `snake_case` functions/modules and `PascalCase` classes. Follow neighboring Lua conventions, share addon state through `addonTable`, and preserve initialization order in `PixBlood.toc`. Retain cell names such as `001_enable.lua` and `I01_player_cast_icon.lua`; coordinate position changes with `layout.md`. No formatter or linter is configured.

## Testing Guidelines

No coverage threshold or test naming convention exists. Validate affected behavior in game, including cell colors, layout, and state transitions. Do not add tests for ordinary feature work. Reuse relevant checks; add focused regression cases only after identifying a bug's cause.

## Commits & Pull Requests

History uses concise imperative subjects, sometimes prefixed with `docs:` or `chore:`. Keep changes minimal. Before editing files with uncommitted changes, commit their existing state separately. Commit resulting changes only for edited files; exclude unrelated staged work.

PRs should describe behavior changes, validation performed, and relevant issues. Include screenshots for visible UI changes.

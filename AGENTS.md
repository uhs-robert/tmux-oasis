# tmux-oasis

A tmux theme (16 styles, each with one dark and five light variants) with a status line built from configurable modules. Plain tmux config and bash: no build step, no plugin dependencies.

- Theme files under `themes/` are generated in the sibling `oasis.nvim` repo and copied in with `just sync`. Change colours there, not here.
- The status line is built at config load by `status/build_status.sh` from `@oasis_status_left` / `@oasis_status_right`. Its header comment explains groups, tones and separators. The module contract (`@oasis_module_<name>`, optional `_when`) is in the README's configuration section.
- Built-in modules live in `status/modules/<name>.conf` and use `set -ogq` so users can override them. New modules are opt-in: don't change the default layout lists, and so the default look, without the owner deciding it.

## Conventions

- Shell variables use `snake_case`. No emojis in code (README headings are fine). Comments only say what names can't.
- Conventional Commits with scopes from history (`status`, `theme`, `panes`); bodies explain why. Short, reviewer-focused PR bodies.
- The owner merges PRs. Don't merge without their approval.
- Every user-facing option goes in the README configuration block (`<!-- config:start -->` to `<!-- config:end -->`) with its default. Notable or breaking changes get an entry in What's New.

## Testing

**Never touch the owner's tmux server.** Agent shells usually run inside it, with `$TMUX` pointing at it. Every tmux call must be `env -u TMUX tmux -L <literal-unique-name> ...`, finishing with `kill-server` on that name. The recipes below do this for you, on fixed server names (`oasis-dev`, `oasis-shot`, `oasis-compare-*` and their `-view` viewers).

| Recipe | Does |
|---|---|
| `just sandbox [option=value ...]` / `just sandbox-stop` | Isolated server `oasis-dev` with this checkout loaded. Prints how to attach. |
| `just render` | The sandbox's drawn bar as cells (fg, bg, bold, glyphs as `U+XXXX`), with `#()` output. |
| `just compare [ref] [option=value ...]` | Draws `ref` (default `main`) and the working tree in every scenario and compares cell by cell. |
| `just screenshot [out.png] [option=value ...]` | PNG of the bar in JetBrainsMono Nerd Font (Pillow; `OASIS_FONT` overrides the font). Open it to check contrast and glyphs. |
| `just preview [option=value ...]` / `just restore [option=value ...]` | Prints commands for the owner to preview this checkout on their own tmux, and to undo it. |

Options are `@oasis_*` names with or without the prefix (`separator=round`). The dev recipes default to the `moonlight_dark` flavour; pass `flavor=...` for another.

**Changes to `build_status.sh`, a module or `windows.conf` must keep the default bar identical: run `just compare`.** It covers synchronize-panes and the prefix key table off and on, with the active window custom-named or named "Window".

To let the owner try a change on their own server, run `just preview` and give them its output to run themselves. The preview drops tmux-continuum's autosave hook until they run the output of `just restore` (given the same options).

## Footguns

- **`%` in a status format is a date code**: `printf "%s"` inside `#()` prints the epoch. Format inside scripts, or write `%%`.
- **Commas inside `#{?cond,a,b}` branches split them**, including commas inside `#[...]`. Use one style attribute per `#[...]`, and reference anything with commas through `#{E:@option}`.
- **`set -ogq` values survive reloads.** Changing a built-in module's content needs `tmux set -gu @oasis_module_<name>` first. Users upgrading must restart tmux once.
- **Private-use glyphs (Nerd Font and powerline icons) can vanish from an agent's output**, including when a `\uXXXX` escape gets turned into the glyph by a heredoc or a file-writing tool. Store them as byte escapes that stay escapes, e.g. `$'\xee\x82\xb0'` in bash, which also works on macOS's bash 3.2. Verify with a codepoint dump.
- **`display -p` does not run `#()` jobs**, so script-backed content is empty there. `just render` shows the drawn bar.
- **`#()` runs every `status-interval` per client.** Scripts must return in well under 100 ms and never sleep.
- **`run-shell` expands formats**, so a `#(...)` passed through it runs instead of being stored.

## Planning files

Root-level Markdown files other than `README.md`, `AGENTS.md` and `CLAUDE.md` are gitignored for the owner's notes (`ROADMAP.md`, `todo.md`, ...). Check for them when picking up work. They exist only in the main checkout, not in worktrees or clones.

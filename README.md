# Doom Emacs config

Private Doom config for `~/.config/doom`. Built against **Emacs 30.2**,
doomemacs `v2.2.4-13-g01d68aaf`, doom+ modules `26.09.0`.

## Layout

| File | Purpose |
|---|---|
| `init.el` | enabled modules and flags |
| `packages.el` | extra packages and pins |
| `config.el` | personal settings, keybindings, per-language setup |
| `custom.el` | Customize-generated (leave alone) |
| `OFFLINE-WINDOWS.md` | installing this on an air-gapped Windows PC |
| `scripts/make-offline-bundle.sh` | builds the offline package bundle |

## Install (machine with network)

```bash
git clone https://github.com/doomemacs/doomemacs ~/.config/emacs
git clone <this-repo> ~/.config/doom
~/.config/emacs/bin/doom install
```

For an air-gapped target, see [OFFLINE-WINDOWS.md](OFFLINE-WINDOWS.md) instead.

## Python

`basedpyright` (LSP) + `ruff` (lint/format on save via apheleia) + `uv` + `pytest`.
Two load-order constraints are load-bearing and documented inline in `config.el`
— read those comments before touching the Python block:

- `lsp-pyright-langserver-command` is set at **top level**, not in `after!`.
  lsp-pyright bakes the value into its `lsp-dependency` at load time, so
  setting it late leaves pyright unable to launch and lsp-mode silently falls
  back to the ruff server: you get lints but **no type checking**.
- The ruff flycheck chain attaches from `lsp-diagnostics-mode-hook`. The `lsp`
  checker is created lazily when a server attaches; calling
  `flycheck-add-next-checker` earlier errors, and that error propagates through
  `lsp!` and aborts Python LSP startup entirely.

Sanity check: open a `.py` file with a type error and confirm **two** LSP
workspaces (`pyright:NNNNN ruff:NNNNN`), not just `ruff`.

## Notes

- Emacs runs as a daemon; restart it after every `doom sync`.
- `:lang latex`, `matlab`, `julia`, `fortran`, `cc`, `dart`, `plantuml` each
  need their own external toolchain.

# Installing this Doom config on an air-gapped Windows PC

This repo holds **only the private config** (~200 KB of `.el`). Doom itself and
its ~300 packages are *not* here. A machine that can never reach the network
cannot run `doom install`, so everything must arrive by USB.

The transfer has three parts:

| Part | Size | Where it comes from |
|---|---|---|
| 1. This config | ~200 KB | `git clone` this repo (on an online machine) |
| 2. Doom + all package repos | ~1.3 GB | `scripts/make-offline-bundle.sh`, run on the Linux box |
| 3. Windows binaries | ~200 MB | downloaded by hand on an online Windows machine |

## Pinned versions

Reproduce these exactly or the pins in `packages.el` will not match:

| Component | Version / commit |
|---|---|
| Emacs | **30.2** |
| doomemacs | `01d68aaf` (`v2.2.4-13-g01d68aaf`) — <https://github.com/doomemacs/doomemacs> |
| doom+ modules | `d57ab52a3` (release `26.09.0`) — <https://github.com/doomemacs/modules> |

Emacs **must** be 30.2. Packages are byte-compiled per Emacs version into
`build-<version>/`; a different Emacs triggers a full rebuild, which is fine
offline, but a *major* version difference can break pinned packages.

---

## Part 1 — On the Linux box: build the bundle

```bash
./scripts/make-offline-bundle.sh /run/media/$USER/USBSTICK
```

This produces `doom-offline-bundle.tar.zst` containing `~/.config/emacs` with
the platform-specific artifacts stripped:

- **included**: doomemacs source, `sources/doom+`, and all 296 pre-cloned
  package repos under `.local/straight/repos/` — this is what removes the need
  for network access.
- **excluded**: `build-30.2/` and `build-30.0.60/` (Linux byte-code, Windows
  rebuilds these), `eln-cache/` (native code, *not* portable), `.local/cache/`,
  `.local/state/`, and `.local/env` (a dump of this machine's Linux `PATH` —
  copying it to Windows would poison `exec-path`).

### Or: download the prebuilt bundle

A prebuilt bundle is published as a **release asset** (it is 835 MB, far past
GitHub's 100 MB per-file limit for tracked files, so it is not in the repo):

<https://github.com/fatihyaman661/doomNobara/releases>

Current build:

| | |
|---|---|
| File | `doom-offline-bundle.tar.zst` |
| Size | 875,068,405 bytes (835 MB) — 1.1 GB uncompressed |
| SHA-256 | `8b502fae0a302cbb93c2b0060d81fd387f1a0690961e4b58f0056f7c0abfdb06` |
| Emacs | 30.2 |
| doomemacs | `01d68aaf6bd7db073365385cd82e1ad7e815295c` |
| doom+ | `d57ab52a3425b6d39564fb011b0e9571da0e270f` |
| Package repos | 296 |

Verify it after copying, **before** trusting a 24-hour offline install to it:

```bash
# Linux
sha256sum -c doom-offline-bundle.tar.zst.sha256
```

```cmd
:: Windows
certutil -hashfile doom-offline-bundle.tar.zst SHA256
```

The archive also carries `emacs/BUNDLE-MANIFEST.txt`, recording the exact
commits and repo count it was built from.

## Part 2 — On an online Windows machine: fetch binaries

Download these, then copy them to the USB stick. Versions are what this config
expects; newer patch releases are fine.

| Tool | Where | Required? |
|---|---|---|
| Emacs 30.2 (x86_64) | <https://ftp.gnu.org/gnu/emacs/windows/emacs-30/> | **yes** |
| Git for Windows (portable `.7z.exe` is easiest) | <https://git-scm.com/download/win> | **yes** — Doom shells out to git |
| ripgrep (`x86_64-pc-windows-msvc.zip`) | <https://github.com/BurntSushi/ripgrep/releases> | **yes** — search is broken without it |
| fd (`x86_64-pc-windows-msvc.zip`) | <https://github.com/sharkdp/fd/releases> | strongly recommended |
| Python 3.13 or 3.14 | <https://www.python.org/downloads/windows/> | for the Python setup |
| ruff (`ruff-x86_64-pc-windows-msvc.zip`) | <https://github.com/astral-sh/ruff/releases> | Python lint/format |
| uv (`uv-x86_64-pc-windows-msvc.zip`) | <https://github.com/astral-sh/uv/releases> | Python envs |

For **basedpyright** (the Python LSP), on the online Windows machine with the
*same* Python version as the target:

```cmd
pip download basedpyright -d basedpyright-wheels
```

Copy that folder across; install it offline in Part 3.

Optional, only if you want those languages to work: a TeX distribution
(MiKTeX) for `:lang latex`, Java + `plantuml.jar` for `:lang plantuml`,
and Hunspell plus dictionaries for `:checkers spell`.

## Part 3 — On the air-gapped Windows PC

Doom resolves `~` from `HOME`. Set it once, system-wide, so `~/.config/emacs`
is unambiguous:

```cmd
setx HOME "%USERPROFILE%"
```

Open a **new** terminal (so `HOME` is live), then:

1. Install Emacs 30.2 and Git. Put `rg.exe`, `fd.exe`, `ruff.exe`, `uv.exe`
   somewhere on `PATH` — e.g. `%USERPROFILE%\bin` added via `setx PATH`.
2. Extract the bundle so that Doom lands at `%HOME%\.config\emacs`:
   ```cmd
   tar -xf doom-offline-bundle.tar.zst -C "%HOME%\.config"
   ```
   (Windows 10+ `tar` handles zstd. If not, extract with 7-Zip.)
3. Put this config at `%HOME%\.config\doom` — copy the clone from Part 1.
4. Install the Python LSP offline:
   ```cmd
   pip install --no-index --find-links basedpyright-wheels basedpyright
   ```
5. Build it, **without** `-u`:
   ```cmd
   %HOME%\.config\emacs\bin\doom.cmd sync
   ```

> **Never run `doom sync -u` or `doom upgrade` on this machine.** Both fetch
> from the network. Plain `doom sync` only checks out the commits already in
> `.local/straight/repos`, which is exactly why the bundle works offline.

First sync takes a while — it byte-compiles ~300 packages and native-compiles
from scratch. Then:

```cmd
%HOME%\.config\emacs\bin\doom.cmd doctor
```

## What will not work offline on Windows

Be aware of these before you start; none of them break the editor, they just
degrade specific modules.

- **`tree-sitter`** — Emacs 30 needs grammar **`.dll`**s, and builds them from
  source with a C compiler and network access. Offline you must supply
  prebuilt `.dll`s in `~/.config/emacs/.local/etc/tree-sitter/`. Python still
  works: `python-ts-mode` falls back to `python-mode` if the grammar is absent.
  The bundled MATLAB grammar here is a Linux `.so` (`glnxa64`) and is useless
  on Windows.
- **`pdf-tools`** — needs `epdfinfo.exe`, which normally compiles under MSYS2.
  Get a prebuilt binary or expect `:tools pdf` to fail.
- **`:lang latex` / `plantuml` / `matlab` / `julia` / `fortran` / `cc` /
  `dart`** — each needs its own external toolchain installed separately.
- **`:checkers spell`** — needs Hunspell plus dictionaries on `PATH`.
- **`magit-delta`** — needs `delta.exe`; magit works fine without it.

## Keeping the two machines in sync

Edit config here, commit, push. On the Windows side, since it cannot pull,
re-copy `config.el` / `init.el` / `packages.el` by USB. If you change
`packages.el` to add a *new* package, the Windows box has no way to fetch it —
rebuild the bundle on Linux (after a `doom sync` here) and re-transfer.

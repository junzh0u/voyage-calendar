# AGENTS.md — voyage-calendar

- The whole program is the single stdlib-only file `voyage-calendar`; its docstring is the reference for configuration, modes, and the Kindle's BusyBox quirks. Keep it accurate when behavior changes.
- Tests live in the file behind `--test`; `just check` lints and runs them. The Chrome screenshot test runs only where a Chrome or Chromium is found.
- The shell that runs on the Kindle (`KEEPER_SH`, `REMOTE_SHOW`, `REMOTE_RESTORE`) targets BusyBox `sh` on a jailbroken Kindle with USBNetwork: no bashisms, `timeout -t N`, `pidof` from busybox.
- Never run the default (painting) mode against the Kindle from a test; `--dry-run --png` renders without touching the device.
- Never commit `.env`: the feed URLs are credentials. The Kindle's ssh key lives outside the repo, at `~/.ssh/kindle_voyage`.
- `just install` loads a launch agent that paints the Kindle from this checkout every 10 minutes, so uncommitted edits to `voyage-calendar` reach the device within one round.

# voyage-calendar

Turns a jailbroken Kindle Voyage into an always-on wall calendar for Google Calendar. A launch agent on a Mac fetches the calendars' secret iCal feeds every ten minutes, renders the coming week as a page sized for the Voyage's 300 ppi panel, screenshots it with headless Chrome, and pushes the image to the Kindle over SSH, where FBInk paints it.

The layout: today in detail, the next days compact, the month grid, and a footer with the last update time. What is already over today collapses into one line so the rest keeps its room; a week that does not fit says how far it got. `--rotate DEG` says how far the Kindle is turned clockwise from upright: 180 flips the portrait page, and 90 (top edge to the right) or 270 (top edge to the left) split it into two columns for a Kindle lying on its side, where what of today the left column cannot hold leads the right column as "Today, continued", printed like any other day.

The push also turns the Kindle into a kiosk: the reader framework is stopped so nothing repaints over the calendar, the device is kept from sleeping, and a small keeper loop left on the Kindle brings Wi-Fi back whenever it drops. `--restore` hands the reader UI back; a reboot does the same on its own.

## The Kindle

- Jailbroken, with the [USBNetwork](https://wiki.mobileread.com/wiki/USBNetwork) package for SSH and its bundled FBInk, reachable over Wi-Fi from the Mac.
- A private key that logs in as `root`. Only that key is offered (Dropbear caps auth attempts).

## Run

```sh
cp env.example .env                          # feed URLs, your address, the Kindle's address
just install                                 # load the launch agent: a check now and every minute
tail -f ~/Library/Logs/voyage-calendar.log
```

The agent (`launchd.plist`, installed as `~/Library/LaunchAgents/io.github.junzh0u.voyage-calendar.plist`) runs `./voyage-calendar --rotate 90` from this checkout with the system Python and Google Chrome, so whatever is checked out is what the Kindle shows. Rerun `just install` after moving the checkout; `launchctl bootout gui/$(id -u)/io.github.junzh0u.voyage-calendar` stops it.

The Kindle's host key is accepted on first contact and pinned under `cache/`, next to the last good copy of each feed, which serves when a fetch fails (the footer says so).

The variables in `.env`, sourced by `sh` (keep the feed list quoted) and read by the program itself:

| Variable | Description |
|---|---|
| `VOYAGE_CALENDAR_ICS_URLS` | whitespace-separated secret iCal feed URLs (Google Calendar → Settings → the calendar → "Secret address in iCal format") |
| `VOYAGE_CALENDAR_EMAIL` | optional: your address, so invitations you declined are dropped |
| `VOYAGE_CALENDAR_HOST` | the Kindle's address, or `user@address` (the user defaults to `root`) |
| `TZ` | optional: the zone the agenda is rendered in (default: the Mac's) |

To give the Kindle back to the reader UI:

```sh
launchctl bootout gui/$(id -u)/io.github.junzh0u.voyage-calendar
just push --restore
```

## Elsewhere

`voyage-calendar` is one stdlib-only Python file; it needs Python 3, a Chrome or Chromium, and an ssh client. `--every 60 --heartbeat 60` repaints forever without a scheduler, at once when the page changes and on the hour otherwise. `./voyage-calendar --help` lists every variable and mode. It looks for `chrome-headless-shell` under `~/.cache/puppeteer` (where `just install` puts it) or on `PATH`, then Google Chrome on macOS, then `chromium` or `google-chrome` on `PATH`; without `VOYAGE_CALENDAR_SSH_KEY` it relies on your ssh config for the host.

```sh
./voyage-calendar --dry-run --rotate 90 --png out.png   # render without touching the Kindle
./voyage-calendar --rotate 90                           # one push
```

## Development

```sh
just check      # ruff + the built-in tests (./voyage-calendar --test)
just push       # one push now with the agent's .env, key and cache, instead of waiting for its next round
just render     # dry run: render the page upright to render.png (or `just render PATH`); never touches the Kindle
```

Recurrence covers what Google Calendar writes: DAILY, WEEKLY, MONTHLY (by day of month or ordinal weekday), YEARLY, with INTERVAL, COUNT, UNTIL, EXDATE, RDATE, and per-instance overrides (moved and cancelled instances). Unsupported rules degrade to the first occurrence.

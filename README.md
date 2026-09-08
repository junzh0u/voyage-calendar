# voyage-calendar

Turns a jailbroken Kindle Voyage into an always-on wall calendar for Google Calendar. A container fetches the calendars' secret iCal feeds every ten minutes, renders the coming week as a page sized for the Voyage's 300 ppi panel, screenshots it with headless Chromium, and pushes the image to the Kindle over SSH, where FBInk paints it.

The layout: today in detail, the next days compact, the month grid with busy days marked, and a footer with the last update time. What is already over today collapses into one line so the rest keeps its room; a week that does not fit says how far it got. `--landscape` splits the page into two columns for a Kindle lying on its side, top edge to the left.

The push also turns the Kindle into a kiosk: the reader framework is stopped so nothing repaints over the calendar, the device is kept from sleeping, and a small keeper loop left on the Kindle brings Wi-Fi back whenever it drops. `--restore` hands the reader UI back; a reboot does the same on its own.

## The Kindle

- Jailbroken, with the [USBNetwork](https://wiki.mobileread.com/wiki/USBNetwork) package for SSH and its bundled FBInk, reachable over Wi-Fi from the Docker host.
- A private key that logs in as `root`. Only that key is offered (Dropbear caps auth attempts).

## Run

```sh
cp env.example .env             # feed URLs, your address, the Kindle's address, TZ
cp ~/.ssh/kindle_voyage .       # the Kindle's private key; mounted read-only
docker compose up -d            # pulls ghcr.io/junzh0u/voyage-calendar:latest, built by CI on every push to main
docker compose logs -f
```

The Kindle's host key is accepted on first contact and pinned under `cache/`, next to the last good copy of each feed, which serves when a fetch fails (the footer says so).

The variables in `.env`, all read by the program itself:

| Variable | Description |
|---|---|
| `VOYAGE_CALENDAR_ICS_URLS` | whitespace-separated secret iCal feed URLs (Google Calendar → Settings → the calendar → "Secret address in iCal format") |
| `VOYAGE_CALENDAR_EMAIL` | optional: your address, so invitations you declined are dropped |
| `VOYAGE_CALENDAR_HOST` | the Kindle's address, or `user@address` (the user defaults to `root`) |
| `TZ` | the zone the agenda is rendered in |

To give the Kindle back to the reader UI:

```sh
docker compose run --rm voyage-calendar --restore
```

## Without Docker

`voyage-calendar` is one stdlib-only Python file; it needs a Chrome or Chromium and an ssh client. `./voyage-calendar --help` lists every variable and mode. It looks for Google Chrome on macOS, then `chromium` or `google-chrome` on `PATH`; without `VOYAGE_CALENDAR_SSH_KEY` it relies on your ssh config for the host.

```sh
./voyage-calendar --dry-run --landscape --png out.png   # render without touching the Kindle
./voyage-calendar --landscape                           # one push
```

## Development

```sh
just check      # ruff + the built-in tests (./voyage-calendar --test)
just push       # one push from this checkout with the .env settings, to preview a layout change on the Kindle
docker build -t voyage-calendar . && docker run --rm --env-file .env -v $PWD:/out voyage-calendar --dry-run --landscape --png /out/out.png
```

Recurrence covers what Google Calendar writes: DAILY, WEEKLY, MONTHLY (by day of month or ordinal weekday), YEARLY, with INTERVAL, COUNT, UNTIL, EXDATE, RDATE, and per-instance overrides (moved and cancelled instances). Unsupported rules degrade to the first occurrence.

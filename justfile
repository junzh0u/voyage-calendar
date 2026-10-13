set dotenv-load

default: check

# Lint and run the built-in tests
check:
    uvx ruff check voyage-calendar
    ./voyage-calendar --test

# Apply automatic lint fixes
fix:
    uvx ruff check --fix voyage-calendar

# Install the launch agent (launchd.plist) that paints the Kindle from this
# checkout at login and every 10 minutes, with .env and cache/ beside it and
# the Kindle's key at ~/.ssh/kindle_voyage; it logs to
# ~/Library/Logs/voyage-calendar.log. Rerun after moving the checkout or
# editing the plist.
install:
    #!/bin/sh
    set -eu
    label=io.github.junzh0u.voyage-calendar
    plist="$HOME/Library/LaunchAgents/$label.plist"
    sed -e "s|@DIR@|{{ justfile_directory() }}|g" -e "s|@HOME@|$HOME|g" launchd.plist > "$plist"
    plutil -lint -s "$plist"
    launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$plist"
    echo "loaded $label; tail -f ~/Library/Logs/voyage-calendar.log"

# Paint the Kindle once now from this checkout, with the same .env, key and
# cache as the launch agent, instead of waiting for its next round
push *args:
    VOYAGE_CALENDAR_SSH_KEY="$HOME/.ssh/kindle_voyage" VOYAGE_CALENDAR_CACHE_DIR=cache ./voyage-calendar --rotate 90 {{ args }}

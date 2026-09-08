set dotenv-load

default: check

# Lint and run the built-in tests
check:
    uvx ruff check voyage-calendar
    ./voyage-calendar --test

# Apply automatic lint fixes
fix:
    uvx ruff check --fix voyage-calendar

# Render from this checkout and paint the Kindle once, with the feeds, host
# and TZ from .env. ssh needs a ~/.ssh/config entry for that host carrying
# the Kindle's key. The container (compose.yaml) keeps repainting from its
# image every 10 minutes, so a local push only previews an unreleased layout.
push *args:
    ./voyage-calendar --landscape {{ args }}

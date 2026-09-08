default: check

# Lint and run the built-in tests
check:
    uvx ruff check voyage-calendar
    ./voyage-calendar --test

# Apply automatic lint fixes
fix:
    uvx ruff check --fix voyage-calendar

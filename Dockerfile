FROM python:3.13-slim

# chromium renders the page; fonts-liberation stands in for the Helvetica/Arial
# the page asks for and fonts-dejavu-core covers the symbols event titles carry
# (✈, →); openssh-client pushes to the Kindle; tzdata lets zoneinfo resolve the
# feeds' TZIDs and TZ set the local zone.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        chromium fonts-liberation fonts-dejavu-core openssh-client tzdata \
    && rm -rf /var/lib/apt/lists/*

ENV VOYAGE_CALENDAR_CHROME=/usr/bin/chromium \
    VOYAGE_CALENDAR_CACHE_DIR=/cache \
    VOYAGE_CALENDAR_SSH_KEY=/ssh/kindle_voyage \
    PYTHONUNBUFFERED=1

COPY voyage-calendar /usr/local/bin/voyage-calendar

VOLUME /cache
ENTRYPOINT ["voyage-calendar"]
CMD ["--every", "600"]

#!/usr/bin/env bash

#export LC_ALL=C.UTF-8
export LC_NUMERIC=C.UTF-8

##
# Print Settings
##

echo "PHOTIUS_VERSION: $PHOTIUS_VERSION"
echo "TZ: $TZ"
echo "SRC_DIR: ${SRC_DIR}"
echo "TEMP_DIR: ${TEMP_DIR}"
echo "DEST_DIR: ${DEST_DIR}"
echo "PHOTIUS_SKIP_PICTURES: ${PHOTIUS_SKIP_PICTURES}"
echo "PHOTIUS_SKIP_VIDEOS: ${PHOTIUS_SKIP_VIDEOS}"
echo "PHOTIUS_FAILURE_THRESHOLD: ${PHOTIUS_FAILURE_THRESHOLD}s"
echo "PHOTIUS_ALLDATES_FROM_PROCESSINGDATE: ${PHOTIUS_ALLDATES_FROM_PROCESSINGDATE}"
echo "PHOTIUS_RENAME_PROCESSINGDATE: ${PHOTIUS_RENAME_PROCESSINGDATE}"
echo "PHOTIUS_RENAME_DATETIMEORIGINAL: ${PHOTIUS_RENAME_DATETIMEORIGINAL}"

##
# Main Loop
##

while true
do
  echo "[$(date)] Scanning for new files."
  echo $(date +%s) > /tmp/healthcheck

  # We do not process hidden files or files with non-standard filename format
  # as lots of sync/upload applications use hidden files (i.e. syncthing or webdav).
  # For the same reason, just to be sure, we want to be sure each file to be
  # at least three seconds (3/60) old in our local filesystem before we process it.

  find "$SRC_DIR" -type f -cmin +0.05 ! -iname '.*' -iname '*.*' -printf "%T@ %p\n" | sort -n | cut -d' ' -f2- | while read FILE; do
    REL_PATH="${FILE#"$SRC_DIR"}"
    if echo "$REL_PATH" | grep -vq '\/\.'; then
      # echo "$FILE"
      sleep 1.5
      /photius-helper.sh "$FILE"
    fi
  done

  echo "[$(date)] Scan completed."
  sleep 12
done

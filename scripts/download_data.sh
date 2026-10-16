#!/usr/bin/env bash
# Download PhysioNet/CinC Challenge 2019 training sets A and B into data/.
# Resumable: re-run after an interruption; finished files are skipped.
# The file list comes from physionet.org; the files themselves come from PhysioNet's
# official open S3 mirror (listed on the dataset page), which is much faster per file.
set -euo pipefail

LISTING="https://physionet.org/files/challenge-2019/1.0.0/training"
BASE="https://physionet-open.s3.amazonaws.com/challenge-2019/1.0.0/training"
DEST="${1:-data}"
BATCH="${BATCH:-500}"
status=0

for SET in training_setA training_setB; do
  mkdir -p "$DEST/$SET"
  manifest="$DEST/$SET.manifest"
  if [ ! -s "$manifest" ]; then
    curl -sS --fail --retry 5 --retry-all-errors --retry-delay 5 "$LISTING/$SET/" \
      | grep -oE 'href="p[0-9]+\.psv"' | sed -E 's/href="(.*)"/\1/' > "$manifest.tmp"
    mv "$manifest.tmp" "$manifest"
  fi
  total=$(wc -l < "$manifest" | tr -d ' ')
  echo "$SET: $total files listed"

  # Files are staged and moved into place only after curl exits, so anything in
  # $DEST/$SET is complete. A leftover staging folder is from an interrupted run.
  staging="$DEST/$SET.staging"
  rm -rf "$staging"
  mkdir -p "$staging"
  comm -23 <(sort "$manifest") <(ls "$DEST/$SET" | sort) | split -l "$BATCH" - "$staging/batch."

  for batch in "$staging"/batch.*; do
    [ -e "$batch" ] || continue
    awk -v b="$BASE/$SET" -v s="$staging" \
      '{ printf "url = \"%s/%s\"\noutput = \"%s/%s\"\n", b, $0, s, $0 }' "$batch" > "$batch.cfg"
    # One curl process per batch reuses its connections instead of opening one per file.
    # Timeouts stop a dropped connection from hanging forever; the retry picks it up.
    curl -sS --fail --retry 5 --retry-all-errors --retry-delay 2 --remove-on-error \
      --connect-timeout 15 --max-time 60 \
      --parallel --parallel-max 8 -K "$batch.cfg" || echo "$SET: some transfers in $(basename "$batch") failed"
    for f in "$staging"/*.psv; do
      [ -e "$f" ] && mv "$f" "$DEST/$SET/"
    done
    echo "$SET: $(ls "$DEST/$SET" | grep -c '\.psv$')/$total"
  done
  rm -rf "$staging"

  missing=$(comm -23 <(sort "$manifest") <(ls "$DEST/$SET" | sort) | wc -l | tr -d ' ')
  if [ "$missing" -gt 0 ]; then
    echo "$SET: $missing files still missing; re-run to resume"
    status=1
  fi
done

exit "$status"

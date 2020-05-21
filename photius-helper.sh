#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "Illegal number of parameters"
    exit 2
fi

src="$1"

echo "[$(date +%s.%N)] Processing $src"
echo $(date +%s) > /tmp/healthcheck
date1=$(date +%s%N)

src_path=$(dirname -- "$src")
src_file=$(basename -- "$src")
src_name="${src_file%.*}"
src_ext="${src_file##*.}"
src_ext=${src_ext,,} # convert file extension to lower-case

case $src_ext in
  jpg|jpeg|jpe)
  exiftran -ai "$src"
  jpegoptim -m90 "$src"
  dest="$TEMP_DIR/$src_name.jpg"
  cp "$src" "$dest"
  exit_code=$?
  ;;
  png)
  # @todo: choice with optipng
  # currently, we just convert png into jpg, store it in the src dir and fail gracefully with EX_TEMPFAIL (/usr/include/sysexits.h)
  dest="$SRC_DIR/$src_name.jpg"
  convert "$src" "$dest" && rm "$src"
  exit_code=75  # EX_TEMPFAIL
  ;;
  mp4|m4p|m4v|mpg|mpeg|mpe|mpv|avi|wmv|mov|qt|3gp|flv|swf|webm|avchd)
  hevc_flag=$(ffprobe "$src" 2>&1 >/dev/null | grep 'hevc')
  if [[ -z "$hevc_flag" ]]; then
    dest="$TEMP_DIR/$src_name.mp4"
    # threads option should be the last one.
    ffmpeg -y -i "$src" -c:v libx265 -tag:v hvc1 -threads 1 "$dest"
    exit_code=$?
  else
    dest="$TEMP_DIR/$src_name.$src_ext"
    cp "$src" "$dest"
    exit_code=$?
  fi
  ;;
  *)
  dest="$TEMP_DIR/$src_name.$src_ext"
  cp "$src" "$dest"
  exit_code=$?
  ;;
esac

echo "$src_name.$src_ext -> $dest"

if [ $exit_code -eq 0 ]; then
  exiftool -v0 -overwrite_original -TagsFromFile "$src" -Alldates "$dest"
  rm "$src"
  exiftool -overwrite_original -all= -tagsfromfile @ -all:all -unsafe -icc_profile --makernotes "$dest" # Sanitizing EXIF
  if [[ -z $(exiftool -p '$dateTimeOriginal' -q "$dest") ]]; then
    exiftool -overwrite_original "-alldates<filename" "$dest"
  fi
  if [[ -z "$(echo "$src_name" | grep -E '.*[0-9]{8}_[0-9]{6}_IMG_.*')" ]]; then
    exiftool -v -d "$DEST_DIR/%Y/%m/%d/%%f%%-c.%%le" '-FileName<DateTimeOriginal' "$dest"
  else
    # Rename Google Camera's photoboost pictures
    exiftool -v -d "$DEST_DIR/%Y/%m/%d/%Y%m%d_%H%M%S_Burst%%-c.%%le" '-FileName<DateTimeOriginal' "$dest"
  fi
  echo "success"
else
  echo "failed ($exit_code)"
fi

diff=$(echo "($(date +%s%N) - $date1)/1000000" | bc -l)
echo "Completed in $diff milliseconds."

exit $exit_code

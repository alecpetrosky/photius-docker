#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "Illegal number of parameters"
    exit 2
fi

src="$1"
tag="$(echo "$src" | xargs basename)"

echo "[$(date +%s.%N)] Processing $src"
echo $(date +%s) > /tmp/healthcheck
date1=$(date +%s%N)

# We should rename file before making any changes if RENAME_WITH_FILEMODIFYDATE
if [[ ${PHOTIUS_ENFORCE_FILEMODIFYDATE:-0} == "1" ]]; then
  temp="%Y%m%d_%H%M%S_${tag}%%-c.%%le"
  echo "Renaming $src to $temp"
  exiftool -v -d "$temp" \
    '-FileName<FileModifyDate' \
    "$src"
  exiftool -overwrite_original "-alldates<filename" "$temp"
  src="$temp"
fi

src_path=$(dirname -- "$src")
src_file=$(basename -- "$src")
src_name="${src_file%.*}"
src_ext="${src_file##*.}"
src_ext=${src_ext,,} # convert file extension to lower-case

# Original file's md5sum which we'll use as “Image Unique ID” EXIF field
src_md5=$(md5sum "$src" | awk '{print $1}')

case $src_ext in
  jpg|jpeg|jpe)
  if [[ $PHOTIUS_SKIP_PICTURES == "1" ]]; then
    echo "Skipping $src due to PHOTIUS_SKIP_PICTURES"
    exit 0
  fi
  exiftran -ai "$src"
  jpegoptim -m90 "$src"
  temp="$TEMP_DIR/$src_name.jpg"
  cp "$src" "$temp"
  exit_code=$?
  ;;
  png)
  if [[ $PHOTIUS_SKIP_PICTURES == "1" ]]; then
    echo "Skipping $src due to PHOTIUS_SKIP_PICTURES"
    exit 0
  fi
  optipng -fix "$src"
  temp="$TEMP_DIR/$src_name.png"
  cp "$src" "$temp"
  exit_code=$?
  ;;
  mp4|m4p|m4v|mpg|mpeg|mpe|mpv|avi|wmv|mov|qt|3gp|flv|swf|webm|avchd)
  if [[ $PHOTIUS_SKIP_VIDEOS == "1" ]]; then
    echo "Skipping $src due to PHOTIUS_SKIP_VIDEOS"
    exit 0
  fi
  hevc_flag=$(ffprobe "$src" 2>&1 >/dev/null | grep 'hevc')
  if [[ -z "$hevc_flag" ]]; then
    temp="$TEMP_DIR/$src_name.mp4"
    # threads option should be the last one.
    ffmpeg -y -i "$src" -c:v libx265 -tag:v hvc1 -threads 1 "$temp"
    exit_code=$?
  else
    temp="$TEMP_DIR/$src_name.$src_ext"
    cp "$src" "$temp"
    exit_code=$?
  fi
  ;;
  *)
  temp="$TEMP_DIR/$src_name.$src_ext"
  cp "$src" "$temp"
  exit_code=$?
  ;;
esac

echo "$src_name.$src_ext -> $temp"

if [ $exit_code -eq 0 ]; then
  exiftool -v0 -overwrite_original -TagsFromFile "$src" -Alldates "$temp"
  rm "$src"
  exiftool -overwrite_original -all= -tagsfromfile @ -all:all -unsafe -icc_profile --makernotes "$temp" # Sanitizing EXIF
  exiftool -overwrite_original -imageuniqueid="$src_md5" "$temp"
  if [[ -z $(exiftool -p '$dateTimeOriginal' -q "$temp") ]]; then
    exiftool -overwrite_original "-alldates<filename" "$temp"
  fi
  if [[ -z $(exiftool -p '$gpstimestamp' -q "$temp") || -z $(exiftool -p '$gpsdatestamp' -q "$temp") ]]; then
    tz=$(date +%:z)
    exiftool -overwrite_original '-gpstimestamp<${datetimeoriginal}'"$tz" '-gpsdatestamp<${datetimeoriginal}'"$tz" "$temp"
  fi
  dest="$DEST_DIR/%Y/%m/%d/%%f%%-c.%%le"
  if [[ -n "$(echo "$src_name" | grep -E '.*[0-9]{8}_[0-9]{6}_IMG_.*')" ]]; then
    # Rename Google Camera's photoboost pictures
    dest="$DEST_DIR/%Y/%m/%d/%Y%m%d_%H%M%S_Burst%%-c.%%le"
  fi
  exiftool -v -d "$dest" \
    '-FileName<FileModifyDate' \
    '-FileName<ModifyDate' \
    '-FileName<CreateDate' \
    '-FileName<DateTimeOriginal' \
    "$temp"
  echo "success"
else
  echo "failed ($exit_code)"
fi

diff=$(echo "($(date +%s%N) - $date1)/1000000" | bc -l)
echo "Completed in $diff milliseconds."

exit $exit_code

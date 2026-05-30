#!/bin/bash
# Created by Vonvakva Flucio, discord dav684t      
# Automatic archiver

show_version() {
echo "Version: 1.0-anytime-it-will-break"
exit 0
}

show_help() {
    echo "Monanegra Archiver - Created by  Vonvakva Flucio"
    echo "==============================================="
    echo "Usage: ./template.sh \"<search term>\" <DATE_YYYYMMDD> <Quantity>"
    echo ""
    echo "Arguments:"
    echo "  1. Search term : What you want to search on youtube "
    echo "  2. Limit date    : Download videos only until this date (Format: YYYYMMDD)."
    echo "  3. Quantity     : Limit of videos to download"
    echo ""
    echo "Options:"
    echo "  -h, --help        : Show this screen"
    echo "  -v, --version     : Show version"
    echo ""
    echo "Example:"
    echo "  ./template.sh \"lollapalooza 2018\" 20181231 5"
    echo " (further help, use the current date that you are executing this to download everything everytime (everywhere at the end of time))"
    exit 0
}

if [ "$1" == "-v" ] || [ "$1" == "--version" ]; then
    show_version
fi

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_help
fi

# --- DEPENDENCIES CHECK ---
MISSING_DEP=0

# 1. check yt-dlp
if ! command -v yt-dlp &> /dev/null; then
    echo "error: 'yt-dlp' is not installed"
    MISSING_DEP=1
fi

# 2. Verify JS runtime (Node or Deno)
JS_RUNTIME=""
if command -v deno &> /dev/null; then
    JS_RUNTIME="deno"
elif command -v node &> /dev/null; then
    JS_RUNTIME="node"
else
    echo "error: no javascript runtime found ('node' or 'deno' are necessary to use yt-dlp)."
    MISSING_DEP=1
fi

# stop script on missing dependencies
if [ $MISSING_DEP -eq 1 ]; then
    echo "Please install the dependencies that were listed above and try again"
    exit 1
fi

# --- ARGUMENTS VALIDATION  ---
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "error: how i like to call it, fault on arguments, check it and try again"
    echo "correct usage: ./template.sh \"<search term>\" <DATE_YYYYMMDD> <quantity>"
    echo "use ./template.sh --help to further details"
    exit 1
fi

# assign arguments to variables
SEARCH_TERM="$1"
LIMIT_DATE="$2"
QUANTITY="$3"

# base directories
BASE_DIR="$(pwd)"
DOWNLOAD_DIR="$BASE_DIR/downloads"
ARCHIVE="$BASE_DIR/archive.txt"

# create directories if it dont exist
if [ ! -d "$DOWNLOAD_DIR" ]; then
    mkdir -p "$DOWNLOAD_DIR"
fi

echo "iniciating archivement using: $JS_RUNTIME..."

# run yt-dlp using dynamic variables and the chosen JS runtime
yt-dlp "ytsearch"$QUANTITY":$SEARCH_TERM" \
--no-playlist \
--js-runtime "$JS_RUNTIME" \
--datebefore "$LIMIT_DATE" \
--download-archive "$ARCHIVE" \
-f "bv*[height<=720][ext=mp4]+ba[ext=m4a]/b[height<=720]" \
--merge-output-format mp4 \
--remux-video mp4 \
--write-description \
--write-info-json \
--embed-thumbnail \
--ignore-errors \
--no-abort-on-error \
-o "$DOWNLOAD_DIR/%(uploader)s/%(upload_date)s - %(title)s [%(id)s].%(ext)s"

echo ""
echo "Archiving complete for: $SEARCH_TERM!"

#!/bin/bash

# ---------------------------------------------------------------------------
# HELPER FUNCTIONS

# echo an error message and exit the script
oops() {
    echo "$0:" "$@" >&2
    exit 1
}

# args: $1 = a binary you want to require e.g. tar, gpg, mail
#       $2 = a message briefly describing what you need the binary for
require() {
    command -v "$1" > /dev/null 2>&1 \
        || oops "you do not have '$1' installed; needed for: $2"
}

log() {
    echo "install: $1"
}

# ---------------------------------------------------------------------------
# STUFF THAT NEEDS TO BE INSTALLED TO RUN THIS SCRIPT

require date "logging during script execution"
require python3 "for creating the virtual env that the scripts will work in"
require wget "for downloading required files from the internet"
require sha256sum "for verifying integrity of downloaded files"

# ---------------------------------------------------------------------------
# STUFF THAT NEEDS TO BE INSTALLED FOR SITE GENERATION AS A WHOLE TO WORK

require pandoc "for converting markdown notes to HTML"
require rsync "for pushing notes to a remote server"

# ---------------------------------------------------------------------------
# VARIABLES & FUNCTIONS

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cleanup() {
    # no cleanup to do
    log "Done!"
}

trap cleanup EXIT

check_venv() {
    log "checking for venv..."
    if [ ! -d "venv" ]; then
        log "could not find a venv"
        log "creating one with version: $(python3 --version)"
        python3 -m venv venv
    else
        log "venv already exists - skipping"
    fi
}

# desc: download a file from a CDN and check the sha256 checksum for it.
#       if you already have the file, it wont download it, but will still
#       check the sha256 hash
# args: $1 = url to file
#       $2 = expected sha256 hash of file
#       $3 = path to the folder where the file should go
get_check_and_cache_file_from_CDN() {
    local URL
    local SHA256HASH
    local FOLDER
    local FILE_NAME

    URL="$1"
    SHA256HASH="$2"
    FOLDER="$3"

    # the file name will always be the whatever is after the last '/' in
    # the URL
    FILE_NAME="$(echo "$URL" | sed "s/.*\///g")"

    log "$FILE_NAME: searching for file..."
    if [ ! -f "$FOLDER/$FILE_NAME" ]; then
        log "$FILE_NAME: not present locally"
        log "$FILE_NAME: downloading from: $URL"
        wget --quiet "$URL" --directory-prefix "$FOLDER"
    else
        log "$FILE_NAME: already present - skipping download"
    fi

    log "$FILE_NAME: verifying sha256 checksum"
    # sha256sum expects the below format with the two space gap
    # hash  path/to/file
    echo "$SHA256HASH  $FOLDER/$FILE_NAME" \
        | sha256sum --check --status || oops "$FILE_NAME: sha256 checksum of $URL is not correct!"
    log "$FILE_NAME: all good!"
}

# ---------------------------------------------------------------------------
# MAIN SCRIPT EXECUTION

check_venv

# for manipulating URIs
get_check_and_cache_file_from_CDN \
    "https://unpkg.com/URIjs@1.16.1/src/URI.min.js" \
    "7f3f593b680938ebaf2d8d553f7e0a18fd8ec5b669baf25b16de738e52b1fe52" \
    "$DIR/js"

# for client side result indexing (used for search)
get_check_and_cache_file_from_CDN \
    "https://unpkg.com/lunr@2.3.9/lunr.min.js" \
    "0c50d9002b85780a842afffb567bb54ede402dae7c6dc5997a018614d8044fc8" \
    "$DIR/js"

# sane defaults for CSS
get_check_and_cache_file_from_CDN \
    "https://unpkg.com/@csstools/normalize.css@11.0.1/evergreen.css" \
    "43d2a454581c4eeca4581bfce1b754f8d5b67c0e8b2c16acc82ed385c76460a4" \
    "$DIR/css"

# Open Sans font
get_check_and_cache_file_from_CDN \
    "https://fonts.gstatic.com/s/opensans/v18/mem8YaGs126MiZpBA-UFWJ0bbck.woff2" \
    "33f963a7ce37cbcce434f8d997eadd75d42f9d6953a0cdbdbb82866475bed6f7" \
    "$DIR/css"
get_check_and_cache_file_from_CDN \
    "https://fonts.gstatic.com/s/opensans/v18/mem8YaGs126MiZpBA-UFUZ0bbck.woff2" \
    "547ded99e5139a10d4145e6e5c62ce35fa03495f625ee8d1e457011408428154" \
    "$DIR/css"
get_check_and_cache_file_from_CDN \
    "https://fonts.gstatic.com/s/opensans/v18/mem8YaGs126MiZpBA-UFWZ0bbck.woff2" \
    "71232fd86d1de3acb48b8b0d9297f8d861ecdaf7a468a28a7ce79ce5b57ccea7" \
    "$DIR/css"
get_check_and_cache_file_from_CDN \
    "https://fonts.gstatic.com/s/opensans/v18/mem8YaGs126MiZpBA-UFVp0bbck.woff2" \
    "76a9155c37af66838d10c5bb86e29c9a7b37d8cdc3d458519a2654deb2d89cf7" \
    "$DIR/css"
get_check_and_cache_file_from_CDN \
    "https://fonts.gstatic.com/s/opensans/v18/mem8YaGs126MiZpBA-UFWp0bbck.woff2" \
    "9616881bf47c6526f8f1552b31d1b399fb5a95922a3b8914cc6972cf6aacaa72" \
    "$DIR/css"
get_check_and_cache_file_from_CDN \
    "https://fonts.gstatic.com/s/opensans/v18/mem8YaGs126MiZpBA-UFW50bbck.woff2" \
    "28e9420a6d03a70b837b51c9fbe1bb1f819a3d4aa71bffa07f7c3e79d7dcf878" \
    "$DIR/css"
get_check_and_cache_file_from_CDN \
    "https://fonts.gstatic.com/s/opensans/v18/mem8YaGs126MiZpBA-UFVZ0b.woff2" \
    "9c50a96c859b9beea47b71740bd14e7f69a4df586d015f47434037f8def53b52" \
    "$DIR/css"

# Public Sans font
get_check_and_cache_file_from_CDN \
    "https://fonts.gstatic.com/s/publicsans/v4/ijwGs572Xtc6ZYQws9YVwllKVG8qX1oyOymuFpmJygcob18.woff2" \
    "8eaa9188e062a4df8a8f89e237ab0d537440ee6c4292d689e660d26b8b9051ca" \
    "$DIR/css"
get_check_and_cache_file_from_CDN \
    "https://fonts.gstatic.com/s/publicsans/v4/ijwGs572Xtc6ZYQws9YVwllKVG8qX1oyOymuFpmJxAco.woff2" \
    "66b2815c97afd978234e7420d06256c95c47121172f611744a525f8fe77552b4" \
    "$DIR/css"

# ---------------------------------------------------------------------------
# CLEAN EXIT

exit 0

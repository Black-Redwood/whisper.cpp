#!/usr/bin/env bash

# Function to clean up temporary files
cleanup() {
    echo "Cleaning up temporary files..."
    rm -f "$file" "$file.wav"
}

# Trap to catch signals and clean up
trap cleanup EXIT INT TERM

base="`date +"%m-%d-%Y_%H%M%S"`_youtube"
yt-dlp "$1" -o "$base" -x  > /dev/null 2>&1
file=`/bin/ls | grep "$base"`    # we don't know what audio file extension yt-dlp will create
ffmpeg -i  ./"$file" -acodec pcm_s16le -ac 1 -ar 16000 "$file.wav" > /dev/null 2>&1
./main "${file}.wav" 2> /dev/null

# Clean up normally if the script completes successfully
cleanup
#!/usr/bin/env bash

# Function to clean up temporary files
cleanup() {
    # echo "Cleaning up temporary files..."
    rm -f "$file" "$file.wav" tmp_cookies.txt
}
# Trap to catch signals and clean up
trap cleanup EXIT INT TERM

base="`date +"%m-%d-%Y_%H%M%S"`_youtube"
# yt-dlp will modify our cookies file, so make a tmp throwaway copy
touch cookies.txt
cp cookies.txt tmp_cookies.txt
# Download the video and extract the audio
yt-dlp --cookies tmp_cookies.txt "$1" -o "$base" -x  > /dev/null 2>&1
[ $? -ne 0 ] && exit -1
# Find the audio file yt-dlp created
file=`/bin/ls | grep "$base"`    # we don't know what audio file extension yt-dlp will create
# Convert the audio to the correct format for transcribing
ffmpeg -i  ./"$file" -acodec pcm_s16le -ac 1 -ar 16000 "$file.wav" > /dev/null 2>&1
[ $? -ne 0 ] && exit -1
# Transcribe the audio
../main  -m ../models/ggml-base.bin "${file}.wav" 2> /dev/null
[ $? -ne 0 ] && exit -1
# Clean up normally if the script completes successfully
cleanup

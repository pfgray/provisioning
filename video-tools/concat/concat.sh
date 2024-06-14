#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

output=""

while getopts ":o:" opt; do
  case $opt in
    o) output="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done

if [ -z "${output}" ]; then
  echo "output file not specified"
  echo "usage: concat -o output input1 input2..."
  exit 1;
fi

if [ -z "${3-}" ]; then
  echo "no input files specified"
  echo "usage: concat -o output input1 input2..."
  exit 1;
fi

TMPFILE=$(mktemp)
for i in "${@:3}"
do
  path=$(realpath "$i")
  echo "file $path" >> "$TMPFILE"
done

ffmpeg -safe 0 -f concat -i "$TMPFILE" -c copy "$output"

rm -f "$TMPFILE"

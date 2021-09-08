#!/bin/sh
#
# trim

# get dir in which the script was executed
DIR="$(dirname "${0}")"

# amount of time to trim files by
TRIM_BY=${2}

main() {
    # loop over all files of certain type
    for f in "${DIR}"/*."${1}"; do
        # get base and ext
        base="${f%.*}"
        ext="${f##*.}"

        # get file duration in minutes and seconds
        time="$(ffmpeg -i "${f}" 2>&1 | grep 'Duration:' | awk -F ',' '{print $1}' | cut -f 1 -d '.' | awk -F ':' '{print $3 " " $4}')"
        min=$(printf '%s\n' "${time}" | awk '{print $1}')
        sec=$(printf '%s\n' "${time}" | awk '{print $2}')

        # convert minutes to seconds
        min_to_sec=$((min * 60))

        # length in pure seconds
        length=$((min_to_sec + sec))

        # length after trim
        final_length=$((length - TRIM_BY))

        printf '%s\n' "Trimming ${base}.${ext} by ${TRIM_BY} seconds..."

        # agree to trim file
        yes | ffmpeg -i "${f}" -ss 00 -t "${final_length}" -c copy "${base}-new.${ext}" 2>/dev/null

        # create backup just in case
        mv "${f}" "${f}.bak" && mv "${base}-new.${ext}" "${base}.${ext}"
    done
}

main "${@}"

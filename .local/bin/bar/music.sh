#!/bin/sh
#
# music

MUSIC_ICON=''
PLAYING_ICON=''
PAUSED_ICON=''

open() { "${TERMINAL}" -c "${MUSIC_PLAYER}" -e "${MUSIC_PLAYER}" ; }

get_song_and_state() {
    # get current song name
    song="$(mpc -f %title% | head -n 1)"

    # get state of song
    state="$(mpc -f %title% | sed '2q;d' | awk '{ print $1 }' | tr -d '[:punct:]')"
}

toggle() {
    # pause if playing and play if paused
    mpc -q toggle

    get_song_and_state

    # no songs playing so don't do anything
    if printf '%s\n' "${song}" | awk '{ print $1,$2 }' | grep -iq '^volume:\s[0-9][0-9]*%$'; then return 1; fi

    # convert first letter of state from lowercase to uppercase
    first_letter="$(printf '%s\n' "${state}" | cut -c 1 | tr '[:lower:]' '[:upper:]')"
    rest="$(printf '%s\n' "${state}" | cut -c 2-)"
    state="${first_letter}${rest}"

    herbe "${state} ${song}" &
}


bar() {
    get_song_and_state

    # print ellipses if song name cuts off in bar
    if [ "${#song}" -ge 20 ]; then
        song="$(printf '%.17s' "${song}")"
        song="${song}..."
    fi

    # no songs
    [ -z "${state}" ] && printf '%s\n' "${MUSIC_ICON}"
    # song is playing
    [ "${state}" = 'playing' ] && printf '%s\n' "${PLAYING_ICON} ${song}"
    # paused
    [ "${state}" = 'paused' ] && printf '%s\n' "${PAUSED_ICON} ${song}"
}

main() {
    # called from bar
    [ ${#} -eq 0 ] && bar

    # bar usage
    case ${BLOCK_BUTTON} in
        1) open                                             ;;
        2) toggle                                           ;;
        4) mpc -q prev                                      ;;
        5) [ -n "$( mpc -f %title% queue)" ] && mpc -q next ;;
    esac

    while getopts 'ot' opt; do
        case "${opt}" in
            # open music player if called with o flag
            o) open   ;;
            t) toggle ;;
            *) return ;;
        esac
    done
}

main "${@}"

#!/bin/sh
#
# monitor

ICON=''
# brightness vcp code is 10
VCP_CODE=10
# cache used b/c ddcutil getvcp too expensive
BRIGHTNESS="${XDG_CACHE_HOME:-${HOME}/.cache/}/dots/bar/brightness"

get_brightness() {
    [ ! -f "${BRIGHTNESS}" ] && return 1
    # brightness cache should contain only number
    ! brightness=$(grep '^[0-9][0-9]*$' "${BRIGHTNESS}") && return

}

set_brightness() {
    get_brightness

    # keep between 0-100
    if [ "${1}" = '+' ]; then
        if [ "${brightness}" -lt 100 ]; then
            brightness=$((brightness + ${2}))
            [ "${brightness}" -gt 100 ] && brightness=100
        else return
        fi
    elif [ "${1}" = '-' ]; then
        if [ "${brightness}" -gt 0 ]; then
            brightness=$((brightness - ${2}))
            [ "${brightness}" -lt 0 ] && brightness=0
        else return
        fi
    fi

    # set brightness using ddcutil
    doas ddcutil setvcp ${VCP_CODE} "${brightness}" >/dev/null 2>&1

    env HERBE_ID=/0 herbe "Brightness: ${brightness}%" &

    # get actual brightness and send output to cache
    printf '%s\n' "$(doas ddcutil getvcp ${VCP_CODE} | awk '{ print $9 }' | tr -d '[:punct:]' 2>/dev/null)" > "${BRIGHTNESS}"
}

bar() {
    get_brightness
    printf '%s\n' "${ICON} ${brightness}%"
}

main() {
    # called from bar
    [ ${#} -eq 0 ] && bar

    # bar usage
    case ${BLOCK_BUTTON} in
        4) set_brightness + 25 ;;
        5) set_brightness - 25 ;;
    esac

    # modify monitor brightness based on args
    # ${1} = +/- and ${2} = percentage
    [ "${*}" ] && set_brightness "${1}" "${2}"
}

main "${@}"

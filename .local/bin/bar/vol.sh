#!/bin/sh
#
# vol

VOLUME_HIGH_ICON=''
VOLUME_MID_ICON=''
VOLUME_LOW_ICON=''
VOLUME_OFF_ICON=''
VOLUME_MUTED_ICON=''

get_scontrol() {
    # Prefer Master but use PCM if not available
    if amixer scontrols | grep -iq 'Master'; then scontrol='Master'
    elif amixer scontrols | grep -iq 'PCM'; then scontrol='PCM'
    fi
}

get_vol() { vol=$(amixer get "${scontrol}" -M | awk '{ for (i = 1; i<=NF; i++) { if ( $i ~ /\[[0-9][0-9]*%\]/ ) { print $i } } }' | head -n 1 | tr -d '[:punct:]') ; }

toggle() {
    [ "${scontrol}" = 'Master' ] && amixer set "${scontrol}" toggle
    [ "${scontrol}" = 'PCM' ] && amixer set 'IEC958,5' toggle
}

# set volume linearly
set_vol() {
    amixer set "${scontrol}" "${2}"%"${1}" -M
    get_vol
    env HERBE_ID=/0 herbe "Volume: ${vol}%" &
}

open() { "${TERMINAL}" -c "${MIXER}" -e "${MIXER}" ; }

bar() {
    get_vol

    # check if muted
    if [ "${scontrol}" = 'Master' ] || [ "${scontrol}" = 'PCM' ]; then
        if amixer get "${scontrol}" | sed 5q | grep -iq '\[off\]' || \
           amixer get 'IEC958,5' | sed 4q | grep -iq '\[off\]'; then
            printf '%s\n' "${VOLUME_MUTED_ICON} ${vol}%" && return
        fi
    fi

    # volume 0 is off, 1-33 is low, 34-66 is med, 67-100 is high
    case ${vol} in
        0)                               printf '%s\n' "${VOLUME_OFF_ICON} ${vol}%" ;;
        [1-9]|1[0-9]|2[0-9]|3[0-3])      printf '%s\n' "${VOLUME_LOW_ICON} ${vol}%" ;;
        3[4-9]|4[0-9]|5[0-9]|6[0-6])     printf '%s\n' "${VOLUME_MID_ICON} ${vol}%" ;;
        6[7-9]|7[0-9]|8[0-9]|9[0-9]|100) printf '%s\n' "${VOLUME_HIGH_ICON} ${vol}%" ;;
    esac
}

main() {
    get_scontrol

    # called from bar
    [ ${#} -eq 0 ] && bar

    # bar usage
    case ${BLOCK_BUTTON} in
        1) open                                      ;;
        2) toggle                                    ;;
        4) set_vol + 1                               ;;
        5) set_vol - 1                               ;;
    esac

    while getopts 'ot' opt; do
        case "${opt}" in
            # open mixer
            o) open;   return ;;
            # toggle if t flag used
            t) toggle; return ;;
            *) return         ;;
        esac
    done

    # set volume based on args
    # ${1} = +/- and ${2} = percentage
    [ "${*}" ] && set_vol "${1}" "${2}"
}

main "${@}"

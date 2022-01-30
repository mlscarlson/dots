#!/bin/sh
#
# shot

COLORS="${XDG_CACHE_HOME:-${HOME}/.cache/}/wal/colors.sh"

main() {
    [ -f "${COLORS}" ] && . "${COLORS}"

    hex="$(printf '%s' "${color2}" | tr '[:lower:]' '[:upper:]' | tr -d '[:punct:]')"

    a=$(printf '%s' "${hex}" | cut -c 1-2)
    b=$(printf '%s' "${hex}" | cut -c 3-4)
    c=$(printf '%s' "${hex}" | cut -c 5-6)

    r=$(printf '%d' 0x${a})
    g=$(printf '%d' 0x${b})
    b=$(printf '%d' 0x${c})

    rf=$(awk -v var=${r} 'BEGIN { print var/255 }')
    gf=$(awk -v var=${g} 'BEGIN { print var/255 }')
    bf=$(awk -v var=${b} 'BEGIN { print var/255 }')

    scrot -a "$(slop -b 3 -c "${rf}","${gf}","${bf}",1.0 -f '%x,%y,%w,%h')" -q 100 -z -C 'screenshot' "${PICTURES_DIR}/shots/%m-%d-%Y-%I-%M-%S.png"
}

main "${@}"

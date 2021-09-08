#!/bin/sh
#
# time

ICON=''

bar() { printf '%s\n' "${ICON} $(date +%I:%M\ %p)" ; }

main() {
    # called from bar
    [ ${#} -eq 0 ] && bar

    # bar usage
    case ${BLOCK_BUTTON} in 1) env HERBE_ID=/0 herbe "$(date +%I:%M:%S\ %p)" ;; esac
}

main "${@}"

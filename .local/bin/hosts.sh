#!/bin/sh
#
# hosts

HOSTS_ENABLED_DIR='/etc/'
HOSTS_DISABLED_DIR="${HOME}/.local/share/"

enable() { doas mv -v "${HOSTS_DISABLED_DIR}hosts" "${HOSTS_ENABLED_DIR}" && env HERBE_ID=/0 herbe 'Hosts enabled' & }

disable() { doas mv -v "${HOSTS_ENABLED_DIR}hosts" "${HOSTS_DISABLED_DIR}" && env HERBE_ID=/0 herbe 'Hosts disabled' & }

main() {
    # in each of the following cases we want to sleep to prevent xcb unknown sequence number error

    # disable by moving hosts to xdg share directory
    [ -f "${HOSTS_ENABLED_DIR}/hosts" ]  && disable && sleep 1 && return 0

    # enable by moving hosts to /etc/
    # shellcheck disable=SC3044
    [ -f "${HOSTS_DISABLED_DIR}/hosts" ] && enable  && sleep 1 && return 0
}

main "${@}"

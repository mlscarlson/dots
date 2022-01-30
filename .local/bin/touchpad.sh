#!/bin/sh
#
# touchpad

main() {
    # get touchpad using xinput
    # xinput will show list of input devices with id (we want id)
    # we can then use xinput list-props <ID> to see if device enabled
    tp="$(xinput | grep -i '^.*touchpad.*id=[0-9][0-9]*.*$' | awk '{ for (i = 1; i <= NF; i++) { if ($i ~ /^.*id=[0-9][0-9]*.*$/) { print $i } } }' | tr -d -c 0-9)"
    flag="$(xinput list-props "${tp}" | grep -i '^.*device enabled.*$' | awk '{ for (i = 1; i <= NF; i++) { if ($i ~ /^\s*[0-1]\s*$/) { print $i } } }')"

    # toggle touchpad also with xinput
    {
        if [ "${flag}" -eq 1 ]; then xinput --disable "${tp}" && env HERBE_ID=/0 herbe 'Touchpad disabled' &
        else xinput --enable "${tp}" && env HERBE_ID=/0 herbe 'Touchpad enabled' &
        fi
    } &
}

main "${@}"

#!/bin/sh
#
# cpu

LOAD_ICON=''
TEMP_EMPTY_ICON=''
TEMP_QUARTER_ICON=''
TEMP_HALF_ICON=''
TEMP_THREE_QUARTERS_ICON=''
TEMP_FULL_ICON=''

# approx delay with top alternative
DELAY=3.15

# differs on machine
TEMP="$(ls /sys/class/thermal/thermal_zone2*/temp)"

# cache used b/c awk and delay is time expensive
USAGE="${XDG_CACHE_HOME:-${HOME}/.cache/}/dots/bar/usage"

calculate_temp() {
    [ -f "${TEMP}" ] && temp=$(cat "${TEMP}")
    # convert millidegree celsius to celsius
    temp=$((temp/1000))
}

calculate_usage() {
    # perform math on cpu numbers from /proc/stat to get usage
    printf '%s\n' "$({ cat /proc/stat; sleep "${DELAY}"; cat /proc/stat; } |
        awk '/^cpu / { usr=$2-usr; sys=$4-sys; idle=$5-idle; iow=$6-iow }
        END { total=usr+sys+idle+iow; printf "%.0f\n", (total-idle)*100/total }')" > "${USAGE}"
}

# top ten intensive processes
get_procs() { procs="$(ps -eo comm,%cpu | sort -k 2 -n -r | head | tail | sed 's/$/%/')" ; }

get_usage() { [ -f "${USAGE}" ] && usage=$(cat "${USAGE}") ; }

bar() {
    # temp
    calculate_temp
    case ${temp} in
        [0-9][0-9][0-9]*)  TEMP_ICON="${TEMP_FULL_ICON}"           ;;
        7[5-9]|[8-9][0-9]) TEMP_ICON="${TEMP_THREE_QUARTERS_ICON}" ;;
        [5-6][0-9]|7[0-4]) TEMP_ICON="${TEMP_HALF_ICON}"           ;;
        [0-4][0-9])        TEMP_ICON="${TEMP_QUARTER_ICON}"        ;;
        0)                 TEMP_ICON="${TEMP_EMPTY_ICON}"          ;;
    esac

    calculate_usage &

    get_usage

    # print load in percentage and temp in celsius
    printf '%s\n' "${LOAD_ICON} ${usage}% ${TEMP_ICON} ${temp}°C"
}

main() {
    # called from bar
    [ ${#} -eq 0 ] && bar

    # bar usage
    case ${BLOCK_BUTTON} in
        1) get_procs
           herbe "${procs}"
           ;;
    esac
}

main "${@}"

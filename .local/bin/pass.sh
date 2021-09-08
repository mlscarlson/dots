#!/bin/sh
#
# pass

# named pass in order to just werk when switching from popular pass program
CREDENTIALS_DIR="${XDG_DATA_HOME:-${HOME}/.local/share/}/pass"

NEWLINE='
'

get_credential() {
    credential="$(printf '%s\n' "${credentials}" | grep "\<${1}\>" | awk -F ':' '{ print $2 }')"
    credential="${credential%\'}"
    credential="${credential#\'}"
}

main() {
    # get credentials from pass directory
    i=0
    # only pay attention to files ending in gpg
    for site in "${CREDENTIALS_DIR}"/*.gpg; do
        # strip gpg ending
        site="${site%.*}"

        # first case don't print newline
        # else we want to format the list with newlines
        if [ ${i} -eq 0 ]; then sites="${sites}${site##*/}"
        else sites="${sites}${NEWLINE}${site##*/}"
        fi

        i=$((i+1))
    done

    # pick the site in dmenu
    site="$(printf '%s\n' "${sites}" | dmenu -c -l 10)"

    # get the credentials by decrypting the file
    credentials="$(gpg -dq "${CREDENTIALS_DIR}"/"${site}".gpg)"

    # valid credential types are:
    # uname
    # email
    # pw
    # squestion{n}
    credential_types="$(printf '%s\n' "${credentials}" | awk -F ':' '{ print $1 }')"

    # get the number of security questions
    squestions="$(printf '%s\n' "${credential_types}" | grep -c 'squestion*')"

    # get all credential types as formatted strings
    credential_options="$(printf '%s\n' "${credential_types}" | ( while read -r type; do
        case "${type}" in
            'uname')      printf 'Username\n'          ;;
            'pw')         printf 'Password\n'          ;;
            'email')      printf 'Email\n'             ;;
            'squestion'*) i=1
                          while [ ${i} -le "${squestions}" ]; do
                              printf '%s\n' "Security Question ${i}"
                              i=$((i+1))
                          done
                          break
                          ;;
        esac
    done
    printf '%s\n' "${credential_options}" ))"

    # pick the credential in dmenu
    # e.g. select password if you want the password
    credential_option="$(printf '%s\n' "${credential_options}" | dmenu -c -l 10 -p 'Credentials')"

    # user picked a security question so get the security number question they picked
    if printf '%s\n' "${credential_option}" | grep -q '\<[0-9]\>'; then num="$(printf '%s\n' "${credential_option}" | awk '{ print $3 }')" ; fi

    # get the credential
    case "${credential_option}" in
        'Username')                 get_credential 'uname'         ;;
        'Password')                 get_credential 'pw'            ;;
        'Email')                    get_credential 'email'         ;;
        "Security Question ${num}") get_credential "sanswer${num}" ;;
    esac

    # copy to clipboard
    if printf '%s\n' "${credential}" | xclip -selection clipboard; then { herbe "${credential_option} for ${site} copied to clipboard" & } ; fi
}

main "${@}"

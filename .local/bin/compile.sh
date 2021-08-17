#!/bin/sh
#
# compile

. "${HOME:-/home/${USER}/}/.local/bin/symlink.sh"

main() {
    # use POSIX-compliant way to follow symlink
    file="$(follow_link "${1}")"

    # dir, base, ext are good things to know
    dir="${file%/*}/"
    base="${file%.*}"
    ext="${file##*.}"

    # dir does not exist and exist
    cd "${dir}" || return 1

    # clear screen for neatness
    clear

    # add some functionality to this basic compiler
    while getopts 'c:o:' opt; do
        case "${opt}" in
            # shell check if called with c flag and shell script
            c) [ "${OPTARG##*.}" = 'sh' ] && shellcheck -x "${OPTARG}"
               return
               ;;
            # open same file name with different extension if called with o flag
            o) case "${OPTARG##*.}" in
                   'tex') [ -f "${OPTARG%.*}.pdf" ] && "${HOME:-/home/${USER}/}/.local/bin/open.sh" "${OPTARG%.*}.pdf" >/dev/null 2>&1 & ;;
               esac
               return
               ;;
            *) break                                                   ;;
        esac
    done

    # different compile options based on file extension
    case "${ext}" in
              # GNU compilers
        'c')    cc "${file}"  -o "${base}" && "${base}"                    ;;
        'cpp')  g++ "${file}" -o "${base}" && "${base}"                    ;;
        'java') javac  "${file}" && java "${file}"                         ;;
        'py')   python "${file}"                                           ;;
        'sh')   sh     "${file}"                                           ;;
        'tex')  printf 'reached'
                if grep -iq 'addbibresource' "${file}"; then
                    biber --input-directory  "${dir}" "${base}"
                fi
                pdflatex --output-directory="${dir}" "${base}"
                # remove annoying files generated by latex
                for f in "${base}".*; do
                    case "${f##*.}" in
                        'aux' | \
                        'bbl' | \
                        'bcf' | \
                        'blg' | \
                        'lof' | \
                        'log' | \
                        'out' | \
                        'toc' | \
                        'xml') rm -f "${f}" ;;
                    esac
                done
                ;;
    esac
}

main "${@}"

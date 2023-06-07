#!/bin/bash

nicenumber() {
    integer=$(echo $1 | cut -d. -f1)
    decimal=$(echo $1 | cut -d. -f2)

    if [ $decimal != $1 ]; then
        result="${DD:="."}$decimal"
    fi

    thousands=$integer

    while [ $thousands -gt 999 ]; do
        remainder=$(($thousands % 1000))

        while [ ${#remainder} -lt 3 ]; do
            remainder="0$remainder"
        done

        thousands=$(($thousands / 1000))
        result="${TD:=","}${remainder}${result}"
    done

    nicenum="${thousands}${result}"
    if [ ! -z $2 ]; then
        echo $nicenum
    fi
}

DD="."
TD=","

while getopts "d:t" opt; do
    case $opt in
        d ) DD="$OPTARG"    ;;
        t ) TD="$OPTARG"    ;;
    esac
done
shift $(($OPTIND -1))

if [ $# -eq 0 ]; then
    echo "Usage: $(basename $0) [-d c] [-t c] numeric value"
    echo "  -d specifies the decimal delimiter (default '.')"
    echo "  -t specifies the thousands delimiter (default ',')"
    exit 0
fi

nicenumber $1 1

exit 0
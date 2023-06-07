#!/bin/sh

bytes_in_gb=1048576

scripbc=$HOME/scriptbc
nicenumber=$HOME/nicenumber

host=""

if [ $# -eq 0 ]; then
    echo "Usage: $(basename $0) logfile" >&2
    exit 1
fi

if [ ! -r "$1" ]; then
    echo "Error: log file $1 not found" >&2
    exit 1
fi

firstdate="$(head -1 "$1" | awk '{print $4}' | sed 's/\[//')"
lastdate="$(tail -1 "$1" | awk '{print $4}' | sed 's/\[//')"

echo "Results of analyzing log file $1"
echo ""
echo "  Start date: $(echo $firstdate|sed 's/:/ at /')"
echo "    End date: $(echo $lastdate|sed 's/:/ at /')"

hits="$(wc -l < "$1" | sed 's/[^[:digit:]]//g')"

echo "      Hits: $($nicenumber $hits) (total accesses)"

pages="$(grep -ivE '(.txt|.gif|.jpg|.png))' "$1" | wc -l | sed 's/[^[:digit:]]//g')"

echo "      Pageviews: $($nicenumber $pages) (hits minus graphics)"
echo ""

totalbytes="$(awk '{sum+=$10} END {print sum}' "$1")"

echo -n " Transferred: $($nicenumber $totalbytes) bytes"
echo ""

if [ $totalbytes -gt $bytes_in_gb]; then
    echo "($($scriptbc $totalbytes / $bytes_in_gb) GB)"
elif [ $totalbytes -gt 1024 ]; then
    echo "($($scriptbc $totalbytes / 1024) MB)"
else
    echo ""
fi

echo ""
echo "The ten most popular pages were:"

awk '{print $7}' "$1" | grep -ivE '(.gif|.jpg|.png)' | \
    sed 's/\/$//g' | sort | \
    uniq -c | sort -rn | head -10

echo ""

echo "The ten most common referrers were:"

awk '{print $11}' "$1" | \
    grep -vE "(^\"-\"$|/www.$host|/$host)" | \
    sort | uniq -c | sort -rn | head -10

echo ""
exit 0
#!/bin/bash

function memory_status {
TOTAL_MEMORY=$(free  | grep Mem: | awk '{ printf("TOTAL: " $2) }')
MEMORY_IN_USE=$(free | grep Mem: | awk '{ printf("IN USE: " $3 " (%.2f%)", $3/$2 * 100.0) }')
FREE_MEMORY=$(free | grep Mem: | awk '{ printf("FREE: " $4 " (%.2f%)", $4/$2 * 100.0) }')

echo $TOTAL_MEMORY
echo $MEMORY_IN_USE
echo $FREE_MEMORY
}

function parameter {
        echo "Usage: $(basename $0) [-cwe]" 2>&1
        echo '  -c: critical threshold (percentage)'
        echo '  -w: warning threshold (percentage)'
        echo '  -e: email address to send the report'
        echo '  example: ./memory_check.sh -c 90 -w 60 -e name@domain.com'
        exit 1
}


# Define parameters

while getopts :c:w:e: arg; do
  case $arg in
	c)
	  critical="$OPTARG";;
	w)
	  warning="$OPTARG";;
	e)
  	  email="$OPTARG";;
	\?) #if input does not match getops options
	  echo "Invalid option."
	  parameter
	  exit 1 ;;
   esac
done
shift $((OPTIND -1))



if [ -z "$critical" ] || [ -z "$warning" ] || [ -z "$email" ]; then #if no parameter provided
	echo "None or incomplete parameter/s provided" >&2
	parameter
else
	printf "Critical Threshhold: %s\n" "$critical"
	printf "Warning Threshhold: %s\n" "$warning"
	printf "Email: %s\n" "$email"
	# memory_status
fi

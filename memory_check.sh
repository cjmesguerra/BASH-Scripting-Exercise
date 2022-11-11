#!/bin/bash

# Memory Check

# if no parameter provided, tell parameters to be provided

function parameter {
        echo "How to Use: $(basename $0) [-cwe]" 2>&1
        echo '  -c: critical threshold (percentage)'
        echo '  -w: warning threshold (percentage)'
        echo '  -e: email address to send the report'
        echo '  example: ./memory_check.sh -c 90 -w 60 -e name@domain.com'
        exit 1
}

#if [[ $# -eq ]]; then
#	echo "0 arguments provided"
#	parameter
#	exit 1
#fi

# Define paremeters

optstring=":cwe"

while getopts ${optstring} arg; do
  case ${arg} in
	c)
	  echo "Critical Threshhold: "
	  ;;
	w)
	  echo "Warning Threshhold: "
	  ;;
	e)
  	  echo "Email Address: "
	  ;;
	?)
	  echo "Invalid parameter/s: -${OPTARG}."
	  echo
	  parameter
	  exit 2
	  ;;
   esac
done

free

TOTAL_MEMORY=$(free  | grep Mem: | awk '{ printf("TOTAL MEMORY:" $2) }')

echo $TOTAL_MEMORY

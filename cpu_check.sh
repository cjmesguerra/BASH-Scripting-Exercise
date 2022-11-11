#!/bin/bash

function parameter {
        echo "Usage: $(basename $0) [-cwe]" 2>&1
        echo '  -c: critical threshold (percentage)'
        echo '  -w: warning threshold (percentage)'
        echo '  -e: email address to send the report'
        echo '  example: ./cpu_check.sh -c 90 -w 60 -e name@domain.com'
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
elif [ "$critical" -lt "$warning" ]; then
	echo "Critical threshold must always be greater than warning threshold." >&2
else	
	echo ""
	CPU_UTIL_PERCENT=$(top -b -n 1 | grep "Cpu(s)" | \sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \awk '{print 100 - $1"%"}')
	CPU_UTIL=${CPU_UTIL_PERCENT%.*}

	echo "CPU Utilization: $CPU_UTIL_PERCENT"
	echo ""

	if [ "$CPU_UTIL" -ge "$critical" ]; then
		echo "CPU Usage has reached given CRITICAL THRESHOLD ($critical). Forwarding status to email"
		SUBJECT="$(date +"%Y%m%d %H:%M") cpu_check - critical"
		MESSAGE="/tmp/Mail.out"
		TO="$email"
		
		echo "CPU Utilization: $CPU_UTIL_PERCENT" >> $MESSAGE
		echo "" >> $MESSAGE
		echo "================================" >> $MESSAGE
		echo "Top 10 Most Consuming Processes" >> $MESSAGE
		echo "================================" >> $MESSAGE
		echo "$(top -b -o +%CPU | head )" >> $MESSAGE
		echo "" >> $MESSAGE
		mail -s "$SUBJECT" "$TO" < $MESSAGE
		rm /tmp/Mail.out	
		exit 2

	elif [ "$CPU_UTIL" -ge "$warning" ] && [ "$CPU_UTIL" -lt "$critical" ]; then
		echo "CPU Usage has reached given WARNING THRESHOLD ($warning). Forwarding status to email."
		SUBJECT="$(date +"%Y%m%d %H:%M") cpu_check - warning" 
		MESSAGE="/tmp/Mail.out"
		TO="$email"
		
		echo "CPU Utilization: $CPU_UTIL_PERCENT" >> $MESSAGE
		echo "" >> $MESSAGE
		echo "================================" >> $MESSAGE
		echo "Top 10 Most Consuming Processes" >> $MESSAGE
		echo "================================" >> $MESSAGE
		echo "$(top -b -o +%CPU | head )" >> $MESSAGE
		echo "" >> $MESSAGE
		mail -s "$SUBJECT" "$TO" < $MESSAGE
		rm /tmp/Mail.out	
		exit 1

	else
		echo "Current CPU Utilzation is under given threshold parameters."
		exit 0
	fi
	
fi

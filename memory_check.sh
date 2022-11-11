#!/bin/bash

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
elif [ "$critical" -lt "$warning" ]; then
	echo "Critical threshold must always be greater than warning threshold." >&2
else	
	echo ""
	
	TOTAL_MEMORY=$(free  | grep Mem: | awk '{ printf("Total Memory: " $2) }')
	MEMORY_IN_USE=$(free | grep Mem: | awk '{ printf("Current Memory Usage: " $3 " (%.2f%)", $3/$2 * 100.0) }')
	MEMORY_USAGE=$(free | grep Mem: | awk '{ printf("%.0f\n", $3/$2 * 100.0) }')
	FREE_MEMORY=$(free | grep Mem: | awk '{ printf("Current Free Memory: " $4 " (%.2f%)", $4/$2 * 100.0) }')
	CACHE_MEMORY=$(free | grep Mem: | awk '{ printf("Memory On Cache: " $6 " (%.2f%)", $6/$2 * 100.0) }')

	echo $TOTAL_MEMORY
	echo $MEMORY_IN_USE
	echo $FREE_MEMORY
	echo $CACHE_MEMORY
	echo ""

	if [ "$MEMORY_USAGE" -ge "$critical" ]; then
		echo "Memory Usage has reached given CRITICAL THRESHOLD($critical). Forwarding status to email"
		SUBJECT="Memory Usage on $(hostname) at $(date) has reached CRITICAL THRESHOLD"
		MESSAGE="/tmp/Mail.out"
		TO="$email"
		
		echo "$MEMORY_IN_USE" >> $MESSAGE
		mail -s "$SUBJECT" "$TO" < $MESSAGE
		rm /tmp/Mail.out	

		exit 2
	elif [ "$MEMORY_USAGE" -ge "$warning" ] && [ "$MEMORY_USAGE" -lt "$critical" ]; then
		echo "Memory Usage has reached given WARNING THRESHOLD($warning). Forwarding status to email."
		SUBJECT="Memory Usage on $(hostname) at $(date) has reached WARNING THRESHOLD" 
		MESSAGE="/tmp/Mail.out"
		TO="$email"
		
		echo "$MEMORY_IN_USE" >> $MESSAGE
		mail -s "$SUBJECT" "$TO" < $MESSAGE
		rm /tmp/Mail.out	

		exit 1
	else
		echo "Memory Usage of $MEMORY_USAGE is under given threshold parameters of $critical and $warning"
		echo "Not sending to $email"
		exit 0
	fi
	
fi

#!/bin/bash

function parameter {
        echo "Usage: $(basename $0) [-cwe]" 2>&1
        echo '  -c: critical threshold (percentage)'
        echo '  -w: warning threshold (percentage)'
        echo '  -e: email address to send the report'
        echo '  example: ./disk_check.sh -c 90 -w 60 -e name@domain.com'
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
	DISK_PARTITION=$( df -P |awk '0 + $5  >= 60  {print $1"\t"$5}')
	echo "$DISK_PARTITION"
	
	echo ""

	if [ "$DISKPARTITION" -ge "$critical" ]; then
		echo "Disk Usage has reached given CRITICAL THRESHOLD ($critical). Forwarding status to email"
		SUBJECT="$(date +"%Y%m%d %H:%M") disk_check - critical"
		MESSAGE="/tmp/Mail.out"
		TO="$email"
		
		echo "Disk Usage: " >> $MESSAGE
		echo "" >> $MESSAGE
		mail -s "$SUBJECT" "$TO" < $MESSAGE
		rm /tmp/Mail.out	
		exit 2

	elif [ "$DISKPARTITION" -ge "$warning" ] && [ "$DISKPARTITION" -lt "$critical" ]; then
		echo "Disk Usage has reached given WARNING THRESHOLD ($warning). Forwarding status to email."
		SUBJECT="$(date +"%Y%m%d %H:%M") disk_check - warning" 
		MESSAGE="/tmp/Mail.out"
		TO="$email"
		
		echo "Disk Usage: " >> $MESSAGE
		echo "" >> $MESSAGE
		mail -s "$SUBJECT" "$TO" < $MESSAGE
		rm /tmp/Mail.out	
		exit 1

	else
		echo "Used Disk Usage is less than given threshold parameters."
		echo "$critical & $warning"
		exit 0
	fi
	
fi

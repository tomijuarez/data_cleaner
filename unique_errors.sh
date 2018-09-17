#!/bin/bash

#!/bin/bash

#The name of the log file.
LOG_FILE="$1"

if [ -z "$LOG_FILE" ]
then
  echo "Please, provide a log file to be analyzed."
  exit 1
fi

#Variables declarations
WARNINGS=()
ERRORS=()
#Search for LINE: pattern in log file and then grab the next to rows.
while read -r line ; do
  WARNING+=("$line")
done < <(cat $LOG_FILE | grep -o '@.*@' | grep 'WARNING' | tr '@' ' ')

while read -r line ; do
  ERRORS+=("$line")
done < <(cat $LOG_FILE | grep -o '@.*@' | grep 'ERROR' | tr '@' ' ')

UNIQUE_ERRORS=($(printf "%s\n" "${ERRORS[@]}" | sort -u))
echo "${UNIQUE_ERRORS[@]}" | tr "|" "\n" > "errors.txt"
UNIQUE_WARNINGS=($(printf "%s\n" "${WARNINGS[@]}" | sort -u))
echo "${UNIQUE_WARNINGS[@]}" | tr "|" "\n" > "warnings.txt"




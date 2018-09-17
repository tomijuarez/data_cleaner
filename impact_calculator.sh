#!/bin/bash

#The name of the log file.
LOG_FILE="$1"

if [ -z "$LOG_FILE" ]
then
  echo "Please, provide a log file to be analyzed."
  exit 1
fi

#Variables declarations
ALL_FILES=0 #How many files do we have in the log file.
CORE_FILES=0 #How many core files are affected
CORE_ERRORS=0 #Errors in core files
CORE_WARNINGS=0 #Warnings in core files
ALL_ERRORS=0 #Warnings per file
ALL_WARNINGS=0 #Errors per file
LINE_ERRORS=0
LINE_WARNINGS=0
#Search for LINE: pattern in log file and then grab the next to rows.
while read -r line ; do
  ALL_FILES=$(($ALL_FILES+1))
  LINE_ERRORS=$(echo "$line" | cut -d ' ' -f1)
  LINE_WARNINGS=$(echo "$line" | cut -d ' ' -f2)
  #Sum in global errors and warnings
  ALL_ERRORS=$((ALL_ERRORS + LINE_ERRORS))
  ALL_WARNINGS=$((ALL_WARNINGS + LINE_WARNINGS))
done < <(cat $LOG_FILE | grep '^FILE:.*.php' -A 2 | grep "ERROR" | cut -d ' ' -f2,5)

#The core lines are evaluated in a diferent loop because an if with a grep inside of $() create a new sub-process
#and we won't be able to read/write outer variables, which make this more complicated.
while read -r line ; do
  CORE_FILES=$(($CORE_FILES+1))
  LINE_ERRORS=$(echo "$line" | cut -d ' ' -f1)
  LINE_WARNINGS=$(echo "$line" | cut -d ' ' -f2)
  #Sum in global errors and warnings
  CORE_ERRORS=$((CORE_ERRORS + LINE_ERRORS))
  CORE_WARNINGS=$((CORE_WARNINGS + LINE_WARNINGS))
done < <(cat $LOG_FILE | grep '^FILE:.*src/cms/moodle.*.php' -A 2 | grep "ERROR" | cut -d ' ' -f2,5)

echo "NUMBER OF FILES: $ALL_FILES | NUMBER OF ERRORS: $ALL_ERRORS | NUMBER OF WARNINGS: $ALL_WARNINGS"
echo "NUMBER OF CORE FILES: $CORE_FILES ($(echo "scale=2 ; $CORE_FILES / $ALL_FILES" | bc)) | NUMBER OF CORE ERRORS: $CORE_ERRORS ($(echo "scale=2 ; $CORE_ERRORS / $ALL_ERRORS" | bc)) | NUMBER OF CORE WARNINGS: $CORE_WARNINGS ($(echo "scale=2 ; $CORE_WARNINGS / $ALL_WARNINGS" | bc))"
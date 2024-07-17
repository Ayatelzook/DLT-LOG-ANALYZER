#!/bin/bash

if [ ! -f "./function.sh" ]; then
    echo "File not exists"
    exit 1
fi
 source  "./function.sh"
 
function main () {

   declare path=$1
   Report
   Filtering
   Event_Tracking
   Error_Warning_Summary
   Log_Parsing
}

main "$1"
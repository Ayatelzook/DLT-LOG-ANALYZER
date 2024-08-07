#!/bin/bash


##  1. Log Parsing: Extract key pieces of information from each log entry, such as :
##       1.1 timestamp
##       1.2 log level (INFO, WARN, ERROR, DEBUG)
##       1.3 the message.

log_file=/home/ayat/file.log

function Log_Parsing () {

    echo "--------------------------Log Parsing--------------------------------"
    echo "| Timestamp | Log Level | Message |"
    echo "|-----------|-----------|---------|"
    while read -r line ; do
        timestamp=$(echo "$line" | awk -F '] ' '{print $1}' | tr -d '[]')  
        log_level=$(echo "$line" |awk -F  ']' '{print $2}' | awk -F ' ' '{print $1}') 
        message=$(echo "$line" |awk -F  ']' '{print $2}' | sed 's/^[[:space:]]*//')  
        message="${message#* }"
        
        case "${log_level}" in
            WARN)
                echo "| $timestamp | $log_level | $message |"
                
            ;;
            INFO)
                echo "| $timestamp | $log_level | $message |"

            ;;
            ERROR)
                echo "| $timestamp | $log_level | $message |"
                
            ;;
            DEBUG)
                echo "| $timestamp | $log_level | $message |"
            ;;
            *)
            
                echo "default (none of above)"
            ;;
        esac
                                                                  
    done <$log_file
    echo "---------------------------------------------------------------------" 
    Operations
      
}

##   2. Filtering: Provide options to filter the log entries by log level. 
##     For example, a user might be interested only in ERROR and WARN level messages.

function Filtering () {

    echo "----------------------------Filtering--------------------------------"
    declare -A log_level_counts=()
    echo "Enter log levels (separated by spaces):"
    read -r log_levels
    IFS=' ' read -ra logs_to_track <<< "$log_levels"

    # Initialize counts for all log levels to 0
    for log_level in "${logs_to_track[@]}"; do
        log_level_counts[$log_level]=0
    done

    while read -r line; do
        timestamp=$(echo "$line" | awk -F '] ' '{print $1}' | tr -d '[]')
        log_level=$(echo "$line" | awk -F ']' '{print $2}' | awk -F ' ' '{print $1}')
        message=$(echo "$line" | awk -F ']' '{print $2}' | sed 's/^[[:space:]]*//')
        message="${message#* }"

        if [[ " ${logs_to_track[*]} " =~ ${log_level} ]]; then
            echo "| $timestamp | $log_level | $message |"
            ((log_level_counts[$log_level]++))
        fi
    done < "$log_file"

    echo "Log level counts:"
    for log_level in "${logs_to_track[@]}"; do
        echo "$log_level: ${log_level_counts[$log_level]}"
    done
    echo "---------------------------------------------------------------------"
    Operations
     
}

##   3. Error and Warning Summary: Summarize errors and warnings, providing counts and details 
##     for each type encountered in the log.

function Error_Warning_Summary () {
    
    echo "-----------------------------Summary---------------------------------"
    count_error=0
    count_warn=0
    while read -r line ; do
        timestamp=$(echo "$line" | awk -F '] ' '{print $1}' | tr -d '[]')  
        log_level=$(echo "$line" |awk -F  ']' '{print $2}' | awk -F ' ' '{print $1}') 
        message=$(echo "$line" |awk -F  ']' '{print $2}' | sed 's/^[[:space:]]*//') 
        message="${message#* }"
        case "${log_level}" in
            WARN)
                echo "| $timestamp | $log_level | $message |"
                ((count_warn++))
                
            ;;
            
            ERROR)
                echo "| $timestamp | $log_level | $message |" 
                ((count_error++))

            ;;
            
        esac 
    done <$log_file
    echo "number of errors :$count_error ,number of warnings :$count_warn"
    echo "---------------------------------------------------------------------" 
    Operations
    
}

##   4. Event Tracking: Track specific events, such as "System Startup Sequence Initiated" 
##      and "System health check OK", to ensure critical processes are starting and completing as expected.
 
 function Event_Tracking () {

    echo "-----------------------------Event Tracking-------------------------------"
    declare -A event_counts=()
    echo "Enter the events you want to track (type 'done' when finished):"
    declare -a events_to_track=()
    while true; do
        read -r event
        if [[ "$event" == "done" ]]; then
        break
        fi
        events_to_track+=("$event")
        event_counts["$event"]=0
    done

# Iterate through the log file and count the occurrences of the events
    while read -r line; do
        for event in "${events_to_track[@]}"; do
        events=$(echo "$line " | awk -F ']' '{print $2}')
        event_line="${events#* }"
        event_line="${event_line#* }"
        if [[ "$event_line" == *"$event"* ]]; then
            ((event_counts["$event"]++))
            echo "$line"
        fi
        done
    done < "$log_file"

    echo "Event counts:"
    for event in "${!event_counts[@]}"; do
    echo "$event: ${event_counts[$event]}"
    done
    echo "---------------------------------------------------------------------"
    Operations
}

##   5. Report Generation:Generate a report summarizing the findings, 
##      including any trends identified in the error/warning logs and the status of system events.
function Report () {

    echo "-------------------------------Log Report---------------------------------"
    echo ""
    count_error=0
    count_warn=0
    count_info=0
    count_debug=0
    echo "| Timestamp | Log Level | Message |"
    echo "|-----------|-----------|---------|"

    while read -r line; do
        timestamp=$(echo "$line" | awk -F '] ' '{print $1}' | tr -d '[]')
        log_level=$(echo "$line" | awk -F ']' '{print $2}' | awk -F ' ' '{print $1}')
        message=$(echo "$line" | awk -F ']' '{print $2}' | sed 's/^[[:space:]]*//')
        message="${message#* }"
        case "$log_level" in
            WARN)
                echo "| $timestamp | $log_level | $message |"
                ((count_warn++))
            ;;
            INFO)
                echo "| $timestamp | $log_level | $message |"
                ((count_info++))
            ;;
            DEBUG)
                echo "| $timestamp | $log_level | $message |"
                ((count_debug++))
            ;;
            ERROR)
                echo "| $timestamp | $log_level | $message |"
                ((count_error++))
            ;;
            *)
                echo "| $timestamp | UNKNOWN | $line |"
            ;;
        esac
    done < "$log_file"

    echo ""
    echo "Log Level Summary:"
    echo "- Errors: $count_error"
    echo "- Warnings: $count_warn"
    echo "- Information: $count_info"
    echo "- Debug: $count_debug"
    echo ""
    echo "----------------------------------------------------------------------"
    Operations
}

function Operations() {

    echo "Please select an operation:"
    echo "1. Log parsing ."
    echo "2. Filtering ."
    echo "3. Error and warn summary ."
    echo "4. Event tracking ."
    echo "5. Report ."
    echo "6. Exit ."
    read -r input 
    case "${input}" in
        1)
            Log_Parsing
        ;;
        2)
            Filtering
        ;;
        3)
            Error_Warning_Summary 
        ;;
        4)
            Event_Tracking
        ;;
        5)
            Report
        ;;
        6)
           return 
        ;;
        *)
            echo "default (none of above)"
        ;;
    esac
    
}


#!/bin/bash

LOG_DIR="/var/log/internal/log_util/"
LOG_FILES=("wp_cli.log" "wp_staging_app.log" "wp_update.log")

parse_wp_errors() {
    for logfile in "${LOG_FILES[@]}"; do
        full_path="${LOG_DIR}${logfile}"
        
        if [ ! -f "$full_path" ]; then
            echo "Warning: Log file not found: $full_path" >&2
            continue
        fi

        echo "Processing file: $full_path"
        echo "========================================"

        while IFS= read -r line; do
            if [[ "$line" == *"run_sub_cmd.started"* ]]; then
                timestamp=$(echo "$line" | grep -oP '\[\K[^\]]+')
                cmd=$(echo "$line" | grep -oP "cmd: '\K[^']+")
                current_cmd="$cmd"
                current_timestamp="$timestamp"
            fi
            
            if [[ "$line" == *"run_sub_cmd.failed"* && -n "$current_cmd" ]]; then
                error=$(echo "$line" | grep -oP "error: '\K[^']+")
                
                # Special formatting for 'wp wc update' error
                if [[ "$current_cmd" == *"wp wc update"* ]]; then
                    echo -e "\033[1;31m"  # Start red color
                    echo "TIMESTAMP: $current_timestamp"
                    echo "FILE: $logfile"
                    echo "COMMAND: $current_cmd"
                    echo "ERROR: $error"
                    echo -e "NOTE: 'wp wc update' is invalid. Did you mean:\n- 'wp woocommerce update'\n- 'wp plugin update woocommerce'\n- 'wp db update'?\033[0m"  # End color
                    echo "----------------------------------------"
                else
                    # Normal formatting for all other errors
                    echo "Timestamp: $current_timestamp"
                    echo "File: $logfile"
                    echo "Command: $current_cmd"
                    echo "Error: $error"
                    echo "----------------------------------------"
                fi
                
                current_cmd=""
                current_timestamp=""
            fi
        done < "$full_path"
    done
}

parse_wp_errors

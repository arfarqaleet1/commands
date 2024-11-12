#!/bin/bash
while :; do
        echo "Select an action: add, delete, blacklist, fullaccess. Type 'exit' to finish."
        read -p "Action: " ACTION

        if [[ "$ACTION" == "exit" ]]; then
            break
        elif [[ "$ACTION" != "add" && "$ACTION" != "delete" && "$ACTION" != "blacklist" && "$ACTION" != "fullaccess" ]]; then
            echo "Invalid action. Please choose from: add, delete, blacklist, fullaccess, or type 'exit' to finish."
            continue
        fi

        echo "Enter IP address or range. Type 'done' to finish."
        while :; do
            read -p "IP/Range: " IP_RANGE
            if [[ "$IP_RANGE" == "done" ]]; then
                break
            fi

            case $ACTION in
                add)
                    imunify360-agent ip-list local add --purpose white "$IP_RANGE"
                    echo "Added $IP_RANGE to whitelist"
                    ;;
                delete)
                    imunify360-agent ip-list local delete --purpose white "$IP_RANGE"
                    echo "Deleted $IP_RANGE from whitelist"
                    ;;
                blacklist)
                    imunify360-agent ip-list local add --purpose drop "$IP_RANGE" --comment "Blocking this IP"
                    echo "Added $IP_RANGE to blacklist"
                    ;;
                fullaccess)
                    imunify360-agent ip-list local add --purpose white "$IP_RANGE" --scope group --full-access --comment "Global Trusted IP"
                    echo "Added $IP_RANGE to whitelist with full access"
                    ;;
            esac
        done
    done

    echo "All IP ranges have been processed."

#!/bin/bash
dbname=$1

uncache(){
wp cache flush --skip-plugins --skip-themes --allow-root --all
wp elementor flush_css
redis-cli flushall
wp breeze purge --cache=all
}

ram(){
for A in $(ls -l /home/master/applications/| grep "^d" | awk '{print $NF}'); do echo -e "\n\nDatabase: $A" && awk 'NR==1 {print substr($NF, 1, length($NF)-1)}' /home/master/applications/$A/conf/server.nginx ; cat /home/master/applications/$A/logs/php-app.access.log | tr -d '\000'| sort -nbrk 13,13 | head | awk '{print $1,$3,$5,$16,"  ====>  ",$13/1024/1024, "MB of RAM consumed"}';done
}
appname(){
echo ""
read -p "Enter Url: " url
echo ""
echo -n "Application Name: "
echo ""
grep $url /home/master/applications/*/conf/server.nginx | cut -d ':' -f1 | cut -d '/' -f5
}

plugin1(){
for A in $( find /home/master/applications/* -maxdepth 0 -type d -printf '%f\n' | awk '{print $NF}'); do echo $A && cat $A/conf/server.nginx && cat $A/logs/php-app.slow.log* | grep -ai 'wp-content/plugins' | cut -d " " -f1 --complement | cut -d '/' -f8 | sort | uniq -c | sort -nr ; done
}

traffic(){
for A in $( find /home/master/applications/* -maxdepth 0 -type d -printf '%f\n' | awk '{print $NF}'); do echo $A && sudo apm traffic -s $A -l 5h && echo "----------------------------------------------------------------------------------------------------------"; done
}

mysqlslow() {
for A in $( find /home/master/applications/* -maxdepth 0 -type d -printf '%f\n' | awk '{print $NF}'); do echo $A && sudo apm mysql -s $A -l 5h && echo "----------------------------------------------------------------------------------------------------------"; done
}

slowpages() {
for A in $( find /home/master/applications/* -maxdepth 0 -type d -printf '%f\n' | awk '{print $NF}'); do echo $A && sudo apm php -s $A -l 5h && echo "----------------------------------------------------------------------------------------------------------"; done
}

#########################################################
cpuareeb(){
 curl https://raw.githubusercontent.com/ahmedeasypeasy/New-Cpu/main/Cpu.sh | bash
}

ttfb(){
         read -p "Enter the site URL: " siteurl
curl -o /dev/null -w "Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} \n" "$siteurl"

}

domain(){
find /home/*.cloudwaysapps.com/*/conf/ -type f -name 'server.nginx' -exec sh -c 'echo "$(basename "$(dirname "$(dirname {})")"):"; cat {} | grep -oP "server_name\\s+\\K[^;]+" && echo' \;

}
top5url(){
for app in /home/master/applications/*/logs/apache_*.access.log; do app_name=$(basename "$(dirname "$(dirname "$app")")"); echo "=== $app_name ==="; awk '{print $1,$7}' "$app" | cut -d? -f1 | sort | uniq -c | sort -nr | head -n 5 | awk -F";" '{print $1}'; echo; done

}
topvisit(){
for app in /home/master/applications/*/logs/apache_*.access.log; do app_name=$(basename "$(dirname "$(dirname "$app")")"); echo "=== $app_name ==="; awk '{print $1,$4}' "$app" | sort | uniq -c | sort -nr | head -n 10; echo; done

}
useragent(){
for app in /home/master/applications/*/logs/apache_*.access.log; do app_name=$(basename "$(dirname "$(dirname "$app")")"); echo "=== Top 5 Occurrences in $app_name ==="; awk '{print $12, $13, $14, $15}' "$app" | sort | uniq -c | sort -nr | head -n 5; echo; done

}
ddoscheck(){
cd /var/log/nginx/ && awk -v date="$(date -d '5 hours ago' '+%d/%b/%Y:%H:%M:%S')" '$4 > "["date {print $4, $1, $7}' access.log | sort | uniq -c | sort -nr | head -n 10 && cd /home/master/applications/

}
bandwidth(){
cd && for A in $(ls -l /home/master/applications/| awk '/^d/ {print $NF}'); do echo "" > total.txt ; echo $A && awk 'NR==1 {print substr($NF, 1, length($NF)-1)}' /home/master/applications/$A/conf/server.nginx ;for i in {30..0}; do zcat -f /home/master/applications/$A/logs/*_*.access.log*| awk -v day="$(date --date="$i days ago" '+%d/%b/%Y')" '$4 ~ day {sum += $10} END {print sum >> "total.txt" ; printf("%s %.3f %s\n", day, sum/1024/1024, "MB")}';done;awk '{total +=$1} END {printf ("%s %.3f %s\n", "Total:", total/1024/1024/1024, "GB")}' total.txt;done
}
bandwidthallapps(){
#!/bin/bash

for app_dir in /home/master/applications/*/; do
    app_name=$(basename "$app_dir")
    echo "Application: $app_name"
    echo "┌────────────┬─────────────────────────────────────────────────────────────────────┬────────────────────────────────────────────────────────┐"
    echo "│ Application                         URL                                                                            Bandwidth (MB) "
    echo "├────────────┼─────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────┤"

    for i in {30..0}; do 
        zcat -f "$app_dir/logs/"*_*.access.log*.gz | 
        awk -v day="$(date --date="$i days ago" '+%d/%b/%Y')" '$4 ~ day {sum += $10; url = $7} END {if (sum) print sum >> "/tmp/total.txt"; printf "│ %-31s │ %-80.80s │ %-15.3f │\n", day, url, sum/(1024*1024)}' ||
        echo "│ %-31s │ %-80.80s │ %-15.3f │\n" "$day" "No data found" 0
    done && 

    awk '{total += $1} END {printf "└────────────┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────┴────────────────┘\nTotal Bandwidth: %-15.3f MB\n", total/(1024*1024)}' /tmp/total.txt;

    # Cleanup: Remove temporary file
    rm /tmp/total.txt
    echo ""
done

}
bandwidthapp(){
# Ask for the application name
read -p "Enter the application name: " app_name

# Validate that the entered directory exists
app_path="/home/master/applications/$app_name"
if [ ! -d "$app_path" ]; then
    echo "Error: Directory '$app_path' does not exist."
    exit 1
fi

echo "Application: $app_name"
echo "┌────────────┬─────────────────────────────────────────────────────────────────────┬────────────────────────────────────────────────────────┐"
echo "│ Application                         URL                                                                            Bandwidth (MB) "
echo "├────────────┼─────────────────────────────────────────────────────────────────────┼────────────────────────────────────────────────────────┤"

for i in {30..0}; do 
    find "$app_path/logs/" -name "*_*.access.log*" -exec zcat -f {} + | 
    awk -v day="$(date --date="$i days ago" '+%d/%b/%Y')" '$4 ~ day {sum += $10; url = $7} END {if (sum) print sum >> "/tmp/total.txt"; printf "│ %-31s │ %-80.80s │ %-15.3f │\n", day, url, sum/(1024*1024)}' ||
    echo "│ %-31s │ %-80.80s │ %-15.3f │\n" "$day" "No data found" 0
done && 

awk '{total += $1} END {printf "└────────────┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────┴────────────────┘\nTotal Bandwidth: %-15.3f MB\n", total/(1024*1024)}' /tmp/total.txt;

# Cleanup: Remove temporary file
rm /tmp/total.txt
}

findfile() {
echo ""
read -p "Please enter file name: " file
result=$(find . -type f -name "*$file*" -print 2>/dev/null)

if [ -n "$result" ]; then
    echo "Here are the file paths:"
    echo ""
    echo "$result"
else
    echo ""
    echo "No matching files found."
fi

echo ""

}

findfolder(){

    echo ""
    read -p "Please enter directory name: " dir_name
        echo ""

    result=$(find . -type d -name "$dir_name")

    if [ -n "$result" ]; then
        echo "Here are the matching directory paths:"
        echo ""
        echo "$result"
    else
        echo "No matching directories found."
    fi

    echo ""
}
trafficdate(){
echo && read -p "Enter dbname: " dbname && echo && read -p "Enter start time (DD/MM/YYYY:HH:mm): " start_time && read -p "Enter end time (DD/MM/YYYY:HH:mm): " end_time && sudo /usr/local/sbin/apm traffic -s "$dbname" -f "$start_time" -u "$end_time"
}

phpdate(){
echo && read -p "Enter dbname: " dbname && echo && read -p "Enter start time (DD/MM/YYYY:HH:mm): " start_time && read -p "Enter end time (DD/MM/YYYY:HH:mm): " end_time && sudo /usr/local/sbin/apm php -s "$dbname" -f "$start_time" -u "$end_time"
}

sqldate(){
echo && read -p "Enter dbname: " dbname && echo && read -p "Enter start time (DD/MM/YYYY:HH:mm): " start_time && read -p "Enter end time (DD/MM/YYYY:HH:mm): " end_time && sudo /usr/local/sbin/apm mysql -s "$dbname" -f "$start_time" -u "$end_time"
}

trafficalldate(){
read -p "Enter the starting date and time (format: dd/mm/yyyy:HH:MM): " start_datetime
echo ""
read -p "Enter the ending date and time (format: dd/mm/yyyy:HH:MM): " end_datetime
echo ""
# Loop through applications and run the command
for A in $(find /home/master/applications/* -maxdepth 0 -type d -printf '%f\n' | awk '{print $NF}'); do
    echo "$A"
sudo /usr/local/sbin/apm traffic -s "$A" -f "$start_time" -u "$end_time"
   # sudo apm /usr/local/sbin/apm traffic -s $A -f $start_datetime -u $end_datetime"
    echo "----------------------------------------------------------------------------------------------------------"
done

}
sqlalldate(){
read -p "Enter the starting date and time (format: dd/mm/yyyy:HH:MM): " start_datetime
echo ""
read -p "Enter the ending date and time (format: dd/mm/yyyy:HH:MM): " end_datetime
echo ""
# Loop through applications and run the command
for A in $(find /home/master/applications/* -maxdepth 0 -type d -printf '%f\n' | awk '{print $NF}'); do
    echo "$A"
    sudo /usr/local/sbin/apm mysql -s "$A" -f "$start_datetime" -u "$end_datetime"
    echo "----------------------------------------------------------------------------------------------------------"
done
}

phpalldate(){
read -p "Enter the starting date and time (format: dd/mm/yyyy:HH:MM): " start_datetime
echo ""
read -p "Enter the ending date and time (format: dd/mm/yyyy:HH:MM): " end_datetime
echo ""
# Loop through applications and run the command
for A in $(find /home/master/applications/* -maxdepth 0 -type d -printf '%f\n' | awk '{print $NF}'); do
    echo "$A"
    sudo /usr/local/sbin/apm php -s "$A" -f "$start_datetime" -u "$end_datetime"
    echo "----------------------------------------------------------------------------------------------------------"
done
}
domainpoint(){
#!/bin/bash

for app_dir in /home/master/applications/*/; do
    app_name=$(basename "$app_dir")
        echo ""
    echo "DNS information for $app_name:"
    
    dig -f "${app_dir}/conf/server.nginx" +noall +answer | grep -v NS
    
    echo ""
done

}
nodeinstall(){
# Prompt user for Node.js version
echo ""
read -p "Enter Node.js Version (e.g., 18.17.0): " NODE_VERSION

# Source NVM and Installation script
INSTALL_SCRIPT=$(cat <<-EOF
  source ~/.nvm/nvm.sh
  nvm install $NODE_VERSION
  npm config set prefix \$NVM_DIR/versions/node/v$NODE_VERSION
EOF
)

# Execute the installation script
eval "$INSTALL_SCRIPT"
}

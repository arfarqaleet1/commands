uncache(){
wp cache flush --skip-plugins --skip-themes --allow-root
redis-cli flushall
 #       if redis-cli ping > /dev/null 2>&1;
  #      then
         #       redis-cli flushall > /dev/null;
   #             echo -e $(tput setaf 2)\033[1mSuccess\033[0m: $(tput setaf 7)Redis cache flushed"
       # fi
        #if wp core version >/dev/null 2>&1;
        #then
         #       wp cache flush > /dev/null;
                #echo -e $(tput setaf 2)\033[1mSuccess\033[0m: $(tput setaf 7)WP cache flushed"
                #if ! rm -rf ./wp-content/cache/;
                #then
                 #       echo -e $(tput setaf 1)\033[1mFailed\033[0m: $(tput setaf 7)Reset permissions and try again."
                #else echo -e "$(tput setaf 2)\033[1mSuccess\033[0m: $(tput setaf 7)wp-content/cache removed"
                #fi
        #elif php bin/magento --version >/dev/null 2>&1;
        #then
         #       php bin/magento cache:clean;
          #      php bin/magento cache:flush;
        #elif php artisan --version >/dev/null 2>&1;
        #then
         #       php artisan optimize:clear
        #fi
}

ram(){
for A in $(ls -l /home/master/applications/| grep "^d" | awk '{print $NF}'); do echo -e "\n\nDatabase: $A" && awk 'NR==1$
}
appname(){
read -p "Enter Url: " url
echo -n "Application Name: "
grep $url /home/master/applications/*/conf/server.nginx | cut -d ':' -f1 | cut -d '/' -f5
}

plugin1(){
for A in $( find /home/master/applications/* -maxdepth 0 -type d -printf '%f\n' | awk '{print $NF}'); do echo $A && cat $
}

traffic(){
for A in $( find /home/master/applications/* -maxdepth 0 -type d -printf '%f\n' | awk '{print $NF}'); do echo $A && sudo$
}

mysqlslow() {
for A in $( find /home/master/applications/* -maxdepth 0 -type d -printf '%f\n' | awk '{print $NF}'); do echo $A && sudo$
}

slowpages() {
for A in $( find /home/master/applications/* -maxdepth 0 -type d -printf '%f\n' | awk '{print $NF}'); do echo $A && sudo$
}

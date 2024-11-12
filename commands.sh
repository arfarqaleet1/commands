#!/bin/bash

uncache(){
wp cache flush --skip-plugins --skip-themes --allow-root --all
wp elementor flush_css
redis-cli flushall
wp breeze purge --cache=all
}
echo "hello there"

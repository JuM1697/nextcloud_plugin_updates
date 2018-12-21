#!/bin/bash
#Author: Justin Michael
#Date: 18.12.18
#Version: 1.1
#Requirements:
#	- sudo permissions for nagios user
#	- Nextcloud user (called "icinga") with admin permissions 

set -eu
nextcloud_user=""
nextcloud_password=""
nextcloud_url=""

sudo -u www-data /var/www/nextcloud/occ user:enable $nextcloud_user > /dev/null 

num_updates=`curl -s --user $nextcloud_user:$nextcloud_password $nextcloud_url | grep num_updates_availabl | sed 's/[^0-9]*//g'`

if [ $num_updates -ne 0 ]
then
	echo "Nextcloud Plugins CRITICAL - $num_updates updates are available"
	sudo -u www-data /var/www/nextcloud/occ user:disable icinga > /dev/null
	exit 2
else
	echo "Nextcloud Plugins OK - 0 updates are available"
	sudo -u www-data /var/www/nextcloud/occ user:disable icinga > /dev/null
	exit 0
fi

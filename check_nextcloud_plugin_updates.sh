#!/bin/bash
#Author: Justin Michael
#Requirements:
#	- sudo permissions for nagios user
#	- nextcloud user with admin permissions
set -eu
nextcloud_user=""
nextcloud_password=""
nextcloud_url=""

while getopts ":u:p:a:" opt; do
	case $opt in
		u)
			nextcloud_user=$OPTARG
			;;
		p)
			nextcloud_password=$OPTARG
			;;
		a)
			nextcloud_url=$OPTARG
			;;
		\?)
			echo "Invalid option: -$OPTARG"
			exit 5
			;;
		:)
			echo "Option -$OPTARG requires an argument."
			exit 5
			;;
	esac
done


if [ -z $nextcloud_user ] && [ -z $nextcloud_password ] && [ -z $nextcloud_url ]
then
	echo "Either provide a user with -u argument and a password with -p argument and an url with -a argument or define them in line #7, #8 and #9"
	exit 5
fi

if [ -z $nextcloud_user ]
then
	echo "Either provide a user with -u argument or define one in line #7"
	exit 5
fi

if [ -z $nextcloud_password ]
then
	echo "Either provide a password with -p argument or define one in line #8"
	exit 5
fi


if [ -z $nextcloud_url ]
then
	echo "Either provide an url with -a argument or define one in line #9"
	exit 5
fi

function finish
{
	sudo -u www-data /var/www/nextcloud/occ user:disable $nextcloud_user > /dev/null
}
trap finish EXIT

trap safety 1 2 3 6
safety()
{
	sudo -u www-data /var/www/nextcloud/occ user:disable $nextcloud_user > /dev/null
}


sudo -u www-data /var/www/nextcloud/occ user:enable $nextcloud_user > /dev/null 

num_updates=`curl -s --user $nextcloud_user:$nextcloud_password $nextcloud_url | grep num_updates_availabl | sed 's/[^0-9]*//g'`

if [ $num_updates -ne 0 ]
then
	echo "Nextcloud Plugins CRITICAL - $num_updates updates are available"
	exit 2
else
	echo "Nextcloud Plugins OK - 0 updates are available"
	exit 0
fi

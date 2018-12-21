#!/bin/bash
#Author: Justin Michael
#Requirements:
#	- sudo installed
#	- sudo permissions for nagios user
#	- nextcloud user with admin permissions
#	- curl installed
set -eu

#Pre-Definitions for variables.
nextcloud_user=""
nextcloud_password=""
nextcloud_url=""
webserver_user="www-data"
occ_command_path="/var/www/nextcloud/occ"

#Instead of using hard-coded variables, call the script using arguments.
while getopts ":u:p:a:w:o:" opt; do
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
		w)
			webserver_user=$OPTARG
			;;
		o)
			occ_command_path=$OPTARG
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


#Checking whether all necessary variables have been set or not.
if [ -z $nextcloud_user ] && [ -z $nextcloud_password ] && [ -z $nextcloud_url ] && [ -z $webserver_user ] && [ -z $occ_command_path ]
then
	echo "Use either arguments or pre-defined variables to use this script"
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

if [ -z $webserver_user ]
then
	echo "Either provide a webserver user with -w argument or define one in line #10"
	exit 5
fi

if [ -z $occ_command_path ]
then
	echo "Either provide an occ command path with -o argument or define one in line #11"
	exit 5
fi

#Two Shell traps to provide safety:
#First one disable the nextcloud user after the script exits as expected.
#Second one to disable the nextcloud user after the script gets killed by signals 1, 2, 3 or 6.
trap finish EXIT
function finish
{
	sudo -u $webserver_user $occ_command_path user:disable $nextcloud_user > /dev/null 2>&1
}

trap safety 1 2 3 6
safety()
{
	sudo -u $webserver_user $occ_command_path user:disable $nextcloud_user > /dev/null 2>&1
}


#Check the OCC command path to check if the file is executable
occ_exec=`sudo -u $webserver_user test -r $occ_command_path; echo $?`
if [ $occ_command_path -ne 0]
then
	echo "CRITICAL - $occ_command_path is not executable. Run: chmod u+x $occ_command_path to make it executable"
	exit 2
fi
#if [[ ! -x $occ_command_path ]]
#then
#	echo "CRITICAL - $occ_command_path is not executable. Run: chmod u+x $occ_command_path to make it executable"
#	exit 2
#fi


##Here comes the main Code
#Enabling the monitoring user with admin permissions using the occ command provided by nextcloud.
sudo -u $webserver_user $occ_command_path user:enable $nextcloud_user > /dev/null 

#Check whether username and password are correct and the permissions of the nextcloud user are OK
status_code=`curl -s --user $nextcloud_user:$nextcloud_password $nextcloud_url | grep statuscode | sed 's/[^0-9]*//g'`
if [ $status_code -ne 200 ]
then
	echo "UNKNOWN - There's something wrong with the Nextcloud user and/or password or the permissions of the Nextcloud user"
	exit 6
fi

#Calling the external monitoring xml page provided by nextcloud and grepping the output to have the number of available updates.
num_updates=`curl -s --user $nextcloud_user:$nextcloud_password $nextcloud_url | grep num_updates_available | sed 's/[^0-9]*//g'`

#Easy: Not 0 updates available? If so: exit in critical state and print the amount of available updates.
if [ $num_updates -ne 0 ]
then
	echo "Nextcloud Plugins CRITICAL - $num_updates updates are available"
	exit 2
else
	echo "Nextcloud Plugins OK - 0 updates are available"
	exit 0
fi

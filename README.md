# nextcloud_plugin_updates
This Nagios/Icinga plugin can be used to monitor whether there are any updates for Nextcloud Plugins available.

## Installation
1. Cloning the Repo  
   To clone the Repo just run:
   ```bash
   git clone https://github.com/JuM1697/nextcloud_plugin_updates.git
   ```
2. Grant all necessary users the permission to execute the script.
3. Copy the script in the desired location (mostly /usr/lib/nagios/plugins/
   ```bash
   cp nextcloud_plugin_updates/check_nextcloud_plugin_updates.sh #your_path_goes_here
   ```
4. Grant the nagios user sudo permissions  
   To execute the script without any issues, you need to grant the nagios user (or any other user that will run the script who is not root) some special sudo permissions. The recommended way to do so is:  
   Create a file in /etc/sudoers.d/ e.g.:
   ```bash
   vi /etc/sudoers.d/nagios
   ```
   after that add some lines that look somehow like that:
   ```bash
   #user_who_runs_the_script    ALL=(#webserver_user)  NOPASSWD:/usr/bin/test -x #path_to_your_occ_command
   #user_who_runs_the_script	  ALL=(#webserver_user)  NOPASSWD:#path_to_your_occ_command user\:enable #nextcloud_username_used_to_monitor
   #user_who_runs_the_script	  ALL=(#webserver_user)  NOPASSWD:#path_to_your_occ_command user\:disable #nextcloud_username_used_to_monitor
   ```
   For Debian users with a regular NRPE installation, Nextcloud in /var/www/nextcloud and a nextcloud user called "icinga" it would look like this:
   ```bash
   nagios     ALL=(www-data)  NOPASSWD:/usr/bin/test -x /var/www/nextcloud/occ
   nagios	  ALL=(www-data)  NOPASSWD:/var/www/nextcloud/occ user\:enable icinga
   nagios	  ALL=(www-data)  NOPASSWD:/var/www/nextcloud/occ user\:disable icinga
   ```
## FAQ
### Where do I find my Nextcloud monitoring XML Page?
To run the script properly you need to provide the URL to the Nextcloud external monitoring XML page. You can find it by accessing the following menues:
- settings
- Information
- Scroll all the way to the bottom and you'll have a field with a "copy url" button.
 The URL provided in that field is your link to the external monitoring XML page. Please note that only users with administrative permissions in Nextcloud can access it.
## Troubleshooting
### Describtion of Exit Codes
Exit Code | Meaning | Suggestion
----------|---------|-----------
0 | OK | nothing to do
2 | Critical | update plugins
5 | UNKNOWN | Issues with username/password/url variables
6 | UNKNOWN | Issues with the Nextcloud user (username, password or permissions wrong)
7 | UNKNOWN | OCC not executable

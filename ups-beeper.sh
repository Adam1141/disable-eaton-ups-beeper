#! /bin/bash

apt install nut -y

# add rules to /etc/udev/rules.d to change permission for UPS USB connection device file
rule_file="/etc/udev/rules.d/10-eaton-nut.rules"
rule_text='ACTION=="add", ATTRS{idVendor}=="0463", ATTRS{idProduct}=="ffff", MODE="0666", GROUP="nut"'

if [ ! -f "$rule_file" ]; then
	touch "$rule_file" && echo "$rule_text" > "$rule_file"
fi


# add user to /etc/nut/upsd.users
user_text="
[ups_admin]
password = 12345678
upsmon master
actions = SET
instcmds = ALL
"

user_exists=$( grep "ups_admin" /etc/nut/upsd.users )

if [ -z "$user_exists" ]; then
	echo "$user_text" >> /etc/nut/upsd.users
fi


# add ups to /etc/nut/ups.conf
ups_text="
[eaton]
driver = usbhid-ups
vendorid = 0463
port = auto
pollfreq = 30
"

ups_exists=$( grep "^\[eaton\]" /etc/nut/ups.conf )

if [ -z "$ups_exists" ]; then
	echo "$ups_text" >> /etc/nut/ups.conf
fi


# change mode to standalone in /etc/nut/nut.conf
sed -i "s/MODE=.*/MODE=standalone/" /etc/nut/nut.conf


# add MONITOR line to /etc/nut/hosts.conf, for web gui to work
#mon1_text='MONITOR eaton@localhost "Local UPS"'
#mon1_exists=$( grep "$mon1_text" /etc/nut/hosts.conf )
#if [ -z "$mon1_exists" ]; then
#	echo "$mon1_text" >> /etc/nut/hosts.conf
#fi


# add MONITOR line to /etc/nut/upsmon.conf
mon2_text='MONITOR eaton@localhost 1 ups_admin 12345678'
mon2_exists=$( grep "$mon2_text" /etc/nut/upsmon.conf )

if [ -z "$mon2_exists" ]; then
	echo "$mon2_text" >> /etc/nut/upsmon.conf
fi


# add new service unit to /etc/systemd/system/
# everytime the system starts and both nut-server.service and nut-driver.service
# are up and running, then call `upscmd beeper.disable eaton`
if [ ! -f /etc/systemd/system/disable-eaton-ups-beeper.service ]; then
	cp ./disable-eaton-ups-beeper.service /etc/systemd/system/disable-eaton-ups-beeper.service
	systemctl daemon-reload
	systemctl start disable-eaton-ups-beeper.service &>/dev/null &
	systemctl enable disable-eaton-ups-beeper.service
fi


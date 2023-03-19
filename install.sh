#!/bin/sh
if [ "$(id -u)" -ne 0 ]; then echo "Please run using sudo."; exit 1; fi

if [ -d /usr/src/asus-wmi-1.0 ] ; then
        while true; do
                read -p 'There seems to be a version installed already. Remove (recommended)? [Y/n] ' answer
                case $answer in
                        [Yy]* )
                                echo "Removing old version..."
                                dkms remove -m asus-wmi -v 1.0 --all
                                rm -r /usr/src/asus-wmi-1.0
                                break;;
                        [Nn]* ) break;;
                        * ) echo "Please enter either y or n.";;
                esac
        done
fi

echo "Installing current version..."

#downloading zip and unpacking it
mkdir /usr/src/asus-wmi-1.0
cd /usr/src/asus-wmi-1.0
wget 'https://github.com/Plippo/asus-wmi-screenpad/archive/master.zip'
unzip master.zip
mv asus-wmi-screenpad-master/* .
rmdir asus-wmi-screenpad-master
rm master.zip

# preparing for current kernel
sh prepare-for-current-kernel.sh

#registering with dkms and installing
dkms add -m asus-wmi -v 1.0
dkms build -m asus-wmi -v 1.0
dkms install -m asus-wmi -v 1.0

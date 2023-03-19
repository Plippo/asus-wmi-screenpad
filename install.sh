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

PATCH=false

while getopts p flag
do
    case "${flag}" in
        p) PATCH=true;;
    esac
done

if [ $PATCH = true ]; then
    # check if /usr/bin/patch exists
    if [ ! -f /usr/bin/patch ]; then
        # check if is using apt, dnf, yum, pacman, zypper, apk or pkg 
        if [ -f /usr/bin/apt ]; then
            apt install patch
        elif [ -f /usr/bin/dnf ]; then
            dnf install patch
        elif [ -f /usr/bin/yum ]; then
            yum install patch
        elif [ -f /usr/bin/pacman ]; then
            pacman -S patch
        elif [ -f /usr/bin/zypper ]; then
            zypper install patch
        elif [ -f /usr/bin/apk ]; then
            apk add patch
        elif [ -f /usr/bin/pkg ]; then
            pkg install patch
        else
            echo "Please install patch."
            exit 2
        fi
    fi
    echo "Patching...";

    VERSION=`uname -r | grep -o '^[0-9]\+\.[0-9]\+'`

    if { echo $VERSION ; echo "5.7" ; } | sort -V -c 2>/dev/null
    then
    PATCHFILE="patch"
    elif { echo $VERSION ; echo "5.99" ; } | sort -V -c 2>/dev/null
    then
    PATCHFILE="patch5.8"
    else
    PATCHFILE="patch6.0"
    fi

    echo "Using: $PATCHFILE"

    wget "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/drivers/platform/x86/asus-wmi.c?h=linux-$VERSION.y" -O 'asus-wmi.c'
    wget "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/drivers/platform/x86/asus-wmi.h?h=linux-$VERSION.y" -O 'asus-wmi.h'
    wget "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/drivers/platform/x86/asus-nb-wmi.c?h=linux-$VERSION.y" -O 'asus-nb-wmi.c'
    patch -p1 < $PATCHFILE
    rm *.orig
    echo "Patch complete.";
fi

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
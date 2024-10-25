#!/bin/sh
VERSION=`uname -r | grep -o '^[0-9]\+\.[0-9]\+'`

if { echo $VERSION ; echo "5.7" ; } | sort -V -c 2>/dev/null
then
  PATCHFILE="patch"
elif { echo $VERSION ; echo "5.99" ; } | sort -V -c 2>/dev/null
then
  PATCHFILE="patch5.8"
elif { echo $VERSION ; echo "6.10" ; } | sort -V -c 2>/dev/null
then
  PATCHFILE="patch6.0"
else
  PATCHFILE="patch6.11"
fi

echo "Using: $PATCHFILE - version: $VERSION"

wget "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/drivers/platform/x86/asus-wmi.c?h=linux-$VERSION.y" -O 'asus-wmi.c'
wget "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/drivers/platform/x86/asus-wmi.h?h=linux-$VERSION.y" -O 'asus-wmi.h'
wget "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/drivers/platform/x86/asus-nb-wmi.c?h=linux-$VERSION.y" -O 'asus-nb-wmi.c'
patch -p1 < $PATCHFILE
rm *.orig

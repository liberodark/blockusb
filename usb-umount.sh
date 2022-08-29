#!/bin/bash
#
# About: Block USB
# Author: sbarjatiya
# Thanks : Kiran Kollipara, Krati Jain, liberodark
# License: GNU GPLv3

version="0.0.1"

echo "Welcome on Block USB Script $version"

# List of allowed device IDS separated by space
ALLOWED_DEVICE_IDS="/dev/disk/by-id/usb-JetFlash_Transcend_8GB_SA1LX3TR-0:0 /dev/disk/by-id/usb-SanDisk_Cruzer_Blade_20060877201DE920DA7B-0:0"

# Admin email ID
ADMIN_EMAIL="my_email@example.com"

# Get current Device ID
DEVICE_ID=$(udisks --enumerate-device-files | grep '/usb-.*0:0$')

# Record current run for future reference purposes
echo "Handler ran at " $(date) " for " $DEVICE_ID >> /var/log/usb-lock.log

# Do not continue if DEVICE_ID is empty
if [[ "$DEVICE_ID" == "" ]]; then
   exit 0
fi

# if device is new allowed then exit script
for CURRENT_ID in $ALLOWED_DEVICE_IDS; do
    echo "Comparing $CURRENT_ID with $DEVICE_ID" >> /var/log/usb-lock.log
    if [[ "$CURRENT_ID" == "$DEVICE_ID" ]] ; then
        echo "Allowed device $DEVICE_ID connected " >> /var/log/usb-lock.log  
        exit 0
    fi
done

# If device is not allowed then get its device-file (/dev/sdb etc.) name
DEVICE_FILE=$(udisks --show-info $(udisks --enumerate-device-files | grep '/usb-.*0:0$') | grep device-file | sed 's/device-file://')

# Get list of all mounted partitions for this device
MOUNTED_PARTITIONS=$(mount | grep $DEVICE_FILE | grep -o '^[^ ]* ')

# Umount all mounted partitions
for PARTITION in $MOUNTED_PARTITIONS; do 
    udisks --unmount $PARTITION
done

# Detach drive
udisks --detach $DEVICE_FILE

# Send email about detached device
HOSTNAME=$(hostname --fqdn)
IFCONFIG=$(/sbin/ifconfig)
LOGGED_IN_USERS=$(w)
mail -s "Unauthorized USB DEVICE $DEVICE_ID connected" $ADMIN_EMAIL <<EOF
Dear Admin,
Unauthorized USB DEVICE $DEVICE_ID was connected to machine with following details:

HOSTNAME = $HOSTNAME

IP_ADDRESS = $IFCONFIG

LOGGED_IN_USERS = $LOGGED_IN_USERS

The device was umounted as per policy.  Please take necessary action.

Regards,
Umount script
EOF

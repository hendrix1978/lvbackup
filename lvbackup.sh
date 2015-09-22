#!/bin/bash
BACKUPDAE`date +'%Y_%m_%d'`
PASSWD='' # password to the save
BACKUPPATH=/media/hendrix/bacup02/lvsave
LVLIST=/root/.lvs

if !([ -d $BACKUPPATH  ]); then
    echo "$BACKUPPATH not exist..."
    exit
fi
mkdir -p $BACKUPPATH/$BACKUPDATE
for LVNAME in $(cat $LVLIST); do
    LVSIZE=`lvdisplay /dev/system/$LVNAME | grep "LV Size" | awk '{print $3}'`
    echo "Saving $LVNAME lv..."
    lvcreate -L${LVSIZE}G -s -n ${LVNAME}backup /dev/system/$LVNAME
    if [ -h /dev/system/${LVNAME}backup ]; then
        mount -o ro /dev/system/${LVNAME}backup /mnt/save
        tar cvzf - /mnt/save | openssl des3 -salt -k $PASSWD | dd of=$BACKUPPATH/$BACKUPDATE/${LVNAME}save.tar.gz
	umount /mnt/save
	lvremove -f /dev/system/${LVNAME}backup
    else
	echo "A ${LVNAME}backup lvm snapshot not created..."
    fi
done
#Decrypting Your File
# dd if=lvs.tar.gz |openssl des3 -d -k #YOUR PASSWORD# |tar xvzf -
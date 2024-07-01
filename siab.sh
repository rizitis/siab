#!/bin/bash

# Anagnostakis Ioannis GR (rizitis) 04/2024
# Slackware Initrd And Bootloader (siab) is a merge of 3 projects.
# autoslack-initrd, slackup-grub and auto-elilo.
# You can use it on UEFI Slackware64 systems.

# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# root
if [ "$EUID" -ne 0 ];then
echo "ROOT ACCESS PLEASE OR GO HOME..."
exit 1
fi


# autoslack-initrd dir
dir=/usr/local/autoslack-initrd
file=/usr/local/autoslack-initrd/autoslack-initrd.TXT
file2=/usr/local/autoslack-initrd/autoslack-initrd.BAK
file3=/usr/local/autoslack-initrd/autoslack-initrd
# slackup-grub dir and grub-install
dirg=/usr/local/slackup-grub
fileg=/usr/local/slackup-grub/slackup-grub.TXT
fileg2=/usr/local/slackup-grub/slackup-grub.BAK
dirgg=/usr/local/slackgrub-install
filegg=/usr/local/slackgrub-install/slackgrub-install.TXT
filegg2=/usr/local/slackgrub-install/slackgrub-install.BAK
# auto-elilo then mkdir
direl=/usr/local/auto-elilo
fileel=/usr/local/auto-elilo/auto-elilo.TXT
fileel2=/usr/local/auto-elilo/auto-elilo.BAK

set -e

if [ -d "$dir" ]
then
echo "SIAB is installed"
else
mkdir -p "$dir" || exit 
/bin/ls -tr /var/lib/pkgtools/packages | grep kernel | tail -2 > "$file"
echo "Looks like you are running autoslack-initrd for first time?"
mkdir -p "$dirg"
/bin/ls -tr /var/log/pkgtools/removed_scripts/ | grep kernel | tail -4 > "$fileg"
mkdir -p "$dirgg"
ls /var/adm/packages/ | grep ^grub > "$filegg"
echo "Looks like you are running slackup-grub and slackgrub-install for first time?"
mkdir -p "$direl"
/bin/ls -tr /var/log/pkgtools/removed_scripts/ | grep kernel | tail -4 > "$fileel"
echo "Looks like you are running auto-elilo for first time?"
exit
fi

cd "$dirgg" || exit
if [ -f /usr/local/slackgrub-install/slackgrub-install.TXT ]
then 
mv "$filegg" "$filegg2" || exit
else 
echo "************************************"
echo "Something went wrong, grub-install ATTENSION... *"
echo "************************************"
exit 3
fi

set -e

if [ -f "$filegg2" ]
then 
ls /var/adm/packages/ | grep ^grub > "$filegg"
fi
if cmp -s slackgrub-install.TXT slackgrub-install.BAK ; then
echo "NO GRUB UPDATE WAS FOUND"
sleep 1
else
echo "GRUB WAS UPDATED, REINSTALL-UPDATING GRUB..."
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub --recheck #--debug
wait
grub-mkconfig -o /boot/grub/grub.cfg
fi

cd "$dir" || exit
/bin/ls -tr /var/lib/pkgtools/packages | grep kernel | tail -2 > "$file3"

if [ -f /usr/local/autoslack-initrd/autoslack-initrd.TXT ]
then 
mv "$file" "$file2" || exit
else 
echo "************************************"
echo "Something went wrong, ATTENSION... *"
echo "************************************"
exit 2
fi


if [ -f "$file2" ]
then 
/bin/ls -tr /var/lib/pkgtools/packages | grep kernel | tail -2 > "$file"
fi

# we will remove the "-c" (clear) option from mkinitrd, else if second generic kernel exist...boom
filename="autoslack-initrd.sh"
Clear="mkinitrd -c"
NOClear="mkinitrd"
if cmp -s autoslack-initrd.TXT autoslack-initrd.BAK ; then
echo "autoslack-initrd message:"
echo "NO KERNEL UPDATE WAS FOUND"
sleep 2
else
echo "KERNEL WAS UPDATED, FIXING GENERIC KERNEL..."
sed -i '/kernel-source/d' /usr/local/autoslack-initrd/autoslack-initrd
wait
sed -i 's/kernel-modules-//g' /usr/local/autoslack-initrd/autoslack-initrd
wait
sed -i 's/-x/\n/g' /usr/local/autoslack-initrd/autoslack-initrd
wait
sed -i '$d' /usr/local/autoslack-initrd/autoslack-initrd
wait 
VERSION=$(cat $file3)
echo "$VERSION"
bash /usr/share/mkinitrd/mkinitrd_command_generator.sh -k "$VERSION" > /usr/local/autoslack-initrd/autoslack-initrd.sh
sleep 1
sed -i "s/$Clear/$NOClear/" /usr/local/autoslack-initrd/autoslack-initrd.sh
wait
bash /usr/local/autoslack-initrd/autoslack-initrd.sh
echo "autoslack-initrd finish its job"
echo "time for bootloader to do its job..."
echo ""
fi

# BOOTLOADER
# Get the current bootloader ID
BOOT_CURRENT=$(efibootmgr -v | grep "BootCurrent" | awk '{print $2}')

# GRUB
# Apply logic based on the bootloader ID
case $BOOT_CURRENT in
    "0000")
echo "GRUB is the current bootloader."
if [ -d "$dirg" ]
then
echo "slackup-grub is installed"
else
mkdir -p "$dirg"
/bin/ls -tr /var/log/pkgtools/removed_scripts/ | grep kernel | tail -4 > "$fileg"
echo "Looks like you are running slackup-grub for first time?"
exit
fi

cd "$dirg" || exit

if [ -f /usr/local/slackup-grub/slackup-grub.TXT ]
then 
mv "$fileg" "$fileg2" || exit
else 
echo "************************************"
echo "Something went wrong, ATTENSION... *"
echo "************************************"
exit 3
fi

set -e

if [ -f "$fileg2" ]
then 
/bin/ls -tr /var/log/pkgtools/removed_scripts/ | grep kernel | tail -4 > "$fileg"
fi

if cmp -s slackup-grub.TXT slackup-grub.BAK ; then
echo "NO KERNEL UPDATE WAS FOUND"
sleep 2
else
echo "KERNEL WAS UPDATED, UPDATING GRUB..."
 grub-mkconfig -o /boot/grub/grub.cfg
fi
# ELILO
 ;;
    "0002")
echo "ELILO is the current bootloader."
if [ -d "$direl" ]
then
echo "auto-elilo is installed"
else
mkdir -p "$direl"
/bin/ls -tr /var/log/pkgtools/removed_scripts/ | grep kernel | tail -4 > "$fileel"
echo "Looks like you are running auto-elilo for first time?"
exit
fi

cd "$direl" || exit

if [ -f /usr/local/auto-elilo/auto-elilo.TXT ]
then 
mv "$fileel" "$fileel2" || exit
else 
echo "************************************"
echo "Something went wrong, ATTENSION... *"
echo "************************************"
exit 4
fi

set -e

if [ -f "$fileel2" ]
then 
/bin/ls -tr /var/log/pkgtools/removed_scripts/ | grep kernel | tail -4 > "$fileel"
fi

if cmp -s auto-elilo.TXT auto-elilo.BAK ; then
echo "NO KERNEL UPDATE WAS FOUND"
sleep 2
else
echo "KERNEL WAS UPDATED, UPDATING ELILO..."
 eliloconfig
fi
;;
    *)
        echo "***********************************************************"
        echo "Unknown or not supported bootloader with ID $BOOT_CURRENT *"
        echo "***********************************************************"
        sleep 3
        ;;
esac



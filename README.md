# SIAB



> **S**lackware
>   
>**I**nitrd 
>  
> **A**nd
>  
>**B**ootloader 


*Slackware Initrd And Bootloader (siab) is a merge of 4 projects.
[autoslack-initrd](https://github.com/rizitis/autoslack-initrd/tree/main) , [slackup-grub](https://github.com/rizitis/slackup-grub) and [auto-elilo](https://github.com/rizitis/auto-elilo/tree/main)
And auto grub-install if Grub version uptated from Slackware64 (slackpkg)
 You can use it **ONLY** on UEFI Slackware64 systems.*


## Usage
During shutdown script check if slackpkg upgraded your linux kernel or bootloader and if so it will:
* Create an initrd for new kernel
- Check if you use elilo or Grub 
+ Reinstall and update your bootloader

*Note that it not working for custom builded kernels. If you build your own kernel*
*then you should update your bootloader manually also...*

### Install

1. Download siab.sh from [here](https://raw.githubusercontent.com/rizitis/siab/main/siab.sh) and place it in `/etc/rc.d/`
2. `chmod +x /etc/rc.d/siab.sh`
3. Edit or create if not exist a file `/etc/rc.d/rc.local_shutdown`
4. Add in this file in:  
 
 ``` 
 # siab
if [ -x /etc/rc.d/siab.sh ]; then
   /etc/rc.d/siab.sh
fi
```


5. Now you must run as root siab.sh manually for first time:

`/etc/rc.d/siab.sh`

Manually is only onces after the first installation.  
This way siab will create the database needed. After that it will auto-run in every shutdown-reboot and do what it have to do, if needed. 

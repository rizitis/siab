# SIAB



> **S**lackware
>   
>**I**nitrd 
>  
> **A**nd
>  
>**B**ootloader 


*Slackware Initrd And Bootloader (siab) is a merge of 3 projects.
[autoslack-initrd](https://github.com/rizitis/autoslack-initrd/tree/main) , [slackup-grub](https://github.com/rizitis/slackup-grub) and [auto-elilo](https://github.com/rizitis/auto-elilo/tree/main)
 You can use it on UEFI Slackware64 systems.*


## Usage
During shutdown script check if slackpkg upgraded your linux kernel and if so it will:
* Create an initrd for new kernel
- Check if you use elilo or Grub
+ Update your bootloader

*Note that it not working for custom builded kernels. If you build your own kernel*
*then you should update your bootloader manually also...*

### Install

1. Download siab.sh from here and place it in `/etc/rc.d/`
2. `chmod +x /etc/rc.d/siab.sh`
3. Edit or create if not exist a file `/etc/rc.d/rc.local_shutdown`
4. Add in this file:  
 
 ``` 
 # siab
if [ -x /etc/rc.d/siab.sh ]; then
   /etc/rc.d/siab.sh
fi
```


5. Now you must run as root siab.sh manually:

`/etc/rc.d/siab.sh`

Manuall is only onces after the first installation.  
This way siab will create the database needed. After that it will auto-run in every shoutdown-reboot and do what it have to do, if needed. 
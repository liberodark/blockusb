# blockusb

## Install 

### Dowload :
`wget -O /usr/bin/usb-umount.sh https://raw.githubusercontent.com/liberodark/blockusb/master/usb-umount.sh`

### Make executable : 
`chmod +x /usr/bin/usb-umount.sh`

### Create file usb-umount.rules :
`nano /etc/udev/rules.d/100-usb-umount.rules`

### Add in usb-umount.rules :
`KERNEL=="sd*", ACTION=="add", RUN+="/usr/bin/usb-umount.sh"`

### Reload udevadm :
`udevadm control --reload-rules`

By :
liberodark
sbarjatiya
Kiran Kollipara
Krati Jain

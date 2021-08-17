# asus-wmi-screenpad
This repository contains a version of the asus-wmi module with support for brightness control on secondary screens ("ScreenPad Plus") on ASUS Zenbook Duo notebooks. It also adds a few keys from the Zenbook Duo keyboard (Camera, /A, screen switch, toggle ScreenPad) so they can be mapped in your desktop environment.

To install and use this module using dkms:

0. Please make sure that you are running the kernel that you want to install the module for. So if you did a kernel update, please reboot first so the installation uses the correct kernel version.

1. Install DKMS using the method of your distribution.
   Debian/Ubuntu/etc.: `sudo apt install dkms`
   In addition to that, you need to have the headers for your current kernels installed. Most distributions provide a package for that.
   E.g. Ubuntu: `sudo apt install linux-headers-5.4.0-37` (replace by the correct version as determined by `uname -r`)
   
2. Create a directory for the module and download the source code
   ```
   sudo mkdir /usr/src/asus-wmi-1.0
   cd /usr/src/asus-wmi-1.0
   sudo wget 'https://github.com/Plippo/asus-wmi-screenpad/archive/master.zip'
   sudo unzip master.zip
   sudo mv asus-wmi-screenpad-master/* .
   sudo rmdir asus-wmi-screenpad-master
   sudo rm master.zip
   ```
   Now the source code should be in `/usr/src/asus-wmi-1.0`. It's important that the folder is called exactly like that because DKMS expects that.
   Alternatively you can of course also clone this git repository into that folder.

3. If not using kernel 5.4: Call the following script to download and patch files fitting to your kernel version
   ```
   sudo sh prepare-for-current-kernel.sh
   ```

4. Register the module with DKMS
   ```
   sudo dkms add -m asus-wmi -v 1.0
   ```

5. Build and install the module to the current kernel
   ```
   sudo dkms build -m asus-wmi -v 1.0
   sudo dkms install -m asus-wmi -v 1.0
   ```
   From now on, DKMS will automatically rebuild the module on every kernel update.

6. After rebooting, you should now find a new device in `/sys/class/leds/asus::screenpad`.
   To set the brightness of the screen, simply call
   ```
   echo XXX | sudo tee '/sys/class/leds/asus::screenpad/brightness'
   ```
   where XXX is a value between 0 and 255 (0 turns the screen completely off, 255 sets it to maximum brightness.
   To allow every user to set the brightness without using sudo, call
   ```
   sudo chmod a+w '/sys/class/leds/asus::screenpad/brightness'
   ```
   Now you can set the brightness by simply executing
   ```
   echo XXX > '/sys/class/leds/asus::screenpad/brightness'
   ```
   `chmod` has to be executed again after every reboot, so it is advisable to add the call to a boot script, e.g. `/etc/rc.local`.
   
7. You can now also use the functionality of your Desktop Environment to map the function keys on the keyboard to actions of your choice. For example, you can create a script that toggles the state of the screenpad and map it to the "Toggle ScreenPad" key.



### Troubleshooting
On some kernels, it might happen that the built-in module overrides our compiled module.
In this case, it might help to execute the following code afterwards:
```bash
cd /lib/modules/YOURKERNELVERSION/kernel/drivers/platform/x86
sudo mv  asus-nb-wmi.ko asus-nb-wmi.ko_bak
sudo mv asus-wmi.ko asus-wmi.ko_bak
sudo ln -s ../../../../extra/asus-nb-wmi.ko ./
sudo ln -s ../../../../extra/asus-wmi.ko ./
sudo depmod -a
```



### Removing or reinstalling
If you want to re-download and reinstall the kernel module (maybe because there have been changes in the code), you have to remove the old one first, calling
```
sudo dkms remove -m asus-wmi -v 1.0 --all
sudo rm -r /usr/src/asus-wmi-1.0
```
Then repeat the steps above from step 2 on.

### Major kernel updates
After a major kernel update (e.g. from 5.8 to 5.10), DKMS cannot update the module automatically as the new kernel sources need to be downloaded and patched. In this case, please uninstall and reinstall the module as described above under *Removing or reinstalling*.

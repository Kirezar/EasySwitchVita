# EasySwitchVita
Plugin toggler for PSVita

EasySwitchVita aims to simplify the transition between playing the PS Vita as a handheld, and playing it on a big screen by allowing you to toggle the required plugins on and off and rebooting, as fast as one click, without the need to mess with the configuration files.

### [Download Here](https://github.com/Kirezar/EasySwitchVita/releases)

## Supported Plugins

EasySwitchVita supports the following plugins

* [udcd_uvc by xerpi](https://bitbucket.org/xerpi/vita_udcd_uvc/overview)
* [ds3vita by xerpi](https://github.com/xerpi/ds3vita)
* [ds4vita by xerpi](https://github.com/xerpi/ds4vita)
* [MiniVitaTV and ds3 by TheOfficialFlow](https://github.com/TheOfficialFloW/MiniVitaTV)

## Guide
After opening, the app will show what plugins from the list above you have installed and their current state. Green means the plugin is currently on, and red means it's currently off. If the plugin is not found in the config file, it will show as Not Found.
By default the toggling of all plugins is off. This is shown as the plugin having a ' **_** ' in front of its name. You can navigate to the plugin name and press X (Cross Button) to change if it will toggle when you restart. This is marked by having a ' **X** ' in front of the plugin name.

Once you've chosen what plugins you want to be toggled, you can choose the time it takes for the app to reboot (the default time is 3 seconds) and if you want the app to auto reboot and toggle the plugins when you start it the next time.

When you have everything set up, just press the **Switch!** button and the PSVita will restart and toggle the plugins you chose (If the plugin was on, then it will be turned off, and if it was off then it will be turned on)

If you have the app set to auto reboot, but you want to change the settings, you can hold the **L** trigger whent he app starts, and it will take you to the configuration.

## File locations and Backups

The configuration file for the app is stored on **ux0:data/EasySwitchVita/ez_config.txt**
Backups for the main configuration file are stored on **ux0:data/EasySwitchVita/config_backup_switch.txt** and **ur0:tai/config_backup_switch.txt**

## Known issues and help needed

Currently only supports the config.txt file stored in **ur0:tai/**, no support implemented for config files in **ux0:tai/**

Application was developed in a firmware version **3.65** PS Vita, and has not been tested in any other version. I appreciate the testing of the app in different firmwares!

## Build

If you want to build it from source yourself, you are free to do so, download https://github.com/Rinnegatamante/lpp-vita and follow the instructions on the readme file.

## Disclaimer and Thanks

I am not responsible for what might happen to your PSVita system if the application is used outside the tested environments. It may lead to loss of information. Fully tested and working on a firmware **3.65** system running Enso

### Thanks to the following people

* [xerpi](https://github.com/xerpi/) for udcd_uvc, ds3vita and ds4vita
* [TheOfficialFlow](https://github.com/TheOfficialFloW/) for minivitatv and ds3, and all his hardwork for the PSVita community!
* [Rinnegatamante](https://github.com/Rinnegatamante/) for lpp-vita
* [theheroGAC](https://github.com/theheroGAC/) for AutoPlugin, which I took inspiration from for editing the config file to edit the plugins

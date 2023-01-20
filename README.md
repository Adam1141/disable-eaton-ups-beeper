# Disable Eaton UPS Beeper
## Requirements

    
```notes
Things needed:
    1. Debian/Ubuntu Linux OS
    2. Eaton UPS connected with a USB cable
``` 
## Uasge

```notes
    1. git clone https://github.com/Adam1141/disable-eaton-ups-beeper
    2. cd ./disable-eaton-ups-beeper
    3. sudo ./ups-beeper.sh
    4. reboot the system to take effect:
        shutdown -r now
    
    5. check Eaton UPS variables:
        upsc eaton
        
        you should see `ups.beeper.status: disabled`

```


## Other

https://github.com/networkupstools/nut

https://networkupstools.org/

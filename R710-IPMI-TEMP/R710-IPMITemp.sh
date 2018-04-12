#!/usr/bin/env bash

# ----------------------------------------------------------------------------------
# Script for checking the temperature reported by the ambient temperature sensor, 
# and if deemed to high send the raw IPMI command to enable dynamic fan control.
#
# Requires ipmitool – apt-get install ipmitool
# Tested on Ubuntu 17.04
# ----------------------------------------------------------------------------------


# IPMI DEFAULT R710 SETTINGS
# Modify to suit your needs.
IPMIHOST=192.168.0.120
IPMIUSER=root
IPMIPW=calvin

# TEMPERATURE
# Change this to the temperature in celcius you are comfortable with. 
# If it goes above it will send raw IPMI command to enable dynamic fan control
MAXTEMP=27

# This variable sends a IPMI command to get the temperature, and outputs it as two digits.
# Do not edit unless you know what you do.
TEMP=$(ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW sdr type temperature |grep Ambient |grep degrees |grep -Po '\d{2}' | tail -1)


if [[ $TEMP > $MAXTEMP ]];
  then
    printf "Temperature is too high! Activating dynamic fan control! ($TEMP C)" | systemd-cat -t R710-IPMI-TEMP
    echo "Temperature is too high! Activating dynamic fan control! ($TEMP C)"
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x01
  else
    # healthchecks.io
    curl -fsS --retry 3 https://hchk.io/8470021f-33f3-4a31-b2cd-741f28c47164 >/dev/null 2>&1
    printf "Temperature is OK ($TEMP C)" | systemd-cat -t R710-IPMI-TEMP
    echo "Temperature is OK ($TEMP C)"
fi
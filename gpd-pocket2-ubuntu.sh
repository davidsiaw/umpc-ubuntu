#!/usr/bin/env bash

function enable_gpd_pocket_config() {
  # Install the GPD Pocket hardware configuration
  mkdir -p "${XORG_CONF_PATH}"

  # Rotate the monitor.
  cat << MONITOR > "${MONITOR_CONF}"
Section "Monitor"
  Identifier "${PRIMARY_DISPLAY}"
  Option     "Rotate"  "right"
EndSection
MONITOR

  # Rotate the touchscreen.
  cat << TOUCHSCREEN > "${TOUCH_CONF}"
Section "InputClass"
  Identifier   "calibration"
  MatchProduct "Goodix Capacitive TouchScreen"
  Option       "TransformationMatrix"  "0 1 0 -1 0 1 0 0 1"
EndSection
TOUCHSCREEN

  # Rotate the framebuffer
  sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet/GRUB_CMDLINE_LINUX_DEFAULT="fbcon=rotate:1 quiet/' /etc/default/grub
  update-grub

  if [ ${BRCM4356} -eq 1 ]; then
    cat << 'WIFI' > ${WIFI_CONF}
# Sample variables file for BCM94356Z NGFF 22x30mm iPA, iLNA board with PCIe for production package
NVRAMRev=$Rev: 373428 $
#4356 chip = 4354 A2 chip
sromrev=11
boardrev=0x1101
boardtype=0x073e
boardflags=0x02400201
#0x2000 enable 2G spur WAR
boardflags2=0x00802000
boardflags3=0x0000000a
#boardflags3 0x00000100 /* to read swctrlmap from nvram*/
#define BFL3_5G_SPUR_WAR   0x00080000   /* enable spur WAR in 5G band */
#define BFL3_AvVim   0x40000000   /* load AvVim from nvram */
macaddr=00:90:4c:1a:10:01
ccode=X2
regrev=1
antswitch=0
pdgain5g=4
pdgain2g=4
tworangetssi2g=0
tworangetssi5g=0
paprdis=0
femctrl=10
vendid=0x14e4
devid=0x43a3
manfid=0x2d0
#prodid=0x052e
nocrc=1
otpimagesize=502
xtalfreq=37400
rxgains2gelnagaina0=0
rxgains2gtrisoa0=7
rxgains2gtrelnabypa0=0
rxgains5gelnagaina0=0
rxgains5gtrisoa0=11
rxgains5gtrelnabypa0=0
rxgains5gmelnagaina0=0
rxgains5gmtrisoa0=13
rxgains5gmtrelnabypa0=0
rxgains5ghelnagaina0=0
rxgains5ghtrisoa0=12
rxgains5ghtrelnabypa0=0
rxgains2gelnagaina1=0
rxgains2gtrisoa1=7
rxgains2gtrelnabypa1=0
rxgains5gelnagaina1=0
rxgains5gtrisoa1=10
rxgains5gtrelnabypa1=0
rxgains5gmelnagaina1=0
rxgains5gmtrisoa1=11
rxgains5gmtrelnabypa1=0
rxgains5ghelnagaina1=0
rxgains5ghtrisoa1=11
rxgains5ghtrelnabypa1=0
rxchain=3
txchain=3
aa2g=3
aa5g=3
agbg0=2
agbg1=2
aga0=2
aga1=2
tssipos2g=1
extpagain2g=2
tssipos5g=1
extpagain5g=2
tempthresh=255
tempoffset=255
rawtempsense=0x1ff
pa2ga0=-147,6192,-705
pa2ga1=-161,6041,-701
pa5ga0=-194,6069,-739,-188,6137,-743,-185,5931,-725,-171,5898,-715
pa5ga1=-190,6248,-757,-190,6275,-759,-190,6225,-757,-184,6131,-746
subband5gver=0x4
pdoffsetcckma0=0x4
pdoffsetcckma1=0x4
pdoffset40ma0=0x0000
pdoffset80ma0=0x0000
pdoffset40ma1=0x0000
pdoffset80ma1=0x0000
maxp2ga0=80
maxp5ga0=78,78,78,78
maxp2ga1=80
maxp5ga1=78,78,78,78
cckbw202gpo=0x0000
cckbw20ul2gpo=0x0000
mcsbw202gpo=0x99644422
mcsbw402gpo=0x99644422
dot11agofdmhrbw202gpo=0x6666
ofdmlrbw202gpo=0x0022
mcsbw205glpo=0x88766663
mcsbw405glpo=0x88666663
mcsbw805glpo=0xbb666665
mcsbw205gmpo=0xd8666663
mcsbw405gmpo=0x88666663
mcsbw805gmpo=0xcc666665
mcsbw205ghpo=0xdc666663
mcsbw405ghpo=0xaa666663
mcsbw805ghpo=0xdd666665
mcslr5glpo=0x0000
mcslr5gmpo=0x0000
mcslr5ghpo=0x0000
sb20in40hrpo=0x0
sb20in80and160hr5glpo=0x0
sb40and80hr5glpo=0x0
sb20in80and160hr5gmpo=0x0
sb40and80hr5gmpo=0x0
sb20in80and160hr5ghpo=0x0
sb40and80hr5ghpo=0x0
sb20in40lrpo=0x0
sb20in80and160lr5glpo=0x0
sb40and80lr5glpo=0x0
sb20in80and160lr5gmpo=0x0
sb40and80lr5gmpo=0x0
sb20in80and160lr5ghpo=0x0
sb40and80lr5ghpo=0x0
dot11agduphrpo=0x0
dot11agduplrpo=0x0
phycal_tempdelta=255
temps_period=15
temps_hysteresis=15
rssicorrnorm_c0=4,4
rssicorrnorm_c1=4,4
rssicorrnorm5g_c0=1,2,3,1,2,3,6,6,8,6,6,8
rssicorrnorm5g_c1=1,2,3,2,2,2,7,7,8,7,7,8
WIFI

    # Reload the brcmfmac kernel module
    modprobe -r brcmfmac
    modprobe brcmfmac
  fi

  echo "${MODEL} hardware configuration is applied. ${MESSAGE}"
}

function disable_gpd_pocket_config() {
  # Remove the GPD Pocket hardware configuration
  for CONFIG in ${MONITOR_CONF} ${TOUCH_CONF} ${WIFI_CONF}; do
    if [ -f "${CONFIG}" ]; then
      rm -f "${CONFIG}"
    fi
  done

  # Remove the framebuffer rotation
  sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="fbcon=rotate:1/GRUB_CMDLINE_LINUX_DEFAULT="/' /etc/default/grub
  update-grub

  echo "${MODEL} hardware configuration is removed. ${MESSAGE}"
}

function usage() {
    echo
    echo "Usage"
    echo "  ${0} enable || disable"
    echo ""
    echo "You must supply one of the following modes of operation"
    echo "  enable  : apply the ${MODEL} hardware configuration"
    echo "  disable : remove the ${MODEL} hardware configuration"
    echo "  help    : This help."
    echo
    exit 1
}

# Make sure we are not running on Wayland
if [ "${XDG_SESSION_TYPE}" == "wayland" ]; then
  echo "ERROR! This script is only designed to configure Xorg (X11). Please choose an alternative desktop session that uses Xorg (X11)."
  exit 1
fi

# Make sure we are root.
if [ $(id -u) -ne 0 ]; then
  echo "ERROR! You must be root to run $(basename $0)"
  exit 1
fi

# Define variables for the xorg configs
XORG_CONF_PATH="/usr/share/X11/xorg.conf.d"
WIFI_CONF="/lib/firmware/brcm/brcmfmac4356-pcie.txt"

# Get some system information
PRIMARY_DISPLAY=$(xrandr -q | grep primary | cut -d' ' -f1 | sed 's/ //g')
WIFI_CHECK=$(lspci | grep BCM4356)
if [ $? -eq 0 ]; then
  BRCM4356=1
else
  BRCM4356=0
fi

# Which GPD Pocket model is this?
if [ "${PRIMARY_DISPLAY}" == "DSI-1" ] && [ ${BRCM4356} -eq 1 ]; then
  MODEL="GPD Pocket"
  MESSAGE="Please reboot to complete the setup."
  MONITOR_CONF="${XORG_CONF_PATH}/40-gpd-pocket-monitor.conf"
  TOUCH_CONF="${XORG_CONF_PATH}/99-gpd-pocket-touchscreen.conf"
else
  MODEL="GPD Pocket2"
  MESSAGE="Please log out of this desktop session to complete the setup."
  MONITOR_CONF="${XORG_CONF_PATH}/40-gpd-pocket2-monitor.conf"
  TOUCH_CONF="${XORG_CONF_PATH}/99-gpd-pocket2-touchscreen.conf"
fi

# Display usage instructions if we've not been given an action. If an action
# has been provided store it in lowercase.
if [ -z "${1}" ]; then
  usage
else
  MODE=$(echo "${1}" | tr '[:upper:]' '[:lower:]')
fi

case "${MODE}" in
  -d|--disable|disable)
    disable_gpd_pocket_config;;
  -e|--enable|enable)
    enable_gpd_pocket_config;;
  -h|--h|-help|--help|-?|help)
    usage;;
  *)
    echo "ERROR! \"${MODE}\" is not a supported parameter."
    usage;;
esac

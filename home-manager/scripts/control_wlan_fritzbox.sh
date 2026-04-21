#!/bin/sh

# src: https://github.com/jhubig/FritzBoxShell

fritzbox_user='fritz9150'

fritzbox_ip='fritz.box'
if ! $(ping -c 1 "$fritzbox_ip" &> /dev/null); then
  echo "Fritzbox ($fritzbox_ip) unreachable"
  exit 1
fi

fritzbox_pw_path='/run/user/1000/secrets/wlan_password'
fritzbox_pw=''
if [ -f "$fritzbox_pw_path" ]; then
  fritzbox_pw=`cat "$fritzbox_pw_path"`
else
  read -p "Enter wlan password: " fritzbox_pw
fi

number_2G=1
number_5G=2

get_wlan_state_x() {
  wlanNumber=$1
  action='GetInfo'
  location="/upnp/control/wlanconfig$wlanNumber"
  uri="urn:dslforum-org:service:WLANConfiguration:$wlanNumber"

  r=$(curl \
    -s \
    -k \
    -m 5 \
    --anyauth \
    -u "$fritzbox_user:$fritzbox_pw" \
    "http://$fritzbox_ip:49000$location" \
    -H 'Content-Type: text/xml; charset="utf-8"' \
    -H "SoapAction:$uri#$action" \
    -d "<?xml version='1.0' encoding='utf-8'?><s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'><s:Body><u:$action xmlns:u='$uri'></u:$action></s:Body></s:Envelope>" \
    | grep NewEnable \
    | awk -F">" '{print $2}' \
    | awk -F"<" '{print $1}')
  echo $r
}

turn_on_wlan_x() {
  wlanNumber=$1
  if [ $(get_wlan_state_x $wlanNumber) == "0" ]; then
    set_wlan_x 1 $wlanNumber
  fi
}

turn_off_wlan_x() {
  wlanNumber=$1
  if [ $(get_wlan_state_x $wlanNumber) == "1" ]; then
    set_wlan_x 0 $wlanNumber
  fi
}

set_wlan_x() {
  onOff=$1
  wlanNumber=$2
  action='SetEnable'
  location="/upnp/control/wlanconfig$wlanNumber"
  uri="urn:dslforum-org:service:WLANConfiguration:$wlanNumber"
  curl \
    -k \
    -m 5 \
    --anyauth \
    -u "$fritzbox_user:$fritzbox_pw" \
    "http://$fritzbox_ip:49000$location" \
    -H 'Content-Type: text/xml; charset="utf-8"' \
    -H "SoapAction:$uri#$action" \
    -d "<?xml version='1.0' encoding='utf-8'?><s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'><s:Body><u:$action xmlns:u='$uri'><NewEnable>$onOff</NewEnable></u:$action></s:Body></s:Envelope>" \
    -s > /dev/null
}

toggle_wlan_x() {
  wlanNumber=$1
  onOff=0
  if [ $(get_wlan_state_x $wlanNumber) = "0" ]; then
    onOff=1
  fi
  set_wlan_x $onOff $wlanNumber
}

toggle_wlan_2G() {
  toggle_wlan_x $number_2G
}

toggle_wlan_5G() {
  toggle_wlan_x $number_5G
}

get_wlan_status() {
  if [ $(get_wlan_state_x $number_2G) = "0" ] && [ $(get_wlan_state_x $number_5G) = "0" ]; then
    echo $1
  else
    echo $2
  fi
}

if [[ $# -eq 0 ]]; then
  get_wlan_status "0" "1"
  exit 0
fi

case $1 in
  -s|--state)
    get_wlan_status "0" "1"
    exit 0
    ;;
  --symbol)
    get_wlan_status "󰖪 " "󰤥 "
    exit 0
    ;;
  -t|--toggle)
    toggle_wlan_2G
    toggle_wlan_5G
    exit 0
    ;;
  -1|--on)
    turn_on_wlan_x $number_2G
    turn_on_wlan_x $number_5G
    exit 0
    ;;
  -0|--off)
    turn_off_wlan_x $number_2G
    turn_off_wlan_x $number_5G
    exit 0
    ;;
  *)
    echo "Unknown option."
    exit 1
    ;;
esac

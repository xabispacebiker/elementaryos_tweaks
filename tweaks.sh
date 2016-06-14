#!/bin/bash
# Include utils:
spinner()
{
    test "$1" = "" && $1 = "Loading "
    local pid=$!
    local delay=0.75
    local spinstr='...'
    echo $1
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf "%s  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b"
    done
    printf "    \b\b\b\b"
}
update()
{
  apt-get update &>/dev/null &>/dev/null
  spinner("Updating the system")
  apt-get upgrade -y &>/dev/null
  spinner("Upgrading the system")
  apt-get autoremove -y &>/dev/null
  spinner("Finalizing upgrade operations")
}
disable_apport()
{
  echo "Removing crash items";
  rm /var/crash/* &>/dev/null
  echo "Disabling apport notifications"
  sed -i '/^enabled=/s/=.*/=0/' /etc/default/apport
  service apport stop &>/dev/null
  service apport start force_start=1 &>/dev/null
}
# 0. Check for root permision:
if [ "$(id -u)" != "0" ]; then
	echo "You are not root, execute the script with sudo";
	echo "sudo tweaks.sh";
	exit 1
fi

# 1. Update the system:
update()

# 2. Disable apport notifications. We don't want the user to be annoyed
disable_apport()

# 2. Install the tweaks
#!/bin/bash

installVer=$1 	#NodeJS major version to be installed
minVer=$1	#min NodeJS major version to be accepted
NODE_MAJOR=$( [[ $installVer == *.* ]] && echo $installVer | cut -d'.' -f1 || echo $installVer )

if [ "$LANG_DEP" = "fr" ]; then
	step 10 "Prérequis"
else
	step 10 "Prerequisites"
fi

#ipv4 first for dns (like before nodejs 18)
export NODE_OPTIONS="--dns-result-order=ipv4first"

#prioritize nodesource nodejs : just in case
sudo bash -c "cat >> /etc/apt/preferences.d/nodesource" << EOL
Package: nodejs
Pin: origin deb.nodesource.com
Pin-Priority: 600
EOL

if [ "$LANG_DEP" = "fr" ]; then
	step 15 "Installation des packages nécessaires"
else
	step 15 "Mandatory packages installation"
fi
# apt-get update should have been done in the calling file
try sudo DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::ForceIPv4=true install -y lsb-release build-essential apt-utils git gnupg

if [ "$LANG_DEP" = "fr" ]; then
	step 20 "Vérification du système"
else
	step 20 "System Check"
fi
arch=`arch`;

#jessie as libstdc++ > 4.9 needed for nodejs 12+
lsb_release -c | grep jessie
if [ $? -eq 0 ]; then
  today=$(date +%Y%m%d)
  if [[ "$today" > "20200630" ]]; then
    if [ "$LANG_DEP" = "fr" ]; then
      echo "$HR"
      echo -n "== KO == Erreur d'Installation"
      echo
      echo "$HR"
      echo "== ATTENTION Debian 8 Jessie n'est officiellement plus supportée depuis le 30 juin 2020, merci de mettre à jour votre distribution !!!"
    else
      echo "$HR"
      echo -n "== KO == Installation Error"
      echo
      echo "$HR"
      echo "== WARNING Debian 8 Jessie is not supported anymore since the 30rd of june 2020, thank you to update your distribution !!!"
    fi
    exit 1
  fi
fi

#stretch doesn't support nodejs 18+
lsb_release -c | grep stretch
if [ $? -eq 0 ]; then
  today=$(date +%Y%m%d)
  if [[ "$today" > "20220630" ]]; then
    if [ "$LANG_DEP" = "fr" ]; then
      echo "$HR"
      echo -n "== KO == Erreur d'Installation"
      echo
      echo "$HR"
      echo "== ATTENTION Debian 9 Stretch n'est officiellement plus supportée depuis le 30 juin 2022, merci de mettre à jour votre distribution !!!"
    else
      echo "$HR"
      echo -n "== KO == Installation Error"
      echo
      echo "$HR"
      echo "== WARNING Debian 9 Stretch is not supported anymore since the 30rd of june 2022, thank you to update your distribution !!!"
    fi
    exit 1
  fi
fi

#x86 32 bits not supported by nodesource anymore
bits=$(getconf LONG_BIT)
if { [ "$arch" = "i386" ] || [ "$arch" = "i686" ]; } && [ "$bits" -eq "32" ]; then
  if [ "$LANG_DEP" = "fr" ]; then
    echo "$HR"
    echo -n "== KO == Erreur d'Installation"
    echo
    echo "$HR"
    echo "== ATTENTION Votre système est x86 en 32bits et NodeJS 12 n'y est pas supporté, merci de passer en 64bits !!!"
  else
    echo "$HR"
    echo -n "== KO == Installation Error"
    echo
    echo "$HR"
    echo "== WARNING Your system is x86 in 32bits and NodeJS 12 doesn not support it anymore, thank you to reinstall in 64bits !!!"
  fi
  exit 1 
fi

if [ "$LANG_DEP" = "fr" ]; then
	step 25 "Vérification de la version de NodeJS installée"
else
	step 25 "Installed NodeJS version check"
fi
silent type node
if [ $? -eq 0 ]; then actual=`node -v`; else actual='Aucune'; fi
testVer=$(php -r "echo version_compare('${actual}','v${minVer}','>=');")
if [ "$LANG_DEP" = "fr" ]; then
	echo -n "[Check Version NodeJS actuelle : ${actual} : "
else
	echo -n "[Check Current NodeJS Version : ${actual} : "
fi
if [[ $testVer == "1" ]]; then
  echo_success
  new=$actual
else
  if [ "$LANG_DEP" = "fr" ]; then
  	echo "Correction..."
  	step 30 "Installation de NodeJS $NODE_MAJOR"
  else
  	echo "Fixing..."
  	step 30 "Installing NodeJS $NODE_MAJOR"
  fi
  
  #if npm exists
  silent type npm
  if [ $? -eq 0 ]; then
    npmPrefix=`npm prefix -g`
  else
    npmPrefix="/usr"
  fi
  
  silent sudo DEBIAN_FRONTEND=noninteractive apt-get -y --purge autoremove npm
  silent sudo DEBIAN_FRONTEND=noninteractive apt-get -y --purge autoremove nodejs
  
  
  if [[ $arch == "armv6l" ]]; then
    #version to install for armv6 (to check on https://unofficial-builds.nodejs.org/download/release/)
    if [[ $NODE_MAJOR == "12" ]]; then
      armVer="12.22.12"
    elif [[ $NODE_MAJOR == "14" ]]; then
      armVer="14.21.3"
    elif [[ $NODE_MAJOR == "16" ]]; then
      armVer="16.20.2"
    elif [[ $NODE_MAJOR == "18" ]]; then
      armVer="18.19.0"
    elif [[ $NODE_MAJOR == "20" ]]; then
      armVer="20.11.0"
    fi
    if [ "$LANG_DEP" = "fr" ]; then
    	echo "Jeedom Mini ou Raspberry 1, 2 ou zéro détecté, non supporté mais on essaye l'utilisation du paquet non-officiel v${armVer} pour armv6l"
    else
    	echo "Jeedom Mini or Raspberry 1, 2 or zero detected, unsupported but we try to install unofficial packet v${armVer} for armv6l"
    fi
    try wget -4 https://unofficial-builds.nodejs.org/download/release/v${armVer}/node-v${armVer}-linux-armv6l.tar.gz
    try tar -xvf node-v${armVer}-linux-armv6l.tar.gz
    cd node-v${armVer}-linux-armv6l
    try sudo cp -f -R * /usr/local/
    cd ..
    silent rm -fR node-v${armVer}-linux-armv6l*
    silent ln -s /usr/local/bin/node /usr/bin/node
    silent ln -s /usr/local/bin/node /usr/bin/nodejs
    #upgrade to recent npm
    forceUpdateNPM=1
  else
    if [ "$LANG_DEP" = "fr" ]; then
    	echo "Utilisation du dépot officiel"
    else
    	echo "Using official repository"
    fi
    
    #old method
    #curl -fsSL https://deb.nodesource.com/setup_${installVer}.x | try sudo -E bash -
    #try sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs
    
    #new method
    sudo mkdir -p /etc/apt/keyrings
    silent sudo rm /etc/apt/keyrings/nodesource.gpg
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    silent sudo rm /etc/apt/sources.list.d/nodesource.list
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | silent sudo tee /etc/apt/sources.list.d/nodesource.list
    try sudo apt-get -o Acquire::ForceIPv4=true update
    try sudo DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::ForceIPv4=true install -y nodejs
  fi
  
  silent npm config set prefix ${npmPrefix}

  new=`node -v`;
  if [ "$LANG_DEP" = "fr" ]; then
  	echo -n "[Check Version NodeJS après install : ${new} : "
  else
  	echo -n "[Check NodeJS Version after install : ${new} : "
  fi
  testVerAfter=$(php -r "echo version_compare('${new}','v${minVer}','>=');")
  if [[ $testVerAfter != "1" ]]; then
    echo_failure -n
    if [ "$LANG_DEP" = "fr" ]; then
    	echo " -> relancez les dépendances"
    else
    	echo " -> restart the dependancies"
    fi
  else
    echo_success
  fi
fi

silent type npm
if [ $? -ne 0 ]; then
  if [ "$LANG_DEP" = "fr" ]; then
  	step 35 "Installation de npm car non présent"
  else
  	step 35 "Installing npm because not present"
  fi
  try sudo DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::ForceIPv4=true install -y npm  
  forceUpdateNPM=1
fi

npmver=`npm -v`;
echo -n "[Check Version NPM : ${npmver} : "
echo $npmver | grep "8.11.0" &>/dev/null
if [ $? -eq 0 ]; then
	echo_failure
	forceUpdateNPM=1
else
	if [[ $forceUpdateNPM == "1" ]]; then
		if [ "$LANG_DEP" = "fr" ]; then
			echo "[ MàJ demandée ]"
		else
			echo "[ Update requested ]"
		fi
	else
 		echo_success
	fi
fi

if [[ $forceUpdateNPM == "1" ]]; then
	if [ "$LANG_DEP" = "fr" ]; then
		step 37 "Mise à jour de npm"
	else
		step 37 "Updating npm"
	fi
	try sudo -E npm install -g npm
fi

silent type npm
if [ $? -eq 0 ]; then
  npmPrefix=`npm --silent prefix -g`
  npmPrefixSudo=`sudo npm --silent prefix -g`
  npmPrefixwwwData=`sudo -u www-data npm --silent  prefix -g`
  if [ "$LANG_DEP" = "fr" ]; then
  	echo -n "[Check Prefixe : $npmPrefix et sudo prefixe : $npmPrefixSudo et www-data prefixe : $npmPrefixwwwData : "
  else
  	echo -n "[Check Prefix : $npmPrefix and sudo prefix : $npmPrefixSudo and www-data prefix : $npmPrefixwwwData : "
  fi
  if [[ "$npmPrefixSudo" != "/usr" ]] && [[ "$npmPrefixSudo" != "/usr/local" ]]; then 
    echo_failure
    if [[ "$npmPrefixwwwData" == "/usr" ]] || [[ "$npmPrefixwwwData" == "/usr/local" ]]; then
      if [ "$LANG_DEP" = "fr" ]; then
      		step 40 "Réinitialisation prefixe ($npmPrefixwwwData) pour npm `sudo whoami`"
      else
        	step 40 "Prefix reset ($npmPrefixwwwData) for npm `sudo whoami`"
      fi
      sudo npm config set prefix $npmPrefixwwwData
    else
      if [[ "$npmPrefix" == "/usr" ]] || [[ "$npmPrefix" == "/usr/local" ]]; then
        if [ "$LANG_DEP" = "fr" ]; then
        	step 40 "Réinitialisation prefixe ($npmPrefix) pour npm `sudo whoami`"
	else
		step 40 "Prefix reset ($npmPrefix) for npm `sudo whoami`"
	fi
        sudo npm config set prefix $npmPrefix
      else
        [ -f /usr/bin/raspi-config ] && { rpi="1"; } || { rpi="0"; }
        if [[ "$rpi" == "1" ]]; then
	  if [ "$LANG_DEP" = "fr" ]; then
	  	step 40 "Réinitialisation prefixe (/usr) pour npm `sudo whoami`"
	  else
	  	step 40 "Prefix reset (/usr) for npm `sudo whoami`"
	  fi
          sudo npm config set prefix /usr
	else
	  if [ "$LANG_DEP" = "fr" ]; then
	  	step 40 "Réinitialisation prefixe (/usr/local) pour npm `sudo whoami`"
	  else
          	step 40 "Prefix reset (/usr/local) for npm `sudo whoami`"
	  fi
          sudo npm config set prefix /usr/local
	fi
      fi
    fi  
  else
    if [[ "$npmPrefixwwwData" == "/usr" ]] || [[ "$npmPrefixwwwData" == "/usr/local" ]]; then
      if [[ "$npmPrefixwwwData" == "$npmPrefixSudo" ]]; then
        echo_success
      else
        echo_failure
	if [ "$LANG_DEP" = "fr" ]; then
        	step 40 "Réinitialisation prefixe ($npmPrefixwwwData) pour npm `sudo whoami`"
	else
		step 40 "Prefix reset ($npmPrefixwwwData) for npm `sudo whoami`"
	fi
        sudo npm config set prefix $npmPrefixwwwData
      fi
    else
      echo_failure
      if [[ "$npmPrefix" == "/usr" ]] || [[ "$npmPrefix" == "/usr/local" ]]; then
        if [ "$LANG_DEP" = "fr" ]; then
        	step 40 "Réinitialisation prefixe ($npmPrefix) pour npm `sudo whoami`"
	else
		step 40 "Prefix reset ($npmPrefix) for npm `sudo whoami`"
	fi
        sudo npm config set prefix $npmPrefix
      else
        [ -f /usr/bin/raspi-config ] && { rpi="1"; } || { rpi="0"; }
        if [[ "$rpi" == "1" ]]; then
	  if [ "$LANG_DEP" = "fr" ]; then
	  	step 40 "Réinitialisation prefixe (/usr) pour npm `sudo whoami`"
	  else
	  	step 40 "Prefix reset (/usr) for npm `sudo whoami`"
	  fi
          sudo npm config set prefix /usr
	else
	  if [ "$LANG_DEP" = "fr" ]; then
          	step 40 "Réinitialisation prefixe (/usr/local) pour npm `sudo whoami`"
	  else
		step 40 "Prefix reset (/usr/local) for npm `sudo whoami`"
	  fi
          sudo npm config set prefix /usr/local
	fi
      fi
    fi
  fi
fi

if [ "$LANG_DEP" = "fr" ]; then
	step 50 "Nettoyage"
else
	step 50 "Cleaning"
fi
# on nettoie la priorité nodesource
silent sudo rm -f /etc/apt/preferences.d/nodesource

# ADDING ERROR HANDLERS
# fix npm cache integrity issue
add_fix_handler "EINTEGRITY" "" "sudo npm cache clean --force"

# fix npm cache permissions
add_fix_handler "npm ERR! fatal: could not create leading directories of '/root/.npm/_cacache/tmp/" "*code 128" "sudo chown -R root:root /root/.npm"

# check for ENOTEMPTY error in both /usr and /usr/local
add_fix_handler "npm ERR! dest /usr/local/lib/node_modules/.homebridge-config-ui-x-" "*ENOTEMPTY" "sudo rm -fR /usr/local/lib/node_modules/.homebridge-config-ui-x-*"
add_fix_handler "npm ERR! dest /usr/lib/node_modules/.homebridge-config-ui-x-" "*ENOTEMPTY" "sudo rm -fR /usr/lib/node_modules/.homebridge-config-ui-x-*"

add_fix_handler "npm ERR! dest /usr/local/lib/node_modules/.homebridge-alexa-" "*ENOTEMPTY" "sudo rm -fR /usr/local/lib/node_modules/.homebridge-alexa-*"
add_fix_handler "npm ERR! dest /usr/lib/node_modules/.homebridge-alexa-" "*ENOTEMPTY" "sudo rm -fR /usr/lib/node_modules/.homebridge-alexa-*"

add_fix_handler "npm ERR! dest /usr/local/lib/node_modules/.homebridge-gsh-" "*ENOTEMPTY" "sudo rm -fR /usr/local/lib/node_modules/.homebridge-gsh-*"
add_fix_handler "npm ERR! dest /usr/lib/node_modules/.homebridge-gsh-" "*ENOTEMPTY" "sudo rm -fR /usr/lib/node_modules/.homebridge-gsh-*"

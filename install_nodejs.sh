#!/bin/bash

numSubStepMax=9 #the maximum number of different step this script will run (could be less with conditionnals)

#init arguments
forceUpdateNPM=0 #force to update NPM to the latest version

while [[ "$#" -gt 0 ]]; do
	case $1 in
 		--forceNodeVersion) forceNodeVersion="$2"; shift ;;
		--firstSubStep) firstSubStep=$2; shift ;;
		--lastSubStep) lastSubStep=$2; shift ;;
		--forceUpdateNPM) forceUpdateNPM=1 ;;
		*) echo "Unknown Option: $1"; tryOrStop false ;;
	esac
	shift
done

if [ "$LANG_DEP" = "fr" ]; then
	subStep "Prérequis"
else
	subStep "Prerequisites"
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
	subStep "Installation des packages nécessaires"
else
	subStep "Mandatory packages installation"
fi
# apt-get update should have been done in the calling file
try sudo DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::ForceIPv4=true install -y lsb-release build-essential apt-utils git gnupg jq

if [ "$LANG_DEP" = "fr" ]; then
	subStep "Vérification du système"
else
	subStep "System Check"
fi
arch=`arch`;

#jessie as libstdc++ > 4.9 needed for nodejs 12+
lsb_release -c | grep -q jessie
if [ $? -eq 0 ]; then
	today=$(date +%Y%m%d)
	if [[ "$today" > "20200630" ]]; then
 		echo 1 > $TMPFOLDER/hasError.$$
		if [ "$LANG_DEP" = "fr" ]; then
  			echo -e "$HR" >> $TMPFOLDER/errorLog.$$ 
			echo -e "== ATTENTION Debian 8 Jessie n'est officiellement plus supportée depuis le 30 juin 2020, merci de mettre à jour votre distribution !!!" >> $TMPFOLDER/errorLog.$$ 
		else
  			echo -e "$HR" >> $TMPFOLDER/errorLog.$$ 
			echo -e "== WARNING Debian 8 Jessie is not supported anymore since the 30rd of june 2020, thank you to update your distribution !!!" >> $TMPFOLDER/errorLog.$$ 
		fi
  		post
		exit 1
	fi
fi

#stretch doesn't support nodejs 18+
lsb_release -c | grep -q stretch
if [ $? -eq 0 ]; then
	today=$(date +%Y%m%d)
	if [[ "$today" > "20220630" ]]; then
 		echo 1 > $TMPFOLDER/hasError.$$
		if [ "$LANG_DEP" = "fr" ]; then
  			echo -e "$HR" >> $TMPFOLDER/errorLog.$$ 
			echo -e "== ATTENTION Debian 9 Stretch n'est officiellement plus supportée depuis le 30 juin 2022, merci de mettre à jour votre distribution !!!" >> $TMPFOLDER/errorLog.$$ 
		else
  			echo -e "$HR" >> $TMPFOLDER/errorLog.$$ 
			echo -e "== WARNING Debian 9 Stretch is not supported anymore since the 30rd of june 2022, thank you to update your distribution !!!" >> $TMPFOLDER/errorLog.$$ 
		fi
  		post
		exit 1
	fi
fi

#end of support buster except smart
lsb_release -c | grep -q buster
if [ $? -eq 0 ]; then
	if [ ! -f /media/boot/multiboot/meson64_odroidc2.dtb.linux ]; then
		today=$(date +%Y%m%d)
		if [[ "$today" > "20240630" ]]; then
  			echo 1 > $TMPFOLDER/hasError.$$
			if [ "$LANG_DEP" = "fr" ]; then
   				echo -e ":fg-danger:$HR:/fg:" >> $TMPFOLDER/errorLog.$$ 
				echo -e ":fg-danger:== ATTENTION Debian 10 Buster n'est officiellement plus supportée depuis le 30 juin 2024, merci de mettre à jour votre distribution !!!:/fg:" >> $TMPFOLDER/errorLog.$$ 
	   			echo -e ":fg-danger:== Les dépendances sont bloquées afin d'éviter tout problème, soit $PLUGIN fonctionne et donc on y touche plus tant qu'il tourne, soit il ne fonctionne plus et donc il faut mettre à jour votre distribution.:/fg:" >> $TMPFOLDER/errorLog.$$ 
       				echo -e ":fg-danger:$HR:/fg:" >> $TMPFOLDER/errorLog.$$ 
			else
   				echo -e ":fg-danger:$HR:/fg:" >> $TMPFOLDER/errorLog.$$ 
				echo -e ":fg-danger:== WARNING Debian 10 Buster is not supported anymore since June 30, 2024. Please update your distribution!!!:/fg:" >> $TMPFOLDER/errorLog.$$ 
	   			echo -e ":fg-danger:== Dependencies are blocked to avoid any issues. Either $PLUGIN works and so we don't touch the dependencies as long as it works, or it doesn't work anymore and you have to update your distribution.:/fg:" >> $TMPFOLDER/errorLog.$$ 
       				echo -e ":fg-danger:$HR:/fg:" >> $TMPFOLDER/errorLog.$$ 
			fi
   			post
	  		exit 1
		fi
	else
		if [ "$LANG_DEP" = "fr" ]; then
			echo ":fg-warning:$HR:/fg:"
			echo ":fg-warning:== WARNING == A VERIFIER AU PLUS VITE:/fg:"
			echo
			echo ":fg-warning:$HR:/fg:"
			echo ":fg-warning:== ATTENTION Debian 10 Buster n'est officiellement plus supportée depuis le 30 juin 2024, cependant l'image Debian 11 de la Smart est en cours de finalisation par Jeedom.:/fg:"
			echo ":fg-warning:== Les dépendances vont quand même se lancer (mais aucun support ne sera fait si celles-ci ne fonctionnent pas !), surveillez les nouvelles de Jeedom afin de mettre à jour en Debian 11 au plus vite quand ils auront sorti leur nouvelle image.:/fg:"
		else
			echo ":fg-warning:$HR:/fg:"
			echo ":fg-warning:== WARNING == TO CHECK SOON:/fg:"
			echo
			echo ":fg-warning:$HR:/fg:"
			echo ":fg-warning:== WARNING Debian 10 Buster is not supported anymore since June 30, 2024. Nevertheless, the Debian 11 image for the Smart box is still under development by Jeedom.:/fg:"
			echo ":fg-warning:== Dependancies will continue (but no support will be done if it fails). Watch for Jeedom news to update to Debian 11 as soon as they release the new image.:/fg:"
		fi
 	fi
fi

#x86 32 bits not supported by nodesource anymore
bits=$(getconf LONG_BIT)
if { [ "$arch" = "i386" ] || [ "$arch" = "i686" ]; } && [ "$bits" -eq "32" ]; then
	echo 1 > $TMPFOLDER/hasError.$$
	if [ "$LANG_DEP" = "fr" ]; then
 		echo -e "$HR" >> $TMPFOLDER/errorLog.$$ 
		echo -e "== ATTENTION Votre système est x86 en 32bits et NodeJS n'y est pas supporté, merci de passer en 64bits !!!" >> $TMPFOLDER/errorLog.$$ 
	else
 		echo -e "$HR" >> $TMPFOLDER/errorLog.$$ 
		echo -e "== WARNING Your system is x86 in 32bits and NodeJS does not support it anymore, thank you to reinstall in 64bits !!!" >> $TMPFOLDER/errorLog.$$ 
	fi
 	post
	exit 1 
fi

if [ "$LANG_DEP" = "fr" ]; then
	subStep "Vérification de la version de NodeJS installée"
else
	subStep "Installed NodeJS version check"
fi

if [ -z "$forceNodeVersion" ]; then
	requiredNodeVersion=$(jq -r ".engines.node" ${BASEDIR}/package.json)
	requiredNodeOperator=$(echo "$requiredNodeVersion" | grep -o "^[<>=]*")
	requiredNodeVersion=$(echo "$requiredNodeVersion" | grep -o "[0-9.]*$")
else
	requiredNodeVersion=$forceNodeVersion
 	requiredNodeOperator="=="
fi
NODE_MAJOR=$( [[ $requiredNodeVersion == *.* ]] && echo $requiredNodeVersion | cut -d'.' -f1 || echo $requiredNodeVersion )

if [ -z "$NODE_MAJOR" ]; then
	echo 1 > $TMPFOLDER/hasError.$$
	echo "Erreur: NODE_MAJOR est vide" >> $TMPFOLDER/errorLog.$$ 
	echo "Contenu de ${BASEDIR}/package.json:" >> $TMPFOLDER/errorLog.$$ 
	cat "${BASEDIR}/package.json" >> $TMPFOLDER/errorLog.$$ 
	echo "Version de node trouvée requiredNodeVersion: $requiredNodeVersion" >> $TMPFOLDER/errorLog.$$ 
	if ! command -v jq &> /dev/null; then
		echo "jq n'est pas installé." >> $TMPFOLDER/errorLog.$$ 
	fi
 	post
    	exit 1
fi

silent type node
if [ $? -eq 0 ]; then actual=`node -v`; else actual='Aucune'; fi
testVer=$(php -r "echo version_compare('${actual}','v${requiredNodeVersion}','${requiredNodeOperator}');")
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
		subStep "Installation de NodeJS $NODE_MAJOR"
	else
		echo "Fixing..."
		subStep "Installing NodeJS $NODE_MAJOR"
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
			armVer="18.20.2"
		elif [[ $NODE_MAJOR == "20" ]]; then
			armVer="20.12.2"
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
	testVerAfter=$(php -r "echo version_compare('${new}','v${requiredNodeVersion}','${requiredNodeOperator}');")
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
		subStep "Installation de npm car non présent"
	else
		subStep "Installing npm because not present"
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
 		requiredNPMVersion=$(jq -r ".engines.npm" ${BASEDIR}/package.json)
		requiredNPMOperator=$(echo "$requiredNPMVersion" | grep -o "^[<>=]*")
		requiredNPMVersion=$(echo "$requiredNPMVersion" | grep -o "[0-9.]*$")

		if [[ $requiredNPMVersion =~ ^[0-9]+(\.[0-9]+)+$ ]]; then
			testNPMVer=$(php -r "echo version_compare('${npmver}','${requiredNPMVersion}','${requiredNPMOperator}');")
			if [[ $testNPMVer == "1" ]]; then
	   			echo_success
	      		else
				if [ "$LANG_DEP" = "fr" ]; then
					echo "[ MàJ demandée ]"
				else
					echo "[ Update requested ]"
				fi
	   			forceUpdateNPM=1
	 		fi
    		else
			echo_success
      		fi
	fi
fi

if [[ $forceUpdateNPM == "1" ]]; then
	if [ "$LANG_DEP" = "fr" ]; then
		subStep "Mise à jour de npm"
	else
		subStep "Updating npm"
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
		      		subStep "Réinitialisation prefixe ($npmPrefixwwwData) pour npm `sudo whoami`"
			else
				subStep "Prefix reset ($npmPrefixwwwData) for npm `sudo whoami`"
			fi
	      		sudo npm config set prefix $npmPrefixwwwData
		else
			if [[ "$npmPrefix" == "/usr" ]] || [[ "$npmPrefix" == "/usr/local" ]]; then
				if [ "$LANG_DEP" = "fr" ]; then
					subStep "Réinitialisation prefixe ($npmPrefix) pour npm `sudo whoami`"
				else
					subStep "Prefix reset ($npmPrefix) for npm `sudo whoami`"
				fi
				sudo npm config set prefix $npmPrefix
			else
				[ -f /usr/bin/raspi-config ] && { rpi="1"; } || { rpi="0"; }
				if [[ "$rpi" == "1" ]]; then
  					if [ "$LANG_DEP" = "fr" ]; then
						subStep "Réinitialisation prefixe (/usr) pour npm `sudo whoami`"
					else
	  					subStep "Prefix reset (/usr) for npm `sudo whoami`"
					fi
					sudo npm config set prefix /usr
				else
					if [ "$LANG_DEP" = "fr" ]; then
	 				 	subStep "Réinitialisation prefixe (/usr/local) pour npm `sudo whoami`"
					else
          					subStep "Prefix reset (/usr/local) for npm `sudo whoami`"
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
        				subStep "Réinitialisation prefixe ($npmPrefixwwwData) pour npm `sudo whoami`"
				else
					subStep "Prefix reset ($npmPrefixwwwData) for npm `sudo whoami`"
				fi
				sudo npm config set prefix $npmPrefixwwwData
			fi
		else
			echo_failure
			if [[ "$npmPrefix" == "/usr" ]] || [[ "$npmPrefix" == "/usr/local" ]]; then
				if [ "$LANG_DEP" = "fr" ]; then
        				subStep "Réinitialisation prefixe ($npmPrefix) pour npm `sudo whoami`"
				else
					subStep "Prefix reset ($npmPrefix) for npm `sudo whoami`"
				fi
				sudo npm config set prefix $npmPrefix
			else
				[ -f /usr/bin/raspi-config ] && { rpi="1"; } || { rpi="0"; }
				if [[ "$rpi" == "1" ]]; then
					if [ "$LANG_DEP" = "fr" ]; then
	  					subStep "Réinitialisation prefixe (/usr) pour npm `sudo whoami`"
				  	else
						subStep "Prefix reset (/usr) for npm `sudo whoami`"
					fi
					sudo npm config set prefix /usr
				else
					if [ "$LANG_DEP" = "fr" ]; then
						subStep "Réinitialisation prefixe (/usr/local) pour npm `sudo whoami`"
					else
						subStep "Prefix reset (/usr/local) for npm `sudo whoami`"
					fi
					sudo npm config set prefix /usr/local
				fi
			fi
		fi
	fi
fi

if [ "$LANG_DEP" = "fr" ]; then
	subStep "Nettoyage"
else
	subStep "Cleaning"
fi
# on nettoie la priorité nodesource
silent sudo rm -f /etc/apt/preferences.d/nodesource

# ADDING ERROR HANDLERS
# fix npm cache integrity issue
add_fix_handler "EINTEGRITY" "" "sudo npm cache clean --force"

# fix npm cache permissions
add_fix_handler "npm ERR! fatal: could not create leading directories of '/root/.npm/_cacache/tmp/" "*code 128" "sudo chown -R root:root /root/.npm"

# check for ENOTEMPTY error in both /usr and /usr/local
add_fix_handler "npm ERR! dest /usr/local/lib/node_modules/.homebridge-config-ui-x-" "*ENOTEMPTY local config-ui-x" "sudo rm -fR /usr/local/lib/node_modules/.homebridge-config-ui-x-*"
add_fix_handler "npm ERR! dest /usr/lib/node_modules/.homebridge-config-ui-x-" "*ENOTEMPTY config-ui-x" "sudo rm -fR /usr/lib/node_modules/.homebridge-config-ui-x-*"

add_fix_handler "npm error dest /usr/local/lib/node_modules/.homebridge-config-ui-x-" "*ENOTEMPTY local config-ui-x" "sudo rm -fR /usr/local/lib/node_modules/.homebridge-config-ui-x-*"

add_fix_handler "npm ERR! dest /usr/local/lib/node_modules/.homebridge-alexa-" "*ENOTEMPTY local alexa" "sudo rm -fR /usr/local/lib/node_modules/.homebridge-alexa-*"
add_fix_handler "npm ERR! dest /usr/lib/node_modules/.homebridge-alexa-" "*ENOTEMPTY alexa" "sudo rm -fR /usr/lib/node_modules/.homebridge-alexa-*"

add_fix_handler "npm ERR! dest /usr/local/lib/node_modules/.homebridge-gsh-" "*ENOTEMPTY local gsh" "sudo rm -fR /usr/local/lib/node_modules/.homebridge-gsh-*"
add_fix_handler "npm ERR! dest /usr/lib/node_modules/.homebridge-gsh-" "*ENOTEMPTY gsh" "sudo rm -fR /usr/lib/node_modules/.homebridge-gsh-*"

# fix when sometimes node source is not correct
#add_fix_handler "deb.nodesource.com/node_.x" "" "sudo sed -i 's|node_.x|node_${$NODE_MAJOR}.x|' /etc/apt/sources.list.d/nodesource.list"
#add_fix_handler "deb.nodesource.com/node_.x" "" "sudo sed -i 's|node_.x|node_18.x|' /etc/apt/sources.list.d/nodesource.list"

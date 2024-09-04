Require to be launched by a script containing :
1. the inclusion lib dependance.lib
2. the wget of install_nodejs.sh
3. some parameters :
   - --firstSubStep numFirstStep : mandatory : first percentage for the first subStep
   - --lastSubStep numLastStep : mandatory : last percentage for the last subStep
   - [--forceNodeVersion numVersion] : optional : force to install a precise NodeJS version
   - [--forceUpdateNPM] : optional : force to update NPM to the latest version
5. an apt-get update before launch
6. pre-required packages already installed (nodejs required packages will be installed by this script)
7. this script take care of percents from 10 to 50 if parameters are --firstSubStep 10 and --lastSubStep 50.
8. the script read package.json file next to it and install nodejs version in engines>node and npm version in engines>npm (needs >= no ^)

```
#!/bin/bash
######################### INCLUSION LIB ##########################
BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
wget https://raw.githubusercontent.com/NebzHB/dependance.lib/master/dependance.lib --no-cache -O $BASEDIR/dependance.lib &>/dev/null
PLUGIN=$(basename "$(realpath $BASEDIR/..)")
. ${BASEDIR}/dependance.lib
##################################################################
wget https://raw.githubusercontent.com/NebzHB/dependance.lib/master/install_nodejs.sh --no-cache -O $BASEDIR/install_nodejs.sh &>/dev/null

pre
step 0 "Vérifications diverses"


step 5 "Mise à jour APT et installation des packages nécessaires"
try sudo apt-get update
try sudo DEBIAN_FRONTEND=noninteractive apt-get install -y exemple_package_needed_after_step_50

#install nodejs, steps 10->50
. ${BASEDIR}/install_nodejs.sh --firstSubStep 10 --lastSubStep 50

step 60 "La suite"

step 70 "suite"

step 80 "suite encore"

step 90 "nettoyage final"
post
```

# Added error handlers :

 npm `EINTEGRITY`

 npm `npm ERR! fatal: could not create leading directories of '/root/.npm/_cacache/tmp/'`

 npm `ENOTEMPTY` for homebridge-gsh, homebridge-alexa and homebridge-camera-ffmpeg

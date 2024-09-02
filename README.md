# dependance.lib

NB : for nodejs install, see [install_nodejs script Doc](https://github.com/NebzHB/dependance.lib/blob/master/install_nodejs.md)

NB : for python install, see [pyenv script Doc](https://github.com/NebzHB/dependance.lib/blob/master/pyenv.md)

Bash HomeMade Dependance Library for Jeedom

# Usage example :
```
######################### INCLUSION LIB ##########################
BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
wget https://raw.githubusercontent.com/NebzHB/dependance.lib/master/dependance.lib -O $BASEDIR/dependance.lib &>/dev/null
PLUGIN=$(basename "$(realpath $BASEDIR/..)")
. ${BASEDIR}/dependance.lib
##################################################################

pre
step 10 "Installation des paquets"
try sudo apt-get install this that
try sudo rm -f /oldFolder
wget http://aScript.com/script.sh | try sudo -E bash -
silent sudo rm -f /anotherFolderNotSure

step 50 "Configuration du plugin"
try wget ...
echo "not silent"
post
```

# Result example :

**result if ok** :
```
======================================================================
== 01/01/2020 01:01:01 == Installation des dépendances de PLUGIN
======================================================================
[  0% ] : Vérification des droits...
[  9% ] : Vérification des droits : [  OK  ]
[ 10% ] : Prérequis...
[ 19% ] : Prérequis : [  OK  ]
[ 20% ] : Mise à jour APT et installation des packages nécessaires...
[ 29% ] : Mise à jour APT et installation des packages nécessaires : [  OK  ]
[ 30% ] : Vérification de la version de NodeJS installée...
Version actuelle : v12.14.1
Ok, version suffisante
[ 49% ] : Vérification de la version de NodeJS installée : [  OK  ]
[ 50% ] : Nettoyage anciens modules...
[ 59% ] : Nettoyage anciens modules : [  OK  ]
[ 60% ] : Installation des librairies, veuillez patienter svp...
[ 89% ] : Installation des librairies, veuillez patienter svp : [  OK  ]
[ 90% ] : Nettoyage...
[ 99% ] : Nettoyage : [  OK  ]
[100% ] : Terminé !
======================================================================
== OK == Installation Réussie
======================================================================
```

**result if not ok** :
```
======================================================================
== 01/01/2020 01:01:01 == Installation des dépendances de PLUGIN
======================================================================
[  0% ] : Vérification des droits...
[  9% ] : Vérification des droits : [  OK  ]
[ 10% ] : Prérequis...
[ 19% ] : Prérequis : [  OK  ]
[ 20% ] : Mise à jour APT et installation des packages nécessaires...
[ 29% ] : Mise à jour APT et installation des packages nécessaires : [ERROR]
[ 30% ] : Vérification de la version de NodeJS installée...
Version actuelle : v12.14.1
Ok, version suffisante
[ 49% ] : Vérification de la version de NodeJS installée : [  OK  ]
[ 50% ] : Nettoyage anciens modules...
[ 59% ] : Nettoyage anciens modules : [  OK  ]
[ 60% ] : Installation des librairies, veuillez patienter svp...
[ 89% ] : Installation des librairies, veuillez patienter svp : [  OK  ]
[ 90% ] : Nettoyage...
[ 99% ] : Nettoyage : [  OK  ]
[100% ] : Terminé !
======================================================================
== KO == Erreur d'Installation
======================================================================
== Erreur à l'étape : Mise à jour APT et installation des packages nécessaires
== Ligne 75
== La commande `sudo DEBIAN_FRONTEND=noninteractive apt-get install -y fdsfqfqfsqdf' pose problème 
== Le code de retour est 100
== Le message d'erreur :
Reading package lists...
Building dependency tree...
Reading state information...
E: Unable to locate package fdsfqfqfsqdf
======================================================================
```

# Functions

- pre : display the header + prepare some stuff (MANDATORY BEFORE ANY STEP)

- try : will try the commands of the line and catch errors (and display them at the end)

- tryOrStop : will try the commands of the line and catch errors (and stop the script by displaying the errors)

- silent : no matter if the commands fails, it'll be silent

> **IMPORTANT** : dont use try or tryOrStop or silent if the command uses >> | or > or < (output/input redirections), or only in the last part of a piped command

- step : percentage + name of the step that will follow. Every Step will close the previous one (if any) with a percentage-1 closure message.

- post : fix the errors found in error_handlers + display the Footer (MANDATORY AT THE END)

# Variables

## LANG_DEP=en 

> Use it before the `. ${BASEDIR}/dependance.lib` line if you want messages in english instead of french.

**example** :
```
######################### INCLUSION LIB ##########################
BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
wget https://raw.githubusercontent.com/NebzHB/dependance.lib/master/dependance.lib -O $BASEDIR/dependance.lib &>/dev/null
PLUGIN=$(basename "$(realpath $BASEDIR/..)")
LANG_DEP=en
. ${BASEDIR}/dependance.lib
##################################################################

pre
```

## TIMED=1

> Use it before the `. ${BASEDIR}/dependance.lib` line to time each step.

**example** :
```
######################### INCLUSION LIB ##########################
BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
wget https://raw.githubusercontent.com/NebzHB/dependance.lib/master/dependance.lib -O $BASEDIR/dependance.lib &>/dev/null
PLUGIN=$(basename "$(realpath $BASEDIR/..)")
TIMED=1
. ${BASEDIR}/dependance.lib
##################################################################

pre
```



# Other Features :

## Error Handlers

### Implement your own error handler : add your handler(s) anywhere after the *include header* and before the `post` cmd :

```
add_fix_handler "string to grep in errors" "message to show if the string is found" "command to fix the error"
```

or

```
myFixFunc() {
  echo "this is my fix"
}
add_fix_handler "string to grep in errors" "message to show if the string is found" myFixFunc
```

or

```
myTestFunct() {
  echo "this is my test"
  return 0; # 0 will trigger the fix, other return value don't trigger the fix
}
add_fix_handler myTestFunct "message to show if the string is found" "command to fix the error"
```

or

```
myTestFunct() {
  grep "my error" $1 #$1 contains the path to the error log, so you can search by yourself !
  return $?; # 0 will trigger the fix, other return value don't trigger the fix
}
add_fix_handler myTestFunct "message to show if the string is found" "command to fix the error"
```

or

```
add_fix_handler "string to grep in errors" "*short message to show in default message" "command to fix the error"
```

or

```
add_fix_handler "string to grep in errors" "" "command to fix the error" #empty message uses the default message with "string to grep in errors"
```

### Real life examples :

```
test_npm_ver() {
	npm -v | grep "8.11.0" &>/dev/null
	return $?
}
fix_npm_ver() {
	sudo npm install -g npm@8.12.2
}
add_fix_handler test_npm_ver "*NPM 8.11.0" fix_npm_ver
```

or

```
add_fix_handler "EINTEGRITY" "" "sudo npm cache clean --force"
```

## subStep

Adding subStep for sub script that would want to have their own steps, please define those variables in your subscript (or by passing it as argument if you want a generic subscript for multiple plugins)

- firstSubStep= lower range of pourcentage your subscript will begin with (default 10)

- lastSubStep= higher range of pourcentage your subscript will finish with (default 50)

- numSubStepMax= max number of call to subStep you'll make in your subscript (to compute the percentage increment of each of your step) (default 9 -> 5% for each steps)

Example calling the subscript install-something.sh here :

```
#!/bin/bash
######################### INCLUSION LIB ##########################
BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
wget https://raw.githubusercontent.com/NebzHB/dependance.lib/master/dependance.lib -O $BASEDIR/dependance.lib &>/dev/null
PLUGIN=$(basename "$(realpath $BASEDIR/..)")
. ${BASEDIR}/dependance.lib
##################################################################

pre
step 0 "Vérification des droits"
chmod +x ./install-something.sh

step 20 "Installation des paquets"
try sudo apt-get install this that
try sudo rm -f /oldFolder
wget http://aScript.com/script.sh | try sudo -E bash -
silent sudo rm -f /anotherFolderNotSure

# Launching subscript !
./install-something.sh 30 50

step 60 "Configuration du plugin"
try wget ...
echo "not silent"
post
```

in install-something.sh
```
#!/bin/bash

firstSubStep=$1
lastSubStep=$2
numSubStepMax=5

subStep "My first step"
npm -i ...
substep "My second step"
apt install nodejs
substep "My third step"
apt remove blabla
substep "My fourth step"
rm -f /var/lib/thing
substep "My fifth step"
rm -f /var/lib/anotherThing
```

will display :
```
======================================================================
== 01/01/2020 01:01:01 == Installation des dépendances de PLUGIN
======================================================================
[  0% ] : Vérification des droits...
[ 19% ] : Vérification des droits : [  OK  ]
[ 20% ] : Installation des paquets...
[ 29% ] : Installation des paquets : [  OK  ]
[ 30% ] : My first step...
[ 34% ] : My first step : [  OK  ]
[ 35% ] : My second step...
[ 39% ] : My second step : [  OK  ]
[ 40% ] : My third step...
[ 44% ] : My third step : [  OK  ]
[ 45% ] : My fourth step...
[ 49% ] : My fourth step : [  OK  ]
[ 50% ] : My fifth step...
[ 59% ] : My fifth step : [  OK  ]
[ 60% ] : Configuration du plugin...
[ 99% ] : Configuration du plugin : [  OK  ]
[100% ] : Terminé !
======================================================================
== OK == Installation Réussie
======================================================================
```


# This library has some auto-fixes already included for this common errors :

- apt `apt --fix-broken install`
 
- dkpg `sudo dpkg --configure -a`
 
- apt `changed its 'Suite' value from 'testing' to 'oldstable'`

- fix issue with mdjr.net certificate

- fix "The repository 'http://apt.armbian.com buster Release' no longer has a Release file." with commenting the source in source file (same fix than the official Atlas Plugin does)

- fix "The repository 'http://deb.debian.org/debian buster-backports Release' no longer has a Release file." with commenting the source in sources.list file.

- Now the library remove repo.jeedom.com repository (accepted by Alex from Jeedom) and disable temporary deb-multimedia repository (often problem source)

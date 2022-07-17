# dependance.lib

Bash HomeMade Dependance Library for Jeedom

**usage** :
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
**IMPORTANT** : dont use try or silent if the command have >> | or > or < (output/input redirections), or in the last part of a piped command

try : will try the commands of the line and catch errors (and display them at the end)

silent : no matter if the commands fails, it'll be silent


add LANG_DEP=en before the `. ${BASEDIR}/dependance.lib` line if you want messages in english instead of french.

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


add TIMED=1 before the `. ${BASEDIR}/dependance.lib` line to time each step.

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
[ 29% ] : Mise à jour APT et installation des packages nécessaires : [ERREUR]
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

# NEW

Now the library remove repo.jeedom.com repository (accepted by Alex from Jeedom) and disable temporary deb-multimedia repository (often problem source)



Implement your own error handler : add your handler anywhere after the *include header* and before the `post` cmd :

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
add_fix_handler "string to grep in errors" "*short message to show in default message" "command to fix the error"
```

or

```
add_fix_handler "string to grep in errors" "" "command to fix the error" #empty message uses the default message with "string to grep in errors"
```

Real life examples :

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

Auto fix alreday included for this common errors :

 apt `apt --fix-broken install`
 
 dkpg `sudo dpkg --configure -a`
 
 apt `changed its 'Suite' value from 'testing' to 'oldstable'`

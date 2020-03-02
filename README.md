# dependance.lib

Bash Home Made Dependance Library for Jeedom

**usage** :
```
BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
wget https://raw.githubusercontent.com/NebzHB/dependance.lib/master/dependance.lib -O $BASEDIR/dependance.lib &>/dev/null
PLUGIN=$(basename "$(realpath $BASEDIR/..)")
. ${BASEDIR}/dependance.lib

pre
step 10 "Installation des paquets"
try sudo apt-get install this that
try sudo rm -f /oldFolder
silent sudo rm -f /anotherFolderNotSure

step 50 "Configuration du plugin"
try wget ...
post
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
== Erreur à 20% à la ligne 75: la commande `sudo DEBIAN_FRONTEND=noninteractive apt-get install -y fdsfqfqfsqdf' pose problème le code de retour 100.
======================================================================
Reading package lists...
Building dependency tree...
Reading state information...
E: Unable to locate package fdsfqfqfsqdf
======================================================================
```

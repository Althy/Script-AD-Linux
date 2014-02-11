#!/bin/bash
# script de gestion des utilisateurs
#Author : Antunes Alan 11/02/2014
clear

###########################
## VARIABLES  
liste_user=""
liste_group=""
first="true"

# Appel au fichier de configuration
. ../etc/appli.conf # Adressage relatif... vous avez reconnu ?

# Appel aux fonctions necessaires au script
. ${Rep_COMMUN}/fonctions_communes
. ${Rep_COMMUN}/gestion_user
. ${Rep_COMMUN}/gestion_group
. ${Rep_COMMUN}/gestion_archives
###########################
## FONCTIONS internes 

# Traitement option u
trait_user() {
  if [ -z $1 ] ; then
     echo -e -u2 "Erreur: Aucun utilisateur existe - la procedure est arrete."
     exit 1
  fi
  argument=$1
  OLDIFS="$IFS"
  IFS=","
  set $argument
  while [ $# -ne 0 ]
  do
    user=$1
    if existe user $user
    then
      if [ $first == "true" ] ; then
        liste_user=$user
        first="false"
      else
        liste_user=$liste_user" "$user
      fi 
    else
      echo -e -u2 "L utilisateur $user n existe pas."
    fi
    shift
  done
  IFS="$OLDIFS"
}

# Traitement option g 
trait_group () {
  if [ -z $1 ] ; then
     echo -e -u2 "Erreur: Aucun utilisateur existe - la procedure est arrete."
     exit 1
  fi

  argument=$1
  liste_groupe=`echo $argument | tr ',' ' '`
  for group in $liste_groupe 
  do

    if existe group $group
    then

      GID=`awk -v var=$group -F: '{ if ( var == $1 ) echo -e $3 }' /etc/group`
      usergroup=`awk -v var="$GID" 'BEGIN {FS=":";ORS=" "} { if ($4!=var) next ; echo -e $1 } ' /etc/passwd`
      if [ $first == "true" ] ; then
        liste_user=$usergroup
        first="false"
      else
        liste_user=$liste_user" "$usergroup
      fi
 
    else
      echo -e -u2 "Le groupe $group n'existe pas"  
    fi

  done
}

######################
# FONCTIONS D AFICHAGE

affichage_titre() {
  # clear

  echo -e "##############################\n#"
  echo -e "#  GESTION  DES  UTILISATEURS\n#"
  echo "#  $1"
  echo -e "#\n##############################\n"
}

# Fonction d affichage du menu
affiche_menu () {
 PS3="Faites votre choix : "

 while true
 do

  # clear
  affichage_titre "     MENU  PRINCIPAL"

  select choix in "Creer un utilisateur" "Creer une liste d utilisateur" \
  "Afficher un utilisateur" "Modifier un utilisateur" \
  "Supprimer un utilisateur" "Creer un groupe utilisateur" \
  "Afficher un groupe utilisateur" "Modifier un groupe utilisateur" \
  "Supprimer un groupe utilisateur" \
  "Creer une archive d un utilisateur" "Lister une archive d un utilisateur"\
  "Restaurer une archive d un utilisateur" \
  "Supprimer une archive d un utilisateur" \
  "Supprimer toutes les archives d un utilisateur" \
  "Quitter"
  do
    case "$choix" in
      "Creer un utilisateur") 
      affichage_titre "Creation d un compte Utilisateur"
      cree_user
      break
      ;;
      "Creer une liste d utilisateur") 
      affichage_titre "Creation d une liste de comptes Utilisateurs"
      cree_liste_user
      break
      ;;
      "Afficher un utilisateur") 
      affichage_titre "Afficher un compte Utilisateur"
      affiche_user
      break
      ;;
      "Modifier un utilisateur") 
      affichage_titre "Modification d un compte Utilisateur"
      modif_user
      break
      ;;
      "Supprimer un utilisateur") 
      affichage_titre "Suppression d un compte Utilisateur"
      delete_user
      break
      ;;
      "Creer un groupe utilisateur") 
      affichage_titre "Creation d un groupe Utilisateur"
      cree_group
      break
      ;;
      "Afficher un groupe utilisateur") 
      affichage_titre "Afficher un groupe Utilisateur"
      affiche_group
      break
      ;;
      "Modifier un groupe utilisateur") 
      affichage_titre "Modification d un groupe Utilisateur"
      modif_group
      break
      ;;
      "Supprimer un groupe utilisateur") 
      affichage_titre "Suppression d un groupe Utilisateur"
      delete_group
      break
      ;;
      "Creer une archive d un utilisateur") 
      affichage_titre "Creation d une Archive Utilisateur"
      menu_creation_archive
      break
      ;;
      "Lister une archive d un utilisateur") 
      affichage_titre "Detail d une Archive Utilisateur"
      menu_lister_archive
      break
      ;;
      "Restaurer une archive d un utilisateur") 
      affichage_titre "Restaurer une Archive Utilisateur" 
      menu_extraction_archive
      break
      ;;
      "Supprimer une archive d un utilisateur") 
      affichage_titre "Supprimer une Archive Utilisateur"
      menu_supprimer_archive
      break
      ;;
      "Supprimer toutes les archives d un utilisateur") 
      affichage_titre "Supprimer Toutes les Archives d un Utilisateur"
      menu_suppression_full_archives
      break
      ;;
      "Quitter") echo -e "\nProcedure terminee."
                 echo -e "Aurevoir.\n"
                 exit 0  
    esac
  done    
  pause
 done
}

# Fonction USAGE  pour le traitement des erreurs
usage () {
  echo -e -u2 $1
  echo -e -u2 "Usage de $0 : "
  echo -e -u2 "Syntaxe : $0 "
  echo -e -u2 "Syntaxe : $0 -c -u  nom_utilisateur1[,nom_utilisateur2,nom_utilisateur3...]"
  echo -e -u2 "Syntaxe : $0 -c -g  nom_groupe1[,nom_groupe2,nom_groupe3...]"
  echo -e -u2 "Syntaxe : $0 -c -u  nom_utilisateur -a archive_a_restaurer"
  echo -e -u2 "Syntaxe : $0 -h nom_utilisateur"
  echo -e -u2 " "
  exit 1
}

#######################
##  Programme Principal

if [ $# -eq 0 ] ; then
  affiche_menu
  exit 0
fi

while getopts :cxh option
do
  case $option in
    c)  while getopts u:g: copt
        do
          case $copt in
          u) trait_user $OPTARG
             ;;
          g) trait_group $OPTARG
             ;;
          \?) usage "Erreur: $OPTARG est une option incorrecte"
              ;; 
          :) usage "Erreur: Absence d argument pour l option $OPTARG"
             ;;
          esac
        done

        creation_archive_liste $liste_user
        ;;

    x)  while getopts :u:g: xopt
        do
          case $xopt in
          u) trait_user $OPTARG
             ;;
          g) trait_group $OPTARG
             ;;
          a) res_archive=$OPTARG
             ;;
          \?) usage "Erreur: $OPTARG est une option incorrecte."
              ;; 
          :) usage "Erreur: Absence d argument pour l option $OPTARG"
             ;;
          esac
        done
        
        if [ ! -z $res_archive ] ; then 
          IFS=" " ; set $liste_user
          if [ $# -eq 1 ]  
          then extraction_archive $liste_user $res_archive
          else echo -e -u2 "Erreur: un seul utilisateur avec l option a."
          fi
        else
          extraction_archive_liste $liste_user
        fi  
        ;;

    h) usage "Syntaxe de la commande."
        ;; 
     
    \?) usage "Erreur: $OPTARG est une option incorrecte."
        ;;

    :) usage "Erreur: Absence d argument pour l option $OPTARG"
        ;;
  esac
done

## Fin de la gestion des utilisateurs et groupes ##

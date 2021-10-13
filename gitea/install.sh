#!/bin/bash

echo "###############################################################################"
echo "#  MAKE SURE YOU ARE LOGGED IN:                                               #"
echo "#  $ oc login http://api.your.openshift.com                                   #"
echo "###############################################################################"

################################################################################
# Deploy Function                                                              #
################################################################################
LOGGEDIN_USER=$(oc whoami)
DEFAULT_PROJECT="cicd-utils"

function deploy() {
  
  read -p "Enter Your OpenShift Wildcard Domain: "  WILDCARD_DOMAIN
  #WILDCARD_DOMAIN="apps.cluster-br5kw.br5kw.example.opentlc.com"

  echo "Wild Card entered: $WILDCARD_DOMAIN"
  read -p "Press Enter Y to confirm to proceed? " CONFIRMED
  
  if [ -z "$CONFIRMED" ];
  then
    echo "Cancel Provisioning!"
    exit 0
  else
    if  [ $CONFIRMED != "Y" ] && [ $CONFIRMED != "y" ];
    then
        echo "Cancel Provisioning!"
        exit 0
    fi
  fi

  #Setup GITEA
  echo
  echo "Provisioning GITEA!!"
  oc new-app -f ./gitea-persistent-template.yaml -p HOSTNAME='gitea.'$WILDCARD_DOMAIN
}

#echo "function echo_header"
function echo_header() {
  echo
  echo "########################################################################"
  echo $1
  echo "########################################################################"
}

################################################################################
# MAIN: Start                                                                  #
################################################################################

if [ -z "$LOGGEDIN_USER" ]; then
    echo "Please login into your OpenShift"
    exit 255;
fi

echo "Do you want to create cicd-utils project?"
read -p "Press Enter Y to confirm to proceed? " CONFIRMED

if [ ! -z "$CONFIRMED" ] && [ $CONFIRMED == "Y" ] || [ $CONFIRMED == "y" ];
then
    PROJECT_EXIT=$(oc get project | grep $DEFAULT_PROJECT )
    #echo $PROJECT_EXIT
    if [ ! -z "$PROJECT_EXIT" ]; # && [[ $PROJECT_EXIT == $DEFAULT_PROJECT* ]] ;
    then
        echo $DEFAULT_PROJECT" project exits, proceed to provisioning..."
        oc project $DEFAULT_PROJECT
    else
        echo "Creating cicd-utils project..."
        oc new-project $DEFAULT_PROJECT
    fi
else
    CURRENT_PROJECT=$(oc project -q)
    echo "Using current project, "$CURRENT_PROJECT", proceed to provisioning..."
fi

START=`date +%s`
echo
echo_header "Intalling GITEA on OpenShift - ($(date))"
deploy
echo
echo "Provisioning completed successfully!"

END=`date +%s`
echo "(Completed in $(( ($END - $START)/60 )) min $(( ($END - $START)%60 )) sec)"
echo 

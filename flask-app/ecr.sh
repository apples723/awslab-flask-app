#!/bin/bash

set -e; echo $'\n
  --------------------------------- \n
           ECR BUILDER              \n
   author: Grant Sider(apples723)   \n
   last updated: 9-28-2023          \n
  --------------------------------- \n
'


ECR_REGION="us-west-2"
ECR_REPO="awslab-flask-app"

while [ $# -gt 0 ]
do
     case "$1" in
          --region) ECR_REGION="$2"; shift;;
          --account-id) ECR_ACCOUNT_ID="$2"; shift;;
          --image-name) LOCAL_IMAGE_NAME="$2"; shift;;
          --ecr-repo) ECR_REPO="$2"; shift;;
          --ecr-image-tag) ECR_IMAGE_TAG="$2"; shift;;
          --dryrun) echo "SCRIPT MODE: DRYRUN"; DRYRUN="true";;
          --) shift;;
     esac
     shift;
done
if [[ -z $LOCAL_IMAGE_NAME ]]
then
   echo "Missing name of local Docker image to tag for ECR"
   exit $ERRCODE
fi
if [[ -z $ECR_REGION ]]
then
   echo "Missing AWS region for ECR connection"
   exit $ERRCODE
fi
if [[ -z $ECR_ACCOUNT_ID ]]
then
  echo "NOTICE: Using Account ID of default AWS profile..."
  ECR_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account' )
  echo "Current AWS Account ID to be used for ECR: $ECR_ACCOUNT_ID"
fi

if [[ ! -z $ECR_IMAGE_TAG ]]
then
  docker tag $LOCAL_IMAGE_NAME $ECR_ACCOUNT_ID.dkr.ecr.$ECR_REGION.amazonaws.com/$ECR_REPO:$ECR_IMAGE_TAG
else
  docker tag $LOCAL_IMAGE_NAME $ECR_ACCOUNT_ID.dkr.ecr.$ECR_REGION.amazonaws.com/$ECR_REPO
fi 

echo $'\n Starting build process....\n'
sleep 2

echo "ECR REGION: $ECR_REGION"
echo "ECR ACCOUNT ID: $ECR_ACCOUNT_ID"
echo "LOCAL IMAGE NAME: $LOCAL_IMAGE_NAME"
echo "ECR REPO: $ECR_REPO"
echo "ECR IMAGE TAG: $ECR_IMAGE_TAG"

echo $'\n\nLoging into AWS ECR with account ID:' $ECR_ACCOUNT_ID
docker login -u AWS -p $(aws ecr get-login-password --region $ECR_REGION) $ECR_ACCOUNT_ID.dkr.ecr.$ECR_REGION.amazonaws.com >> /dev/null
if [[ -z $ECR_IMAGE_TAG ]] 
then
  ECR_PUSH_PATH="$ECR_ACCOUNT_ID.dkr.ecr.$ECR_REGION.amazonaws.com/$ECR_REPO"
  if [[ $DRYRUN ]]
  then
    echo $'DRY RUN...WILL NOT PUSH IMAGE \n\n\nECR PUSH PATH:'$ECR_PUSH_PATH
  else
    docker push $ECR_PUSH_PATH
  fi  
else
  ECR_PUSH_PATH="$ECR_ACCOUNT_ID.dkr.ecr.$ECR_REGION.amazonaws.com/$ECR_REPO:$ECR_IMAGE_TAG"
  if [[ $DRYRUN ]]
  then
    echo $'DRY RUN...WILL NOT PUSH IMAGE \n\n\nECR PUSH PATH:'$ECR_PUSH_PATH
  else
    docker push $ECR_PUSH_PATH
  fi  
fi
set -e; echo $'\n
  --------------------------- \n
  FINISH: ECR Build Complete  \n 
  ---------------------------
'
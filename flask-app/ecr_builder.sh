#!/bin/bash
if [[ -z $1 ]]
then
  echo "Must include container tag to push to ECR"
  exit $ERRCODE
else
  #get account ID
  ECR_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account' )
  echo "Current AWS Account ID to be used for ECR: $ECR_ACCOUNT_ID"
fi
ECR_REGION="us-west-2"
ECR_REPO="awslab-flask-app"

docker tag $1 $ECR_ACCOUNT_ID.dkr.ecr.$ECR_REGION.amazonaws.com/$ECR_REPO
docker login -u AWS -p $(aws ecr get-login-password --region $ECR_REGION) $ECR_ACCOUNT_ID.dkr.ecr.$ECR_REGION.amazonaws.com
docker push $ECR_ACCOUNT_ID.dkr.ecr.$ECR_REGION.amazonaws.com/$ECR_REPO


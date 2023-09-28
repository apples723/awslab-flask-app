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

if [  $2 ]
then
  IMAGE_TAG=$2
else
  IMAGE_TAG="latest"
fi
echo "tagging image with: $IMAGE_TAG"
docker tag $1 $ECR_ACCOUNT_ID.dkr.ecr.$ECR_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
docker login -u AWS -p $(aws ecr get-login-password --region $ECR_REGION) $ECR_ACCOUNT_ID.dkr.ecr.$ECR_REGION.amazonaws.com
docker push $ECR_ACCOUNT_ID.dkr.ecr.$ECR_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG


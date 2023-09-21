#!/bin/bash 


#aws cli dir
if [ -d "aws" ]
then
	echo "removing aws install dirs"
	rm -rf aws 
	rm -rf awscliv2.zip 
fi
rm -rf aws
#docker install script
if [ -f "get-docker.sh" ] 
then
	echo "removing docker install script"
	rm get-docker.sh
fi


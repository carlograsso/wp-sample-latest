#!/bin/bash

if [[ $(basename "$PWD") == "terraform" ]] ;then
    echo "Let´s start"
else
    echo "ERROR - Please move into terraform folder, exit."
    exit 1
fi


##########    BUCKET SETUP

BUCKET_NAME_STATIC="our-wordpress"

RANDOM_NUM=$(date +%s)

check_bucket_existence (){
    BUCKETS=$(aws s3 ls)
    BUCKET_EXISTS=$(echo ${BUCKETS} | grep ${BUCKET_NAME_STATIC})
}

echo "Checking if a $BUCKET_NAME_STATIC-xxxxxxxxxx exists"
check_bucket_existence

if [[ ${BUCKET_EXISTS} ]]
then
    echo "State bucket already exists"
    BUCKET_NAME=$(echo ${BUCKET_EXISTS} |  awk -F ' ' '{print $3}' )
    echo  $BUCKET_NAME
else
    echo "Creating our state bucket"
    echo $(aws s3api create-bucket --bucket ${BUCKET_NAME_STATIC}-${RANDOM_NUM} --region eu-west-1 --object-ownership BucketOwnerEnforced --create-bucket-configuration LocationConstraint=eu-west-1)

    check_bucket_existence 
    BUCKET_NAME=$(echo ${BUCKET_EXISTS} |  awk -F ' ' '{print $3}' ) 
    echo  $(echo ${BUCKET_EXISTS} |  awk -F ' ' '{print $3}' )
fi

echo "Adding the correct state bucket in backend.tf"
sed -ri "/^[ ]*bucket/c\    bucket = \"${BUCKET_NAME}\"" backend.tf

##########    DB_SECRET
echo "Creating DB password secret"
aws secretsmanager create-secret --name wp-application-db-password --secret-string password &> /tmp/output_secret_gen

if  grep "already exists" < /tmp/output_secret_gen &> /dev/null; then
    echo "The scret already exists"
    exit 0
elif grep "aws configure" < /tmp/output_secret_gen &> /dev/null; then
    echo "ERROR - Please login awscli"
    exit 1
fi

if ! cat /tmp/output_secret_gen; then
    echo "Secret created."
    cat /tmp/output_secret_gen
fi

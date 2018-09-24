#!/bin/bash

JUMP_USER=$1
ACCOUNT=$2
REGION=$3
INST_IP=$4

JUMP_HOST=""
SSH_USER="alt-root"
S3_STRING="s3://"
S3_BUCKET="key-mgmt"

CONF_STRING="--profile ${ACCOUNT} --region ${REGION}"

INST_ID=$(aws ${CONF_STRING} ec2 describe-instances --filter Name=private-ip-address,Values=${INST_IP} --query 'Reservations[].Instances[].InstanceId' --output text)
INST_TAG=$(aws ${CONF_STRING} ec2 describe-instances --instance-ids ${INST_ID} --query 'Reservations[].Instances[].Tags[?Key==`created_at`].Value[]' --output text)
INST_TAG_ENV=$(aws ${CONF_STRING} ec2 describe-instances --instance-ids ${INST_ID} --query 'Reservations[].Instances[].Tags[?Key==`ENV`].Value[]' --output text)

INST_TAG_FINAL="priv_$(echo $INST_TAG | sed "s/\//_/g").pem"

aws ${CONF_STRING} s3 cp ${S3_STRING}${S3_BUCKET}/${INST_TAG}/priv.pem "${INST_TAG_FINAL}"
chmod 400 ${INST_TAG_FINAL}


echo -e "\n"
if [ $INST_TAG_ENV == "HOMOLOG" ]; then
    echo -e "DEVELOPMENT\nssh $INST_IP -l $SSH_USER -i ${INST_TAG_FINAL}"
elif [ $INST_TAG_ENV == "PROD" ]; then
    echo -e "PRODUCTION\nscp ${INST_TAG_FINAL} ${JUMP_USER}@${JUMP_USER}:~/. \nssh -t ${JUMP_USER}@${JUMP_HOST} \"ssh $INST_IP -l $SSH_USER -i ${INST_TAG_FINAL}\""
else 
    echo -e "ENV not recognized\nssh $INST_IP -l $SSH_USER -i ${INST_TAG_FINAL}"
fi

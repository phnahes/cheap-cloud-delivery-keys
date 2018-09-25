#!/bin/bash

JUMP_HOST=""
SSH_USER="alt-root"
S3_STRING="s3://"
S3_BUCKET="key-mgmt"

function main() {

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

}


# Função help, exibe informações de uso do programa.
#
function help() {
echo
        echo "Use: `basename $0` [ -u <usuario para acesso ssh ao jump server> | -a < conta ou nome do profile > | -r < regiao > | -i < IP da instancia > | -h ]"
        echo
        echo "  -u <usuario>              Usuario para acessar Jump Server."
        echo "  -a <profile>              Nome do Profile que devera ser utilizado (Conta AWS)."
        echo "  -r <regiao>               Regiao que a instancia se encontra."
        echo "  -i <192.168.0.2>          Endereço IP (v4) da instancia que devera ser acessada."
        echo "  -h                        Mostra este contexto de ajuda."
        echo
        echo "Utilitario para obtenção de chave privada referente a instancia que deseja acessar."
        echo
        echo "Configurações particulares, como usuario, bucket, jumpserver host, estão dentro do script."
        echo
        exit 0
}

# Função usage, usada quando algum parametro estiver incorreto na linha de comando.
#
function usage() {
        echo
        echo "Uso: `basename $0` [ -u <usuario para acesso ssh ao jump server> | -a < conta ou nome do profile > | -r < regiao > | -i < IP da instancia > | -h ]"
        echo "Experimente "`basename $0` -h" para mais informações."
        echo
}

# Função error retornada caso alguma opção for invalida
#
function error() {
  echo
  echo "Erro ao validar opção"
  echo "Uso: `basename $0` [ -8 <HORA:MINUTOS> | -9 <HORA:MINUTOS> | -h ]" >&2
  echo
  exit 1
}


# Corpo do programa
#
if [ -z "$1" ]; then
  help

else
  while getopts ":u:a:r:i:h" OPTION;
    do
      case $OPTION in
        u) export BASTION_USER=${OPTARG};;
        a) export ACCOUNT=${OPTARG};;
        r) export REGION=${OPTARG};;
        i) export INST_IP=${OPTARG};;
        h) help;;
        \?) usage;;
        :) error;;
      esac
  done
  shift $((OPTIND-1))

fi

main


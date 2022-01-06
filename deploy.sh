#!/bin/bash

SERVER=""
USER=""
PASSWD=""
LOC=""

# This values must match the values in the node server and controller yaml files
DEFAULT_SERVER="registry-1.docker.io"
DEFAULT_LOC="agents/core-dev/cte-k8-builder"

NAMESPACE=default
DEPLOY_FILE_DIR=deploy
YAML_CONFIGS=( \
    "${DEPLOY_FILE_DIR}/kubernetes/rbac-cte-csi-controller.yaml" \
    "${DEPLOY_FILE_DIR}/kubernetes/rbac-cte-csi-nodeserver.yaml" \
    "${DEPLOY_FILE_DIR}/kubernetes/cte-csi-controller.yaml" \
    "${DEPLOY_FILE_DIR}/kubernetes/cte-csi-nodeserver.yaml" \
    )

kube_create_secret()
{
    # Skip if User or Password not set
    if [ -z "${USER}" ] || [ -z "${PASSWD}" ]; then
        return
    fi
    if [[ "${SERVER}" == "" ]]; then
        SERVER=${DEFAULT_SERVER}
    fi

    # TODO: Need to make sure to test with container runtimes other than Docker.
    RUN_CMD="kubectl create secret docker-registry cte-csi-secret
        --docker-server=${SERVER} --docker-username=${USER}
        --docker-password=${PASSWD}"
    echo ${RUN_CMD}
    ${RUN_CMD}
}

remove()
{
    if [[ "${REMOVE}" == "YES" ]]; then
        kubectl delete secrets cte-csi-secret 2> /dev/null
    fi

    for YAML in ${YAML_CONFIGS[@]}; do
        kubectl delete --grace-period=0 --force -f ${YAML} 2> /dev/null
    done
}

start()
{
    if [ -z "${SERVER}" ]; then
        SERVER=${DEFAULT_SERVER}
    fi
    if [ -z "${LOC}" ]; then
        LOC=${DEFAULT_LOC}
    fi

    # Remove all the running containers if any.
    remove

    kube_create_secret

    for YAML in ${YAML_CONFIGS[@]}; do
        cat ${YAML} | sed "s|${DEFAULT_SERVER}/${DEFAULT_LOC}|${SERVER}/${LOC}|" | \
            kubectl apply -f -
    done
}

usage()
{
    echo  "Options :"
    echo  "-s= | --server=   Container registry server value."
    echo  "                             Default: registry-1.docker.io"
    echo  "-u= | --user=     Container registry user name value."
    echo  "-p= | --passwd=     Container registry user password value."
    echo  "-r | --remove     Undeploy the CSI driver and exit"
}

# main
if [ $# -eq 0 ]; then
    echo "Please provide the arguments."
    echo ""
    usage
    exit 1
fi

for i in "$@"; do
    case $i in
        -h|--help)
            usage
            exit 1
            ;;
        -s=*|--server=*)
            SERVER="${i#*=}"
            shift
            ;;
        -u=*|--user=*)
            USER="${i#*=}"
            shift
            ;;
        -p=*|--passwd=*)
            PASSWD="${i#*=}"
            shift
            ;;
        -l=*|--loc=*)
            LOC="${i#*=}"
            shift
            ;;
        -r|--remove)
            REMOVE="YES"
            remove
            exit 1
            ;;
    esac
done

echo "Starting the cte-csi containers."
start

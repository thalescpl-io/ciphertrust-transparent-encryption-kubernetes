#!/bin/bash

USER=""
PASSWD=""
SERVER=""

CSI_DEPLOYMENT_NAME="cte-csi-deployment"

DEPLOY_NAMESPACE="kube-system"
DEPLOY_FILE_DIR=deploy

IMAGE_PULL_SECRET="cte-csi-image-pull-secret"

kube_create_secret()
{
    # Skip if User or Password not set
    if [ -z "${USER}" ] || [ -z "${PASSWD}" || -z "${SERVER}"]; then
        return
    fi

    kubectl get secrets ${IMAGE_PULL_SECRET} --namespace=${DEPLOY_NAMESPACE} > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        kubectl delete secrets ${IMAGE_PULL_SECRET} --namespace=${DEPLOY_NAMESPACE}
        if [ $? -ne 0 ]; then
            exit 1
        fi
    fi

    # TODO: Need to make sure to test with container runtimes other than Docker.
    RUN_CMD="kubectl create secret docker-registry ${IMAGE_PULL_SECRET}
        --docker-server=${SERVER} --docker-username=${USER}
        --docker-password=${PASSWD} --namespace=${DEPLOY_NAMESPACE}"
    echo ${RUN_CMD}
    ${RUN_CMD}
    if [ $? -ne 0 ]; then
        exit 1
    fi
}

check_exec() {
    if ! [ -x "$(command -v ${1})" ]; then
        echo "Error: '${1}' is not installed or not in PATH." >&2
        exit 1
    fi
}

remove()
{
    if [[ "${REMOVE}" == "YES" ]]; then
        kubectl delete secrets ${IMAGE_PULL_SECRET} --namespace=${DEPLOY_NAMESPACE} 2> /dev/null
    fi

	helm delete --namespace=${DEPLOY_NAMESPACE} ${CSI_DEPLOYMENT_NAME} 2> /dev/null
}

get_chart_version() {
    local IFS=.
    vers=($1)
    if [ ${#vers[@]} -ne 4 ]; then
        echo "Invalid tag version"
        exit 1
    fi
    char_version=""
    count = 1
    for i in ${vers}; do
        if [ ! "$i" -ge 0 ]; then
            echo "Invalid tag version"
            exit 1
        fi
    done

    CHART_VERSION=${vers[0]}.${vers[1]}.${vers[2]}
}

start()
{
    check_exec kubectl
    check_exec helm

    CHART_VERSION=latest
    if [ -z "${CSI_TAG}" ]; then
        CHART_VERSION=latest
    else
        get_chart_version $CSI_TAG
        EXTRA_OPTIONS="${EXTRA_OPTIONS} --set image.tag=${CSI_TAG}"
    fi

    kube_create_secret

    echo "Deploying $CSI_DEPLOYMENT_NAME using helm chart..."
    cd "${DEPLOY_FILE_DIR}/kubernetes"

    # "upgrade --install" will install if no prioir install exists, else upgrade
    HELM_CMD="helm upgrade --install --namespace=${DEPLOY_NAMESPACE} ${CSI_DEPLOYMENT_NAME}
              ./${CHART_VERSION} ${EXTRA_OPTIONS}"
    echo ${HELM_CMD}
    ${HELM_CMD}
}

usage()
{
    echo  "Options :"
    echo  "-t | --tag=      Tag of image on the server"
    echo  "                             Default: latest"
    echo  "-r | --remove    Undeploy the CSI driver and exit"
}

# main

L_OPTS="server:,user:,passwd:,tag:,remove,help"
S_OPTS="s:u:p:t:rh"
options=$(getopt -a -l ${L_OPTS} -o ${S_OPTS} -- "$@")
if [ $? -ne 0 ]; then
        exit 1
fi
eval set -- "$options"

while true ; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -s|--server)
            SERVER=${2}
            shift 2
            ;;
        -u|--user)
            USER=${2}
            shift 2
            ;;
        -p|--passwd)
            PASSWD=${2}
            shift 2
            ;;
        -t|--tag)
            CSI_TAG=${2}
            shift 2
            ;;
        -r|--remove)
            REMOVE="YES"
            remove
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo -n "unknown option: ${1}"
            exit 1
            ;;

    esac
done

echo "Starting the cte-csi containers."
start

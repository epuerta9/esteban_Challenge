#!/bin/bash

BRANCH=$1
VERSION=$2

set -x
set -e


aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/y3f6w2p0

docker build -t epuerta-challenge/webapp:latest ../../

docker tag epuerta-challenge/webapp:latest public.ecr.aws/y3f6w2p0/epuerta-challenge/webapp:latest

if [[ $BRANCH == "main" && ! -z $VERSION ]]; then
    
    docker tag epuerta-challenge/webapp:latest public.ecr.aws/y3f6w2p0/epuerta-challenge/webapp:$VERSION
    docker push public.ecr.aws/y3f6w2p0/epuerta-challenge/webapp:$VERSION
    echo "finished pushing to public repo from main"

    exit 0

elif [[ ! -z $BRANCH && ! -z $VERSION ]]; then

    docker tag epuerta-challenge/webapp:latest public.ecr.aws/y3f6w2p0/epuerta-challenge/webapp:$BRANCH$VERSION
    docker push public.ecr.aws/y3f6w2p0/epuerta-challenge/webapp:$BRANCH$VERSION
    echo "finished pushing to public repo with branch version"
    exit 0

fi

docker push public.ecr.aws/y3f6w2p0/epuerta-challenge/webapp:latest
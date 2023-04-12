#!/bin/bash

minikube profile list >/dev/null 2>&1

if [ "$?" -eq 0 ]; then
    echo "A Minikube profile already exist. Skipping"
    exit 0 
fi

echo
echo "Creating and starting a Minikube instance..."
minikube start --cpus=4 --memory=16384m --disk-size=40000mb --addons=ingress

echo
echo "Creating a wildcard certificate for *.$(minikube ip).nip.io and configuring Minikube ingress addon to use it..."
mkcert "*.$(minikube ip).nip.io"
mv ./_wildcard.$(minikube ip).nip.io-key.pem ./_wildcard.$(minikube ip).nip.io.pem /tmp/
kubectl -n kube-system create secret tls mkcert --key /tmp/_wildcard.$(minikube ip).nip.io-key.pem --cert /tmp/_wildcard.$(minikube ip).nip.io.pem
rm /tmp/_wildcard*
echo kube-system/mkcert | minikube addons configure ingress
minikube addons disable ingress && minikube addons enable ingress
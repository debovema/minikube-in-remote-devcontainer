#/bin/bash

minikube profile list >/dev/null 2>&1

if [ "$?" -ne 0 ]; then
    echo "No Minikube profile found"
    /usr/local/bin/init-minikube.sh
fi

minikube status >/dev/null 2>&1

if [ "$?" -ne 0 ]; then
    echo "Minikube not started!"
    echo
    echo "Starting Minikube..."
    minikube start
fi

if [ "$?" -ne 0 ]; then
    echo "Minikube was unable to start"
    exit 1
fi

# retrieve IP of the Dev Container (in the Docker bridge, for instance: 172.17.0.2)
DEVCONTAINER_IP=$(ip -4 -br addr show dev eth0  | awk -F" " '{print $3}'|cut -d'/' -f1)

# forward traffic from Dev Container IP to Minikube IP for port 443
sudo iptables -t nat -A PREROUTING -p tcp --dst $DEVCONTAINER_IP --dport 443 -j DNAT --to-destination $(minikube ip):443
sudo iptables -t nat -A POSTROUTING -j MASQUERADE
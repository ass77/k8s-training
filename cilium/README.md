<div align="center">
    <img src="../assets/cluster mesh.png" alt="arch" width="800" height="350">
  <h3 align="center">k8s-training 101</h3>
</div>

# Getting Started with Cilium

- provision at least `3 nodes` with minikube

```
minikube start --nodes 3 -p <cluster_name> --network-plugin=cni --cni=false

# check status
minikube status -p <cluster_name>
```

## Install Cilium and Hubble CLI

```
curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
rm cilium-linux-amd64.tar.gz{,.sha256sum}

export HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
curl -L --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-amd64.tar.gz{,.sha256sum}
sha256sum --check hubble-linux-amd64.tar.gz.sha256sum
sudo tar xzvfC hubble-linux-amd64.tar.gz /usr/local/bin
rm hubble-linux-amd64.tar.gz{,.sha256sum}
```

## Install Cilium on Current k8s cluster

- with cilium cli

```
cilium install


# check if cilium properly installed
cilium status --wait

# validate network connectivity
cilium connectivity test

```

- with helm

```
helm install cilium cilium/cilium --version 1.12.5 --namespace kube-system

# restart unmanaged pods
kubectl get pods --all-namespaces -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,HOSTNETWORK:.spec.hostNetwork --no-headers=true | grep '<none>' | awk '{print "-n "$1" "$2}' | xargs -L 1 -r kubectl delete pod


# validate installation (manual)
kubectl -n kube-system get pods --watch


# validate network connectivity (manual)
kubectl create ns cilium-test

kubectl apply -n cilium-test -f https://raw.githubusercontent.com/cilium/
cilium/v1.12/examples/kubernetes/connectivity-check/connectivity-check.yaml

kubectl get pods -n cilium-test

kubectl delete ns cilium-test
```

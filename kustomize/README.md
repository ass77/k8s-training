# The Basics

```

kubectl apply -f kustomize/application/namespace.yaml
kubectl apply -f kustomize/application/configmap.yaml
kubectl apply -f kustomize/application/deployment.yaml
kubectl apply -f kustomize/application/service.yaml

# OR

kubectl apply -f kustomize/application/

kubectl delete ns example

```

# Kustomize

## Build

```q
kubectl kustomize kustomize\ | kubectl apply -f -
# OR
kubectl apply -k kustomize\

kubectl delete ns example
```

## Overlays

```
kubectl kustomize kustomize\environments\<phase> | kubectl apply -f -
# OR
kubectl apply -k kustomize\environments\<phase>

kubectl delete ns example
```

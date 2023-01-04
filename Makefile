create-local-k8s-cluster:
	kind create cluster --name locale --image kindest/node:v1.19.1

delete-local-k8s-cluster:
	kind delete cluster --name locale

# use isolate machine to run ops
use-isolate-machine:
	docker run -it --rm -v ${HOME}:/root/ -v ${PWD}:/work -w /work --net host alpine sh
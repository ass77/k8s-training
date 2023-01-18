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

- add helm repo

```
helm repo add cilium https://helm.cilium.io/
```

- deploy cilium via helm

```

helm install cilium cilium/cilium --version 1.12.4 \
--namespace kube-system

```

- restart-unmanaged-pods:

```

kubectl get pods --all-namespaces -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,HOSTNETWORK:.spec.hostNetwork --no-headers=true | grep '<none>' | awk '{print "-n "$1" "$2}' | xargs -L 1 -r kubectl delete pod

```

- cilium-conn-check: check cilium connections

```
cilium connectivity test

kubectl create ns cilium-test
kubectl apply -n cilium-test -f https://raw.githubusercontent.com/cilium/cilium/v1.12/examples/kubernetes/connectivity-check/connectivity-check.yaml

```

- enabling hubble (cilium observability)

```

helm upgrade cilium cilium/cilium --version 1.12.5 \
 --namespace kube-system \
 --reuse-values \
 --set hubble.relay.enabled=true \
 --set hubble.ui.enabled=true

 cilium hubble enable --ui

```

- access hubble ui dashboard

```
cilium hubble ui
```

- <b>Cilium use-case - Flows by ChatGPT</b>

<div class="markdown prose w-full break-words dark:prose-invert dark"><p>example of how you might use Cilium to mesh two applications, "app-A" and "app-B", in a Kubernetes cluster:</p><ol><li>First, you would need to deploy Cilium on your cluster. This can be done by creating a Kubernetes DaemonSet using a YAML manifest, like this:</li></ol><pre><div class="bg-black mb-4 rounded-md"><div class="flex items-center relative text-gray-200 bg-gray-800 px-4 py-2 text-xs font-sans"></div><div class="p-4 overflow-y-auto"><code class="!whitespace-pre-wrap hljs language-yaml"><span class="hljs-attr">apiVersion:</span> <span class="hljs-string">apps/v1</span>
<span class="hljs-attr">kind:</span> <span class="hljs-string">DaemonSet</span>
<span class="hljs-attr">metadata:</span>
  <span class="hljs-attr">name:</span> <span class="hljs-string">cilium</span>
  <span class="hljs-attr">labels:</span>
    <span class="hljs-attr">k8s-app:</span> <span class="hljs-string">cilium</span>
<span class="hljs-attr">spec:</span>
  <span class="hljs-attr">selector:</span>
    <span class="hljs-attr">matchLabels:</span>
      <span class="hljs-attr">k8s-app:</span> <span class="hljs-string">cilium</span>
  <span class="hljs-attr">template:</span>
    <span class="hljs-attr">metadata:</span>
      <span class="hljs-attr">labels:</span>
        <span class="hljs-attr">k8s-app:</span> <span class="hljs-string">cilium</span>
    <span class="hljs-attr">spec:</span>
      <span class="hljs-attr">hostNetwork:</span> <span class="hljs-literal">true</span>
      <span class="hljs-attr">containers:</span>
      <span class="hljs-bullet">-</span> <span class="hljs-attr">name:</span> <span class="hljs-string">cilium</span>
        <span class="hljs-attr">image:</span> <span class="hljs-string">cilium/cilium:v1.14.1</span>
        <span class="hljs-attr">securityContext:</span>
          <span class="hljs-attr">privileged:</span> <span class="hljs-literal">true</span>
        <span class="hljs-attr">env:</span>
          <span class="hljs-bullet">-</span> <span class="hljs-attr">name:</span> <span class="hljs-string">KUBERNETES</span>
            <span class="hljs-attr">value:</span> <span class="hljs-string">"true"</span>
        <span class="hljs-attr">args:</span>
        <span class="hljs-bullet">-</span> <span class="hljs-string">"cilium-agent"</span>
        <span class="hljs-bullet">-</span> <span class="hljs-string">"--mtu"</span>
        <span class="hljs-bullet">-</span> <span class="hljs-string">"1430"</span>
</code></div></div></pre><p>You can apply this manifest to your cluster by running:</p><pre><div class="bg-black mb-4 rounded-md"><div class="flex items-center relative text-gray-200 bg-gray-800 px-4 py-2 text-xs font-sans"></div><div class="p-4 overflow-y-auto"><code class="!whitespace-pre-wrap hljs">kubectl apply -f cilium.yaml
</code></div></div></pre><ol start="2"><li><p>Once Cilium is deployed, you would deploy "app-A" and "app-B" to the cluster, using Kubernetes manifests or using Helm for example.</p></li><li><p>Next, you would use Cilium's command-line interface to create a policy that defines how "app-A" and "app-B" should communicate. For example, you might create a policy that allows all traffic between the two applications, using the cilium command-line.</p></li></ol><pre><div class="bg-black mb-4 rounded-md"><div class="flex items-center relative text-gray-200 bg-gray-800 px-4 py-2 text-xs font-sans"></div><div class="p-4 overflow-y-auto"><code class="!whitespace-pre-wrap hljs language-css">cilium policy create <span class="hljs-attr">--from</span> app-<span class="hljs-selector-tag">A</span> <span class="hljs-attr">--to</span> app-<span class="hljs-selector-tag">B</span> <span class="hljs-attr">--allow</span>
</code></div></div></pre><ol start="4"><li><p>Cilium will then automatically configure the BPF programs on each host in the cluster to enforce the policy you defined, allowing "app-A" and "app-B" to communicate with each other while still being isolated from other services in the cluster.</p></li><li><p>Finally, you can use cilium command line or API to configure L7 load-balancing. For example you can create a service that distribute the traffic between two versions of app-A,</p></li></ol><pre><div class="bg-black mb-4 rounded-md"><div class="flex items-center relative text-gray-200 bg-gray-800 px-4 py-2 text-xs font-sans"></div><div class="p-4 overflow-y-auto"><code class="!whitespace-pre-wrap hljs language-lua">cilium service <span class="hljs-built_in">create</span> app-A-v1 app-A:v1 <span class="hljs-comment">--selector app=app-A,version=v1</span>
cilium service <span class="hljs-built_in">create</span> app-A-v2 app-A:v2 <span class="hljs-comment">--selector app=app-A,version=v2</span>
</code></div></div></pre></div>

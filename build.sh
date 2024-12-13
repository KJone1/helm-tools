#!/usr/bin/env bash

set -euo pipefail

### --- Prep ---
apt-get update
apt-get upgrade -y
apt-get install --no-install-recommends -y curl git-core build-essential jq ca-certificates
install /usr/bin/make /usr/local/bin/make
install /usr/bin/jq /usr/local/bin/jq

### --- Install Helm ---
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

### --- Install helmfile ---
curl -fsSL -o helmfile.tar.gz https://github.com/helmfile/helmfile/releases/download/v0.159.0/helmfile_0.159.0_linux_amd64.tar.gz
tar -xvzf helmfile.tar.gz
install helmfile /usr/local/bin

### --- Install helm-docs ---
curl -fsSL -o helm-docs.tar.gz https://github.com/norwoodj/helm-docs/releases/download/v1.14.2/helm-docs_1.14.2_Linux_x86_64.tar.gz
tar -xvzf helm-docs.tar.gz
install helm-docs /usr/local/bin

### --- Install kubectl ---
curl -L -o /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod 755 /usr/local/bin/kubectl

wget -q -O kubeconform.tar.gz https://github.com/yannh/kubeconform/releases/download/v0.6.7/kubeconform-linux-amd64.tar.gz &
wget -q -O /usr/local/bin/kube-score https://github.com/zegl/kube-score/releases/download/v1.18.0/kube-score_1.18.0_linux_amd64 &
wget -q -O /usr/local/bin/kube-linter https://github.com/stackrox/kube-linter/releases/download/v0.6.8/kube-linter-linux &
wait
tar -xvzf kubeconform.tar.gz
install kubeconform /usr/local/bin
chmod 755 /usr/local/bin/kube-score
chmod 755 /usr/local/bin/kube-linter

### --- Install Helm plugins ---
helm plugin install https://github.com/chartmuseum/helm-push &
helm plugin install https://github.com/jkroepke/helm-secrets &
helm plugin install https://github.com/nikhilsbhat/helm-images &
helm plugin install https://github.com/databus23/helm-diff &
helm plugin install https://github.com/KnechtionsCoding/helm-schema-gen &
helm plugin install https://github.com/helm-unittest/helm-unittest &
wait
# yq -- https://github.com/mikefarah/yq
# taskfile -- https://taskfile.dev
wget -q -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 &
wget -q -O task.tar.gz https://github.com/go-task/task/releases/download/v3.35.1/task_linux_amd64.tar.gz &
wait
chmod 755 /usr/local/bin/yq
tar -xvzf task.tar.gz
install task /usr/local/bin

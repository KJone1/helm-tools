#!/usr/bin/env bash

set -euo pipefail

### --- Prep ---
apt-get update
apt-get upgrade -y
apt-get install --no-install-recommends -y curl wget git-core build-essential jq ca-certificates
install /usr/bin/make /usr/local/bin/make
install /usr/bin/jq /usr/local/bin/jq
wget -q -O - https://dl.k8s.io/release/stable.txt >stable_version

wget -q -O /usr/local/bin/kubectl "https://dl.k8s.io/release/$(cat stable_version)/bin/linux/amd64/kubectl" &
wget -q -O helm.tar.gz https://get.helm.sh/helm-v3.16.3-linux-amd64.tar.gz &
wget -q -O helmfile.tar.gz https://github.com/helmfile/helmfile/releases/download/v0.159.0/helmfile_0.159.0_linux_amd64.tar.gz &
wget -q -O helm-docs.tar.gz https://github.com/norwoodj/helm-docs/releases/download/v1.14.2/helm-docs_1.14.2_Linux_x86_64.tar.gz &
wget -q -O kubeconform.tar.gz https://github.com/yannh/kubeconform/releases/download/v0.6.7/kubeconform-linux-amd64.tar.gz &
wget -q -O /usr/local/bin/kube-score https://github.com/zegl/kube-score/releases/download/v1.18.0/kube-score_1.18.0_linux_amd64 &
wget -q -O /usr/local/bin/kube-linter https://github.com/stackrox/kube-linter/releases/download/v0.6.8/kube-linter-linux &
# yq -- https://github.com/mikefarah/yq
wget -q -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 &
# taskfile -- https://taskfile.dev
wget -q -O task.tar.gz https://github.com/go-task/task/releases/download/v3.35.1/task_linux_amd64.tar.gz &
wait

# ---

tar -xvzf helm.tar.gz --strip-components=1 
install helm /usr/local/bin

tar -xvzf helmfile.tar.gz
install helmfile /usr/local/bin

tar -xvzf helm-docs.tar.gz
install helm-docs /usr/local/bin

chmod 755 /usr/local/bin/kubectl

tar -xvzf kubeconform.tar.gz
install kubeconform /usr/local/bin

chmod 755 /usr/local/bin/kube-score
chmod 755 /usr/local/bin/kube-linter

chmod 755 /usr/local/bin/yq

tar -xvzf task.tar.gz
install task /usr/local/bin

# --- Install Helm plugins ---
helm plugin install https://github.com/chartmuseum/helm-push &
helm plugin install https://github.com/jkroepke/helm-secrets &
helm plugin install https://github.com/nikhilsbhat/helm-images &
helm plugin install https://github.com/databus23/helm-diff &
helm plugin install https://github.com/KnechtionsCoding/helm-schema-gen &
helm plugin install https://github.com/helm-unittest/helm-unittest &
wait

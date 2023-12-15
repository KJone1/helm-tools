FROM debian:stable-slim as build

WORKDIR /opt

### --- Prep ---
RUN <<EOF

  apt-get update && apt-get upgrade -y 
  apt-get install curl git-core -y
  apt install build-essential -y

  install /usr/bin/make /usr/local/bin/make

EOF

RUN <<EOF

  ### Install Helm ###
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 
  chmod 700 get_helm.sh 
  ./get_helm.sh
  ### Install helmfile ###
  curl -fsSL -o helmfile.tar.gz https://github.com/helmfile/helmfile/releases/download/v0.159.0/helmfile_0.159.0_linux_amd64.tar.gz
  tar -xvzf helmfile.tar.gz
  install helmfile /usr/local/bin
  ### Install helm-docs ###
  curl -fsSL -o helm-docs.tar.gz https://github.com/norwoodj/helm-docs/releases/download/v1.11.3/helm-docs_1.11.3_Linux_x86_64.tar.gz
  tar -xvzf helm-docs.tar.gz
  install helm-docs /usr/local/bin
  ### Install kubectl ###
  curl -L -o /usr/local/bin/kubectl https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
  chmod 755 /usr/local/bin/kubectl
  ###
  curl -fsSL -o kubeconform.tar.gz https://github.com/yannh/kubeconform/releases/download/v0.6.3/kubeconform-linux-amd64.tar.gz
  tar -xvzf kubeconform.tar.gz
  install kubeconform /usr/local/bin
  ###
  curl -fsSL -o /usr/local/bin/kube-score https://github.com/zegl/kube-score/releases/download/v1.17.0/kube-score_1.17.0_linux_amd64
  chmod 755 /usr/local/bin/kube-score
  ###
  curl -fsSL -o /usr/local/bin/kube-linter https://github.com/stackrox/kube-linter/releases/download/v0.6.4/kube-linter-linux
  chmod 755 /usr/local/bin/kube-linter

EOF

### --- Install Helm plugins ---
RUN <<EOF

  # Helm-tools V1 plugins
  helm plugin install https://github.com/chartmuseum/helm-push
  helm plugin install https://github.com/jkroepke/helm-secrets
  helm plugin install https://github.com/nikhilsbhat/helm-images
  helm plugin install https://github.com/databus23/helm-diff
  # Helm-tools V2 plugins
  helm plugin install https://github.com/KnechtionsCoding/helm-schema-gen
  helm plugin install https://github.com/helm-unittest/helm-unittest
  helm plugin install https://github.com/halkeye/helm-repo-html

EOF


FROM busybox:1.35.0-glibc

WORKDIR /opt

ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV HELM_PLUGINS="/opt/helm/plugins"
ENV KUBECONFIG="/opt/config"

COPY --from=build /usr/local/bin/ /usr/local/bin/
# Make so dependency
COPY --from=build /usr/lib/x86_64-linux-gnu/libdl.so.2 /lib/libdl.so.2
COPY --from=build /root/.local/share/helm/plugins /opt/helm/plugins

CMD [ "/bin/ash" ]

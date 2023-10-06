FROM debian:stable-slim as build

WORKDIR /opt

RUN <<EOF
  apt-get update && apt-get upgrade -y 
  apt-get install curl git-core -y 
  ### Install Helm ###
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 
  chmod 700 get_helm.sh 
  ./get_helm.sh
  ### Install helmfile ###
  curl -fsSL -o helmfile.tar.gz https://github.com/helmfile/helmfile/releases/download/v0.157.0/helmfile_0.157.0_linux_amd64.tar.gz
  tar -xvzf helmfile.tar.gz
  mv helmfile /usr/local/bin
  chown root:root /usr/local/bin/helmfile
  ### Install helm-docs ###
  curl -fsSL -o helm-docs.tar.gz https://github.com/norwoodj/helm-docs/releases/download/v1.11.2/helm-docs_1.11.2_Linux_x86_64.tar.gz
  tar -xvzf helm-docs.tar.gz
  mv helm-docs /usr/local/bin
  ### Install kubectl ###
  curl -L -o /usr/local/bin/kubectl https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
  chmod 755 /usr/local/bin/kubectl
  ###
  # --- Helm-tools V1 plugins ---
  helm plugin install https://github.com/chartmuseum/helm-push
  helm plugin install https://github.com/jkroepke/helm-secrets
  helm plugin install https://github.com/nikhilsbhat/helm-images
  helm plugin install https://github.com/databus23/helm-diff
  # --- Helm-tools V2 plugins ---
  helm plugin install https://github.com/KnechtionsCoding/helm-schema-gen.git
  helm plugin install https://github.com/helm-unittest/helm-unittest.git
  helm plugin install https://github.com/halkeye/helm-repo-html

EOF

FROM busybox:1.35.0-glibc

WORKDIR /opt

ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV HELM_PLUGINS="/opt/helm/plugins"
ENV KUBECONFIG="/opt/config"

COPY --from=build /usr/local/bin/ /usr/local/bin/
COPY --from=build /root/.local/share/helm/plugins /opt/helm/plugins

CMD [ "/bin/ash" ]

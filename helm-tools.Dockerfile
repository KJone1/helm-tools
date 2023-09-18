FROM debian:stable-slim as build

WORKDIR /opt

RUN <<EOF
  apt-get update && apt-get upgrade -y 
  apt-get install curl -y 
  apt-get install git-core -y
  ### 
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 
  chmod 700 get_helm.sh 
  ./get_helm.sh
  ### 
  curl -fsSL -o helmfile.tar.gz https://github.com/helmfile/helmfile/releases/download/v0.155.1/helmfile_0.155.1_linux_amd64.tar.gz
  tar -xvzf helmfile.tar.gz
  mv helmfile /usr/local/bin
  ###
  curl -fsSL -o helm-docs.tar.gz https://github.com/norwoodj/helm-docs/releases/download/v1.11.0/helm-docs_1.11.0_Linux_x86_64.tar.gz
  tar -xvzf helm-docs.tar.gz
  mv helm-docs /usr/local/bin
  ###
  # --- Helm-tools V1 plugins ---
  helm plugin install https://github.com/komodorio/helm-dashboard.git
  helm plugin install https://github.com/adamreese/helm-env
  helm plugin install https://github.com/chartmuseum/helm-push
  helm plugin install https://github.com/jkroepke/helm-secrets
  helm plugin install https://github.com/hypnoglow/helm-s3.git
  helm plugin install https://github.com/nikhilsbhat/helm-images
  helm plugin install https://github.com/databus23/helm-diff
  helm plugin install https://github.com/aslafy-z/helm-git
  # --- Helm-tools V2 plugins ---
  helm plugin install https://github.com/KnechtionsCoding/helm-schema-gen.git
  helm plugin install https://github.com/helm-unittest/helm-unittest.git

EOF

FROM busybox:1.35.0-glibc

WORKDIR /opt

ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV HELM_PLUGINS="/opt/helm/plugins"
ENV KUBECONFIG="/opt/config"

COPY --from=build /usr/local/bin/ /usr/local/bin/
COPY --from=build /root/.local/share/helm/plugins /opt/helm/plugins

CMD [ "/bin/ash" ]

FROM debian:stable-slim as build

WORKDIR /opt

### --- Prep ---
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install --no-install-recommends -y curl git-core build-essential jq ca-certificates\
  && install /usr/bin/make /usr/local/bin/make \
  && install /usr/bin/jq /usr/local/bin/jq

### Install Helm ###
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
  && chmod 700 get_helm.sh \
  && ./get_helm.sh

### Install helmfile ###
RUN curl -fsSL -o helmfile.tar.gz https://github.com/helmfile/helmfile/releases/download/v0.159.0/helmfile_0.159.0_linux_amd64.tar.gz \
  && tar -xvzf helmfile.tar.gz \
  && install helmfile /usr/local/bin

### Install helm-docs ###
RUN curl -fsSL -o helm-docs.tar.gz https://github.com/norwoodj/helm-docs/releases/download/v1.14.2/helm-docs_1.14.2_Linux_x86_64.tar.gz \
  && tar -xvzf helm-docs.tar.gz \
  && install helm-docs /usr/local/bin

### Install kubectl ###
RUN curl -L -o /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
  && chmod 755 /usr/local/bin/kubectl

RUN curl -fsSL -o kubeconform.tar.gz https://github.com/yannh/kubeconform/releases/download/v0.6.7/kubeconform-linux-amd64.tar.gz \
  && tar -xvzf kubeconform.tar.gz \
  && install kubeconform /usr/local/bin

RUN curl -fsSL -o /usr/local/bin/kube-score https://github.com/zegl/kube-score/releases/download/v1.18.0/kube-score_1.18.0_linux_amd64 \
  && chmod 755 /usr/local/bin/kube-score

RUN curl -fsSL -o /usr/local/bin/kube-linter https://github.com/stackrox/kube-linter/releases/download/v0.6.8/kube-linter-linux \
  && chmod 755 /usr/local/bin/kube-linter

### --- Install Helm plugins ---
RUN helm plugin install https://github.com/chartmuseum/helm-push
RUN helm plugin install https://github.com/jkroepke/helm-secrets
RUN helm plugin install https://github.com/nikhilsbhat/helm-images
RUN helm plugin install https://github.com/databus23/helm-diff
RUN helm plugin install https://github.com/KnechtionsCoding/helm-schema-gen
RUN helm plugin install https://github.com/helm-unittest/helm-unittest


# yq -- https://github.com/mikefarah/yq
RUN curl -fsSL -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
  && chmod 755 /usr/local/bin/yq

# taskfile -- https://taskfile.dev
RUN curl -fsSL -o task.tar.gz https://github.com/go-task/task/releases/download/v3.35.1/task_linux_amd64.tar.gz \
  && tar -xvzf task.tar.gz \
  && install task /usr/local/bin


FROM busybox:1.37.0-glibc

WORKDIR /opt

ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV HELM_PLUGINS="/opt/helm/plugins"
ENV KUBECONFIG="/opt/config"

COPY --from=build /usr/local/bin/ /usr/local/bin/
COPY --from=build /root/.local/share/helm/plugins /opt/helm/plugins
# so dependencies
COPY --from=build /usr/lib/x86_64-linux-gnu/libdl.so.2 /lib/libdl.so.2
COPY --from=build /usr/lib/x86_64-linux-gnu/libjq.so.1 /lib/libjq.so.1
COPY --from=build /usr/lib/x86_64-linux-gnu/libonig.so.5 /lib/libonig.so.5

CMD [ "/bin/ash" ]

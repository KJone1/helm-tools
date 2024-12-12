FROM debian:stable-slim AS build

WORKDIR /opt

COPY --chmod=0755 build.sh .

RUN ./build.sh

FROM busybox:1.37.0-glibc

WORKDIR /opt

ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV HELM_PLUGINS="/opt/helm/plugins"
ENV KUBECONFIG="/opt/config"

COPY --from=build --link /usr/local/bin/ /usr/local/bin/
COPY --from=build --link /root/.local/share/helm/plugins /opt/helm/plugins
# so dependencies
COPY --from=build --link /usr/lib/x86_64-linux-gnu/libdl.so.2 /lib/libdl.so.2
COPY --from=build --link /usr/lib/x86_64-linux-gnu/libjq.so.1 /lib/libjq.so.1
COPY --from=build --link /usr/lib/x86_64-linux-gnu/libonig.so.5 /lib/libonig.so.5

CMD [ "/bin/ash" ]

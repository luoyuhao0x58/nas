FROM debian:trixie-slim
ARG MIRROR=mirrors.aliyun.com
ARG TZ=Asia/Shanghai
COPY --chmod=755 ./setup.sh /tmp/setup.sh
RUN /tmp/setup.sh && rm -rf /tmp/*

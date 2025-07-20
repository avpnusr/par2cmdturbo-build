# syntax=docker/dockerfile:experimental

FROM alpine:latest AS builder
ARG PAR2_VERSION TARGETARCH TARGETVARIANT
RUN CPUARCH=${TARGETARCH}${TARGETVARIANT} \
&& if [ $CPUARCH == "armv6" ]; then export QEMU_CPU="arm1176"; fi \
&& apk add --no-cache build-base autoconf automake \
&& mkdir -p /src/par2cmdline-turbo 

WORKDIR /src/par2cmdline-turbo
ADD https://github.com/animetosho/par2cmdline-turbo.git#${PAR2_VERSION} .
RUN && ./automake.sh \
    && ./configure \
    && make -j2 \
    && cp par2 /par2_${TARGETARCH}${TARGETVARIANT} 

FROM scratch AS export-unrar
ARG TARGETARCH TARGETVARIANT
COPY --from=builder /par2_${TARGETARCH}${TARGETVARIANT} /
ENTRYPOINT ["/par2_${TARGETARCH}${TARGETVARIANT}"]
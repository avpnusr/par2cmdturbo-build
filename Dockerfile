FROM alpine:latest AS builder
ARG PAR2_VERSION TARGETARCH TARGETVARIANT
RUN CPUARCH=${TARGETARCH}${TARGETVARIANT} \
&& if [ $CPUARCH == "armv6" ]; then export QEMU_CPU="arm1176"; fi \
&& apk add -U --update --no-cache build-base autoconf automake git \
&& mkdir -p /src

WORKDIR /src

RUN git clone --branch ${PAR2_VERSION} https://github.com/animetosho/par2cmdline-turbo.git \
    && cd par2cmdline-turbo \
    && ./automake.sh \
    && ./configure \
    && make -j2 \
    && cp par2 /par2_${TARGETARCH}${TARGETVARIANT} 

FROM scratch AS export-unrar
ARG TARGETARCH TARGETVARIANT
COPY --from=builder /par2_${TARGETARCH}${TARGETVARIANT} /
ENTRYPOINT ["/par2_${TARGETARCH}${TARGETVARIANT}"]
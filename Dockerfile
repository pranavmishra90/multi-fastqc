# syntax=docker/dockerfile:1

FROM ubuntu:24.04

ARG FASTQC_VERSION=''
ARG MULTIQC_VERSION=''
ARG IMAGE_VERSION=''
ARG ISO_DATETIME=''

ENV FASTQC_VERSION=${FASTQC_VERSION}
ENV MULTIQC_VERSION=${MULTIQC_VERSION}

ENV DEBIAN_FRONTEND="noninteractive"
ENV TZ="America/Chicago"
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Install packages via apt and pip
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN --mount=type=cache,target=/var/cache/apt,sharing=shared \
    --mount=type=cache,target=/var/lib/apt,sharing=shared \
    apt update && \
    apt install -y wget make coreutils openjdk-11-jdk \
    python3 python3-pip \
	unzip \
    pipx \
    parallel && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Copy and Install FastQC

COPY fastqc_v${FASTQC_VERSION}.zip /tmp/fastqc.zip
RUN unzip /tmp/fastqc.zip -d /usr/local/ && \
    chmod +x /usr/local/FastQC/fastqc && \
    ln -s /usr/local/FastQC/fastqc /usr/local/bin/fastqc && \
    rm /tmp/fastqc.zip


RUN pipx ensurepath && pipx install multiqc==${MULTIQC_VERSION}

##############################################################################################
LABEL org.opencontainers.image.title="Multi-FastQC"
LABEL version=${IMAGE_VERSION}
LABEL org.opencontainers.image.version=${IMAGE_VERSION}
LABEL org.opencontainers.image.authors='Pranav Kumar Mishra'
LABEL description="A small docker container with FastQC and MultiQC installed"
LABEL org.opencontainers.image.source="https://github.com/pranavmishra90/multi-fastqc"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.created=${ISO_DATETIME}
##############################################################################################

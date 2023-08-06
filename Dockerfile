FROM ubuntu:20.04

# Install tools
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update && \
    apt install -y wget make coreutils openjdk-11-jdk \
    python3 python3-pip \
	unzip \
    parallel \
    fastqc

RUN pip3 install multiqc

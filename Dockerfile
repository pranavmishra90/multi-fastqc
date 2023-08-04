FROM ubuntu:20.04

# Install tools
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update && \
    apt install -y wget make coreutils openjdk-11-jdk \
    python3 python3-pip \
	unzip \
    parallel

RUN pip3 install multiqc

# Install FastQC; replace low java memory requirement in fastq perl code
ADD fastqc_v0.11.9.zip /usr/local/
RUN cd /usr/local && \
    unzip fastqc_v0.11.9.zip && \
    mv s-andrews-FastQC-f61eee7 fastqc && \
    sed -i 's/Xmx250m/Xmx2048m/' fastqc/fastqc && \
    chmod 755 fastqc/fastqc
ENV PATH /usr/local/fastqc/FastQC/:$PATH

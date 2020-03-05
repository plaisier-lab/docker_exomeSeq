FROM ubuntu:latest
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
MAINTAINER Chris Plaisier <plaisier@asu.edu>

RUN apt-get update

RUN apt-get install --yes software-properties-common

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9

RUN add-apt-repository "deb [trusted=yes] https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/"

RUN apt-get update

# Turn off interactive installation features
ENV DEBIAN_FRONTEND=noninteractive

# Prepare Ubuntu by installing necessary dependencies
RUN apt-get install --yes \
 build-essential \
 gcc-multilib \
 apt-utils \
 zlib1g-dev \
 vim-common \
 wget \
 python \
 python-pip \
 git \
 pigz \
 r-base \
 r-base-dev \
 libxml2 \
 libxml2-dev \
 bwa \
 samtools

# Build BWA reference
RUN mkdir /hg38_reference
WORKDIR /hg38_reference
RUN wget http://hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/hg38.chromFa.tar.gz
RUN tar zvfx hg38.chromFa.tar.gz
RUN cat chroms/*.fa > wg.fa
RUN rm -r chroms hg38.chromFa.tar.gz
RUN bwa index -p hg38bwaidx -a bwtsw wg.fa

# Install Python package dependencies
RUN pip install Cython
RUN pip install biopython reportlab matplotlib numpy scipy pandas pyfaidx pysam pyvcf cnvkit

# Install R dependencies
RUN R -e "install.packages(c('BiocManager'), repos = 'http://cran.us.r-project.org')"
# Bioconductor packages (impute, topGO)
RUN R -e "BiocManager::install(c('DNAcopy',''))"

# Install fused lasso
RUN wget https://cran.r-project.org/src/contrib/Archive/cghFLasso/cghFLasso_0.2-1.tar.gz
RUN R CMD INSTALL cghFLasso_0.2-1.tar.gz

# Setup the bin
WORKDIR /root
RUN mkdir bin
ENV PATH /root/bin:$PATH

# Install picard
RUN apt-get install --yes \
  openjdk-8-jre
WORKDIR /root
RUN wget https://github.com/broadinstitute/picard/releases/download/2.22.0/picard.jar
ENV PICARD /root/picard.jar

# Install GATK
WORKDIR /root
RUN wget https://github.com/broadinstitute/gatk/releases/download/4.1.5.0/gatk-4.1.5.0.zip
RUN unzip /root/gatk-4.1.5.0.zip
RUN ln -s /root/gatk-4.1.5.0/gatk /root/bin/gatk

# Install BEDtools
RUN apt-get install --yes \
  bedtools

WORKDIR /

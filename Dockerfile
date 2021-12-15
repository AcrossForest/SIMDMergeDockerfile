FROM continuumio/anaconda3

RUN apt-get update \
    && apt-get install -y build-essential cmake fish make gawk bison texinfo flex automake libtool openssh-server \
        git m4 scons zlib1g zlib1g-dev \
        libprotobuf-dev protobuf-compiler libprotoc-dev libgoogle-perftools-dev \
        python3-dev python3-six python-is-python3 libboost-all-dev pkg-config

RUN conda install -y scons=3.1.2 \
    && conda install -y -c conda-forge sparse

RUN sed -i -e '$aPermitRootLogin yes' /etc/ssh/sshd_config \
    && echo "root:simd_merge" | chpasswd


COPY step01_cloneAndBuild.sh /root/step01_cloneAndBuild.sh
RUN conda init bash && /bin/bash /root/step01_cloneAndBuild.sh


COPY step02_buildBench.sh /root/step02_buildBench.sh
RUN conda init bash && /bin/bash /root/step02_buildBench.sh

COPY . /root/

EXPOSE 22
ENTRYPOINT service ssh restart && /bin/bash

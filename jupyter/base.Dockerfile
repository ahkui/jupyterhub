FROM nvidia/cuda:10.1-cudnn7-devel

FROM alpine

COPY --from=0 /etc/apt/sources.list /etc/apt/sources.list

RUN apk add --no-cache curl jq && \
    export COUNTRY=$(curl ipinfo.io | jq '.country' | tr -d "\"") && \
    sed -i "s|http:\/\/security|http:\/\/$COUNTRY.archive|g" /etc/apt/sources.list && \
    sed -i "s|http:\/\/archive|http:\/\/$COUNTRY.archive|g" /etc/apt/sources.list


FROM nvidia/cuda:10.1-cudnn7-devel

COPY --from=1 /etc/apt/sources.list /etc/apt/sources.list

RUN apt update && \
    apt-get install -yqq \
    build-essential \
    libssl-dev \
    git \
    && \
    git clone https://github.com/wg/wrk.git wrk && \
    cd wrk && \
    make --silent -j $(nproc) && \
    mv wrk /usr/local/bin

FROM nvidia/cuda:10.1-cudnn7-devel

ARG DEBIAN_FRONTEND=noninteractive

LABEL maintainer="ahkui <ahkui@outlook.com>"

COPY --from=1 /etc/apt/sources.list /etc/apt/sources.list
COPY --from=2 /usr/local/bin/wrk /usr/local/bin/wrk

ENV PATH="/opt/cmake-3.14.2-Linux-x86_64/bin:${PATH}"
RUN apt-get update && apt-get install -yqq --no-install-recommends \
    software-properties-common \
    build-essential \
    python \
    python-dev \
    python3 \
    python3-dev \
    pkg-config \
    rsync \
    curl \
    wget \
    unzip \
    iputils-ping \
    net-tools \
    netcat \
    git \
    openssh-server \
    vim \
    htop \
    nmap \
    nmon \
    iperf3 \
    texlive-full \
    pandoc \
    p7zip-full \
    tree \
    apache2 \
    nginx \
    libpng-dev \
    libzmq3-dev \
    libpq-dev \
    && \
    git config --global credential.helper store \
    && \
    apt-get clean \
    && \
    rm -rf /var/lib/apt/lists/* \
    && \
    wget --quiet https://github.com/Kitware/CMake/releases/download/v3.14.2/cmake-3.14.2-Linux-x86_64.tar.gz \
    && \
    tar xzf cmake-3.14.2-Linux-x86_64.tar.gz -C /opt \
    && \
    rm cmake-3.14.2-Linux-x86_64.tar.gz

RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.10.0/tini && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python3 get-pip.py && \
    python2 get-pip.py && \
    rm get-pip.py

# Pick up some TF dependencies
#RUN apt-get update && apt-get install -yqq --no-install-recommends apt-utils && \
RUN apt-get update && apt-get install -yqq --no-install-recommends --allow-change-held-packages \
    cuda-command-line-tools-10-0 \
    libcublas-dev \
    cuda-cufft-10-1 \
    cuda-curand-10-1 \
    cuda-cusolver-10-1 \
    cuda-cusparse-10-1 \
    cuda-cublas-10-1 \
    libnccl2 \
    libnccl-dev \
    libfreetype6-dev \
    protobuf-compiler \
    libnvinfer5 \
    libnvinfer-dev \
    libprotobuf-dev \
    libopencv-dev \
    libgoogle-glog-dev \
    libboost-all-dev \
    libhdf5-dev \
    libhdf5-serial-dev \
    libatlas-base-dev \
    && \
    apt-get clean \
    && \
    rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && \
    apt-get update && apt-get install -yqq --no-install-recommends \
    nodejs \
    && \
    apt-get clean \
    && \
    rm -rf /var/lib/apt/lists/*

ARG PIP="selenium psycopg2-binary psycopg2 Pillow h5py ipykernel jupyter notebook keras keras_applications keras_preprocessing matplotlib numpy pandas scipy sklearn Flask gunicorn pymongo redis requests ipyparallel bs4 nbconvert pandoc opencv-python django selenium jupyterlab jupyterlab-git jupyterlab_github"
# RUN python2 -m pip --no-cache-dir install \
#     ${PIP} && \
RUN python3 -m pip --no-cache-dir install \
    tornado==5.1.1 \
    jupyterhub \
    git+git://github.com/powerline/powerline \
    ${PIP} \
    && \
    python3 -m ipykernel.kernelspec

ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH
ENV PYTHONPATH /usr/local/python:$PYTHONPATH
ARG OPENPOSE_MODELS_PROVIDER=http://posefs1.perception.cs.cmu.edu/OpenPose/models/
RUN git clone --depth=1 https://github.com/CMU-Perceptual-Computing-Lab/openpose.git \
    && \
    cd openpose \
    && \
    git submodule update --init --recursive \
    && \
    cd models \
    && \
    sed -i "s,http://posefs1.perception.cs.cmu.edu/OpenPose/models/,$OPENPOSE_MODELS_PROVIDER,g" getModels.sh \
    && \
    ./getModels.sh \
    && \
    cd .. \
    && \
    mkdir build

RUN npm install -g --unsafe-perm=true \
    @vue/cli \
    @vue/cli-service-global \
    ijavascript \
    && \
    ijsinstall \
    && \
    rm -rf ~/.npm

RUN add-apt-repository ppa:ondrej/php && \
    apt-get update && apt-get install -yqq --no-install-recommends \
    php7.3 \
    php7.3-fpm \
    php7.3-curl \
    php7.3-zmq \
    && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/bin --filename=composer && \
    php -r "unlink('composer-setup.php');" && \
    composer global require hirak/prestissimo && \
    wget --quiet https://litipk.github.io/Jupyter-PHP-Installer/dist/jupyter-php-installer.phar && \
    php ./jupyter-php-installer.phar install && \
    rm jupyter-php-installer.phar \
    && \
    apt-get clean \
    && \
    rm -rf /var/lib/apt/lists/*

RUN export TODAY=$(date +'%Y-%m-%d') && \
    echo $TODAY && \
    echo https://root.cern.ch/download/cling/cling_${TODAY}_ubuntu18.tar.bz2 && \
    wget --quiet -L https://root.cern.ch/download/cling/cling_${TODAY}_ubuntu18.tar.bz2 || { \
    unset TODAY && \
    export TODAY=$(date -d 'yesterday'  +'%Y-%m-%d') && \
    echo $TODAY && \
    echo https://root.cern.ch/download/cling/cling_${TODAY}_ubuntu18.tar.bz2 && \
    wget -L https://root.cern.ch/download/cling/cling_${TODAY}_ubuntu18.tar.bz2 -q \
    ;} && \
    tar -xf cling_${TODAY}_ubuntu18.tar.bz2 && \
    rm cling_${TODAY}_ubuntu18.tar.bz2 && \
    rsync -av ./cling_${TODAY}_ubuntu18/ /usr/ && \
    cd /usr/share/cling/Jupyter/kernel/ && \
    python3 -m pip install -e . && \
    jupyter-kernelspec install cling-cpp11 && \
    jupyter-kernelspec install cling-cpp14 && \
    jupyter-kernelspec install cling-cpp17

ARG GRADLE_MAVEN=5.6.2
ENV PATH=$PATH:/opt/gradle/gradle-$GRADLE_MAVEN/bin
RUN apt update && apt install -yqq default-jdk maven && \
    wget --quiet https://services.gradle.org/distributions/gradle-$GRADLE_MAVEN-bin.zip && \
    mkdir /opt/gradle && \
    unzip -qq -d /opt/gradle gradle-$GRADLE_MAVEN-bin.zip && \
    rm gradle-$GRADLE_MAVEN-bin.zip

RUN git clone --depth 1 https://github.com/SpencerPark/IJava.git && \
    cd IJava/ && \
    chmod u+x gradlew && ./gradlew installKernel

RUN jupyter labextension install \
    @fissio/hub-topbar-buttons \
    @jupyterlab/git \
    @jupyterlab/github \
    @jupyterlab/toc \
    @jupyterlab/google-drive \
    @jupyter-widgets/jupyterlab-manager \
    && \
    jupyter serverextension enable --py jupyterlab_git \
    && \
    jupyter serverextension enable --py jupyterlab_github \
    && \
    jupyter lab clean \
    && \
    jupyter lab build || \
    cat /tmp/jupyterlab-debug-*.log


RUN ln -s -f /usr/bin/python3 /usr/bin/python

COPY jupyter_notebook_config.py /root/.jupyter/

COPY notebooks /notebooks

COPY run_jupyter.sh /

RUN cd ~ && \
    git clone --depth=1 https://github.com/ahkui/.vim.git && \
    ln -s -f ~/.vim/vimrc-powerline ~/.vimrc && \
    cd ~/.vim/ && \
    ./install.sh && \
    echo . /usr/local/lib/python3.6/dist-packages/powerline/bindings/bash/powerline.sh >> ~/.bashrc && \
    echo export LC_ALL=C.UTF-8 >> ~/.bashrc && \
    echo export LANG=C.UTF-8 >> ~/.bashrc

COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start-notebook.sh
RUN chmod +x /usr/local/bin/start-singleuser.sh

EXPOSE 6006 8888

WORKDIR /notebooks

ENTRYPOINT ["tini", "--"]

CMD ["start-notebook.sh"]

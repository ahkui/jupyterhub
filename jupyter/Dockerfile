FROM nvidia/cuda:10.0-cudnn7-devel

FROM alpine

COPY --from=0 /etc/apt/sources.list /etc/apt/sources.list

RUN apk add --no-cache curl jq && \
    export COUNTRY=$(curl ipinfo.io | jq '.country' | tr -d '"') && \
    sed -i "s|http:\/\/archive|http:\/\/$COUNTRY.archive|g" /etc/apt/sources.list

FROM nvidia/cuda:10.0-cudnn7-devel

COPY --from=1 /etc/apt/sources.list /etc/apt/sources.list

RUN apt update && \
    apt-get install -y \
        build-essential \
        libssl-dev \
        git \
        && \
    git clone https://github.com/wg/wrk.git wrk && \
    cd wrk && \
    make -j $(nproc) && \
    mv wrk /usr/local/bin

FROM nvidia/cuda:10.0-cudnn7-devel

ARG DEBIAN_FRONTEND=noninteractive

ARG JUPYTERHUB_ENABLE_NVIDIA
ENV JUPYTERHUB_ENABLE_NVIDIA=${JUPYTERHUB_ENABLE_NVIDIA}

LABEL maintainer="ahkui <ahkui@outlook.com>"

COPY --from=1 /etc/apt/sources.list /etc/apt/sources.list
COPY --from=2 /usr/local/bin/wrk /usr/local/bin/wrk

RUN apt-get update && apt-get install -y --no-install-recommends \
        software-properties-common \
        build-essential \
        python \
        python-dev \
        python3 \
        python3-dev \
        pkg-config \
        rsync \
        cmake \
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
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.10.0/tini && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python3 get-pip.py && \
    python2 get-pip.py && \
    rm get-pip.py

# Pick up some TF dependencies
#RUN apt-get update && apt-get install -y --no-install-recommends apt-utils && \
RUN apt-get update && apt-get install -y --no-install-recommends --allow-change-held-packages \
        cuda-command-line-tools-10-0 \
        cuda-cublas-10-0 \
        cuda-cufft-10-0 \
        cuda-curand-10-0 \
        cuda-cusolver-10-0 \
        cuda-cusparse-10-0 \
        libnccl2 \
        libfreetype6-dev \
        libhdf5-serial-dev \
        nvinfer-runtime-trt-repo-ubuntu1804-5.0.2-ga-cuda10.0 \
        && \
    apt-get clean \
        && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends --allow-change-held-packages \
        protobuf-compiler \
        libnvinfer5 \
        libprotobuf-dev \
        libopencv-dev \
        libgoogle-glog-dev \
        libboost-all-dev \
        libcaffe-cuda-dev \
        libhdf5-dev \
        libatlas-base-dev \
        && \
    apt-get clean \
        && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
        caffe-cpu \
        && \
    apt-get clean \
        && \
    rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
        && \
    apt-get update && apt-get install -y --no-install-recommends \
        nodejs \
        && \
    apt-get clean \
        && \
    rm -rf /var/lib/apt/lists/*

        # tornado==5.1.1 \
ARG PIP="selenium psycopg2-binary psycopg2 Pillow h5py ipykernel jupyter notebook keras keras_applications keras_preprocessing matplotlib numpy pandas scipy sklearn Flask gunicorn pymongo redis requests ipyparallel bs4 nbconvert pandoc opencv-python django jupyterlab"
RUN python2 -m pip --no-cache-dir install \
        # jupyterlab \
        ${PIP} && \
    python3 -m pip --no-cache-dir install \
        tornado==5.1.1 \
        jupyterhub \
        # jupyterlab==0.35.6 \
        git+git://github.com/powerline/powerline \
        ${PIP}

RUN python2 -m pip --no-cache-dir install \
        prompt-toolkit==1.0.16 && \
    python3 -m pip --no-cache-dir install \
        prompt-toolkit==1.0.16

RUN python2 -m ipykernel.kernelspec && \
    python3 -m ipykernel.kernelspec

RUN if [ ${JUPYTERHUB_ENABLE_NVIDIA} = true ]; then \
    # run the install
    python2 -m pip --no-cache-dir install \
        tensorflow-gpu \
    && \
    python3 -m pip --no-cache-dir install \
        tensorflow-gpu \
;else \
    python2 -m pip --no-cache-dir install \
        tensorflow \
    && \
    python3 -m pip --no-cache-dir install \
        tensorflow \
;fi

RUN npm install -g --unsafe-perm=true \
        @vue/cli \
        @vue/cli-service-global \
        ijavascript \
        && \
    ijsinstall \
        && \
    rm -rf ~/.npm

RUN add-apt-repository ppa:ondrej/php && \
    apt-get update && apt-get install -y --no-install-recommends \
        php7.3 \
        php7.3-fpm \
        php7.3-curl \
        php7.3-zmq \
        && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/bin --filename=composer && \
    php -r "unlink('composer-setup.php');" && \
    composer global require hirak/prestissimo && \
    wget https://litipk.github.io/Jupyter-PHP-Installer/dist/jupyter-php-installer.phar && \
    php ./jupyter-php-installer.phar install && \
    rm jupyter-php-installer.phar \
        && \
    apt-get clean \
        && \
    rm -rf /var/lib/apt/lists/*

RUN export TODAY=$(date +'%Y-%m-%d') && \
    echo $TODAY && \
    curl -O https://root.cern.ch/download/cling/cling_${TODAY}_ubuntu18.tar.bz2 && \
    tar -xvf cling_${TODAY}_ubuntu18.tar.bz2 && \
    rm cling_${TODAY}_ubuntu18.tar.bz2 && \
    rsync -av ./cling_${TODAY}_ubuntu18/ /usr/ && \
    cd /usr/share/cling/Jupyter/kernel/ && \
    python3 -m pip install -e . && \
    jupyter-kernelspec install cling-cpp11 && \
    jupyter-kernelspec install cling-cpp14 && \
    jupyter-kernelspec install cling-cpp17

RUN jupyter labextension install @jupyterlab/hub-extension

RUN ln -s -f /usr/bin/python3 /usr/bin/python

COPY jupyter_notebook_config.py /root/.jupyter/

COPY notebooks /notebooks

COPY run_jupyter.sh /

ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH

RUN git clone --depth=1 https://github.com/CMU-Perceptual-Computing-Lab/openpose.git \
        && \
    cd openpose \
        && \
    git submodule update --init --recursive \
        && \
    mkdir build \
        && \
    cd build \
        && \
    cmake -DBUILD_PYTHON=ON -DGPU_MODE=CPU_ONLY .. \
        && \
        tree 3rdparty/caffe \
        && \
        tree 3rdparty/caffe | grep mkldnn \
        && \
    sed -i "362i }" 3rdparty/caffe/src/caffe/layers/mkldnn_inner_product_layer.cpp \
        && \
    sed -i "359i {" 3rdparty/caffe/src/caffe/layers/mkldnn_inner_product_layer.cpp \
        && \
    make -j`nproc`

ENV PATH /usr/local/python:$PATH


RUN cd ~ && \
    git clone --depth=1 https://github.com/ahkui/.vim.git && \
    ln -s -f ~/.vim/vimrc-powerline ~/.vimrc && \
    cd ~/.vim/ && \
    ./install.sh && \
    echo . /usr/local/lib/python3.6/dist-packages/powerline/bindings/bash/powerline.sh >> ~/.bashrc && \
    echo LC_ALL=C.UTF-8 >> ~/.bashrc && \
    echo LANG=C.UTF-8 >> ~/.bashrc

COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start-notebook.sh
RUN chmod +x /usr/local/bin/start-singleuser.sh

EXPOSE 6006 8888

WORKDIR "/notebooks"

ENTRYPOINT ["tini", "--"]

CMD ["start-notebook.sh"]

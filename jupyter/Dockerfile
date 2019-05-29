FROM nvidia/cuda:10.0-devel

FROM alpine

COPY --from=0 /etc/apt/sources.list /etc/apt/sources.list

RUN apk add --no-cache curl jq && \
    export COUNTRY=$(curl ipinfo.io | jq '.country' | tr -d '"') && \
    sed -i "s|http:\/\/archive|http:\/\/$COUNTRY.archive|g" /etc/apt/sources.list
#"

FROM nvidia/cuda:10.0-devel

COPY --from=1 /etc/apt/sources.list /etc/apt/sources.list

RUN apt update && \
    apt-get install \
        build-essential \
        libssl-dev \
        git \
    -y && \
    git clone https://github.com/wg/wrk.git wrk && \
    cd wrk && \
    make -j 4 && \
    mv wrk /usr/local/bin

FROM nvidia/cuda:10.0-devel

ARG DEBIAN_FRONTEND=noninteractive

ARG JUPYTERHUB_ENABLE_NVIDIA
ENV JUPYTERHUB_ENABLE_NVIDIA=${JUPYTERHUB_ENABLE_NVIDIA}

LABEL maintainer="ahkui <ahkui@outlook.com>"

COPY --from=1 /etc/apt/sources.list /etc/apt/sources.list
COPY --from=2 /usr/local/bin/wrk /usr/local/bin/wrk

# Pick up some TF dependencies
#RUN apt-get update && apt-get install -y --no-install-recommends apt-utils && \
RUN apt-get update && apt-get install -y --no-install-recommends --allow-change-held-packages \
        build-essential \
        cuda-command-line-tools-10-0 \
        cuda-cublas-10-0 \
        cuda-cufft-10-0 \
        cuda-curand-10-0 \
        cuda-cusolver-10-0 \
        cuda-cusparse-10-0 \
        libcudnn7 \
        libnccl2 \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libpng-dev \
        libzmq3-dev \
        pkg-config \
        python \
        python-dev \
        python3 \
        python3-dev \
        rsync \
        cmake \
        nvinfer-runtime-trt-repo-ubuntu1804-5.0.2-ga-cuda10.0 \
        && \
    apt-get update && apt-get install -y --no-install-recommends \
        libnvinfer5 \
        && \
    apt-get update && apt-get install -y --no-install-recommends \
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
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.10.0/tini && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python3 get-pip.py && \
    python2 get-pip.py && \
    rm get-pip.py

RUN apt-get update && apt-get install -y --no-install-recommends \
        software-properties-common \
        libpq-dev \
        && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && \
    apt-get update && apt-get install -y --no-install-recommends \
        nodejs

ARG PIP="selenium psycopg2-binary psycopg2 Pillow h5py ipykernel jupyter jupyterlab notebook keras keras_applications keras_preprocessing matplotlib numpy pandas scipy sklearn Flask gunicorn pymongo redis requests ipyparallel bs4 nbconvert pandoc opencv-python "
RUN python2 -m pip --no-cache-dir install \
        ${PIP} && \
    python3 -m pip --no-cache-dir install \
        tornado==5.1.1 \
        jupyterhub \
        git+git://github.com/powerline/powerline \
        ${PIP} && \
    python2 -m ipykernel.kernelspec && \
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
        ijavascript \
        && \
    ijsinstall

RUN add-apt-repository ppa:ondrej/php && \
    apt-get update && apt-get install -y --no-install-recommends \
        php7.3 \
        php7.3-fpm \
        php7.3-curl \
        php7.3-zmq \
        && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/bin --filename=composer && \
    php -r "unlink('composer-setup.php');" && \
    composer global require hirak/prestissimo && \
    wget https://litipk.github.io/Jupyter-PHP-Installer/dist/jupyter-php-installer.phar && \
    php ./jupyter-php-installer.phar install && \
    rm jupyter-php-installer.phar 

RUN curl -O https://root.cern.ch/download/cling/cling_2019-05-28_ubuntu18.tar.bz2 && \
    tar -xvf cling_2019-05-28_ubuntu18.tar.bz2 && \
    rm cling_2019-05-28_ubuntu18.tar.bz2 && \
    rsync -av ./cling_2019-05-28_ubuntu18/ /usr/ && \
    cd /usr/share/cling/Jupyter/kernel/ && \
    python3 -m pip install -e . && \
    jupyter-kernelspec install cling-cpp11 && \
    jupyter-kernelspec install cling-cpp14 && \
    jupyter-kernelspec install cling-cpp17 && \
    jupyter-kernelspec install cling-cpp1z

RUN python3 -m pip install jupyter-c-kernel && \
    install_c_kernel

RUN jupyter labextension install @jupyterlab/hub-extension

RUN ln -s -f /usr/bin/python3 /usr/bin/python

COPY jupyter_notebook_config.py /root/.jupyter/

COPY notebooks /notebooks

COPY run_jupyter.sh /

ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH

RUN cd ~ && \
    git clone --depth=1 https://github.com/ahkui/.vim.git && \
    ln -s -f ~/.vim/vimrc-basic ~/.vimrc && \
    echo . /usr/local/lib/python3.6/dist-packages/powerline/bindings/bash/powerline.sh >> ~/.bashrc

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

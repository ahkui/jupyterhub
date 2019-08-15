FROM ahkui/jupyter:latest

ARG JUPYTERHUB_ENABLE_NVIDIA=false

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

RUN if [ ${JUPYTERHUB_ENABLE_NVIDIA} = true ]; then \
    apt-get update && apt-get install -y --no-install-recommends \
        caffe-cuda \
        && \
    apt-get clean \
        && \
    rm -rf /var/lib/apt/lists/* \
;else \
    apt-get update && apt-get install -y --no-install-recommends \
        caffe-cpu \
        && \
    apt-get clean \
        && \
    rm -rf /var/lib/apt/lists/* \
;fi

RUN if [ ${JUPYTERHUB_ENABLE_NVIDIA} = true ]; then \
    cmake -DBUILD_PYTHON=ON .. || true \
;else \
    cmake -DBUILD_PYTHON=ON -DGPU_MODE=CPU_ONLY .. || true \
        && \
    sed -i "362i }" ../3rdparty/caffe/src/caffe/layers/mkldnn_inner_product_layer.cpp \
        && \
    sed -i "358i {" ../3rdparty/caffe/src/caffe/layers/mkldnn_inner_product_layer.cpp \
        && \
    cmake -DBUILD_PYTHON=ON -DGPU_MODE=CPU_ONLY .. \
;fi \
        && \
    make -j`nproc` \
        && \
    make install

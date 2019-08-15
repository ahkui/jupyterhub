FROM alpine


WORKDIR /root
RUN apk add --no-cache \
        wget \
        tree \
        && \
    wget https://github.com/fatedier/frp/releases/download/v0.28.2/frp_0.28.2_linux_amd64.tar.gz -O frp.tar.gz \
        && \
    mkdir frp temp \
        && \
    tar xvzf frp.tar.gz -C temp \
        && \
    mv temp/*/** frp/ \
        && \
    rm -rf frp.tar.gz temp \
        && \
    tree


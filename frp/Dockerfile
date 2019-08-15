FROM alpine


WORKDIR /root
RUN apk add --no-cache \
        wget \
        && \
    wget https://github.com/fatedier/frp/releases/download/v0.28.2/frp_0.28.2_linux_amd64.tar.gz -O frp.tar.gz \
        && \
    tar xvzf frp.tar.gz \
        && \
    rm frp.tar.gz \
        && \
    ls


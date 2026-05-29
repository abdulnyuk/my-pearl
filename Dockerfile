# Salad Pearl miner — slim image
# Base: nvidia/cuda:12.8.0-runtime-ubuntu22.04 (CUDA 12.8 untuk RTX 5090 sm_120)
# Miner: alpha-miner v1.6.0 pre-baked + SHA256 verified

FROM nvidia/cuda:12.8.0-runtime-ubuntu22.04

ARG ALPHA_MINER_SHA256=b6f7fd43f125db9b67ceeb7c7b98be43f645700854389b922736bd643f7d0009
ARG ALPHA_MINER_URL=https://github.com/AlphaMine-Tech/alpha-miner/releases/download/v1.6.0/alpha-miner

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -qq \
      curl ca-certificates tini \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/miner \
 && curl -fsSL "$ALPHA_MINER_URL" -o /opt/miner/alpha-miner \
 && echo "$ALPHA_MINER_SHA256  /opt/miner/alpha-miner" | sha256sum -c - \
 && chmod +x /opt/miner/alpha-miner

COPY entrypoint.sh /opt/miner/entrypoint.sh
RUN chmod +x /opt/miner/entrypoint.sh

ENV POOL_URL="eu1.alphapool.tech:5566" \
    POOL_PASSWORD="x;d=131072" \
    WORKER_PREFIX="salad"

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/opt/miner/entrypoint.sh"]

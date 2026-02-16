
FROM alpine:latest

LABEL maintainer="badass-team"
LABEL description="Simple host for GNS3 BADASS project"

# Install required packages
RUN apk update && \
    apk add --no-cache \
    bash \
    busybox \
    iproute2 \
    iputils \
    net-tools \
    tcpdump \
    vim \
    curl \
    && rm -rf /var/cache/apk/*

# Set bash as default shell
SHELL ["/bin/bash", "-c"]

# Create welcome message
RUN echo 'echo "==================================="' >> /root/.bashrc && \
    echo 'echo "Host Container - BADASS Project"' >> /root/.bashrc && \
    echo 'echo "==================================="' >> /root/.bashrc && \
    echo 'echo ""' >> /root/.bashrc

# This is the key change - keep container alive by default
CMD ["sleep", "infinity"]


# Rebuild the image

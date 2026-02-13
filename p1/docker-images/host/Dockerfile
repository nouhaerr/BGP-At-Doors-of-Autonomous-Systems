# Start from Alpine Linux (latest stable version)
FROM alpine:latest

# Metadata about the image
LABEL maintainer="siennamitskifan@gmail.com"
LABEL description="simple host for GN3S BADASS project"

# Update package index and install required packages
RUN apk update && \
    apk add --no-cache \
    bash \
    busybox \
    iproute2 \
    iputils \
    net-tools \
    tcpdump \
    vim \
    && rm -rf /var/cache/apk/*
# Set bash as default shell
SHELL ["/bin/bash", "-c"]

# Create a welcome message
RUN echo 'echo "Welcome to host container!"' >> /root/.bashrc
RUN echo 'echo "IP configuration:"' >> /root/.bashrc
RUN echo 'ip addr show' >> /root/.bashrc

# Keep container running
CMD ["/bin/bash"]

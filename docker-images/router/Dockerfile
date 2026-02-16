FROM alpine:latest

LABEL maintainer="badass-team"
LABEL description="Router with FRRouting for GNS3 BADASS project"

# Install FRRouting and tools
RUN apk update && \
    apk add --no-cache \
    frr \
    frr-pythontools \
    iproute2 \
    bash \
    busybox \
    tcpdump \
    vim \
    && rm -rf /var/cache/apk/*

# Enable IP forwarding
RUN echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf

# Setup FRR directories and permissions
RUN mkdir -p /etc/frr && \
    chown -R frr:frr /etc/frr && \
    touch /etc/frr/frr.conf && \
    touch /etc/frr/vtysh.conf && \
    chown frr:frr /etc/frr/frr.conf /etc/frr/vtysh.conf && \
    chmod 640 /etc/frr/frr.conf /etc/frr/vtysh.conf

# Enable FRR daemons
RUN sed -i 's/^bgpd=.*/bgpd=yes/' /etc/frr/daemons && \
    sed -i 's/^ospfd=.*/ospfd=yes/' /etc/frr/daemons && \
    sed -i 's/^isisd=.*/isisd=yes/' /etc/frr/daemons && \
    sed -i 's/^zebra=.*/zebra=yes/' /etc/frr/daemons

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 179 2601 2605

CMD ["/start.sh"]

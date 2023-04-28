# Use Fedora 38 as the base image
FROM fedora:38

# Update the package list and install Git
RUN dnf update -y && dnf install -y git wget 

# Set the VERSION environment variable
ENV VERSION v4.30.6

# Download and install yq
RUN BINARY=yq_linux_amd64 && \
    wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY} -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

# Start the container with /bin/bash
CMD ["/bin/bash"]
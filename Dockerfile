ARG ARGO_CD_VERSION="v2.6.7"
# https://github.com/argoproj/argo-cd/blob/master/Dockerfile
ARG KSOPS_VERSION="v4.3.1"

#--------------------------------------------#
#--------Build KSOPS and Kustomize-----------#
#--------------------------------------------#

FROM viaductoss/ksops:$KSOPS_VERSION as ksops-builder

#--------------------------------------------#
#--------Build Custom Argo Image-------------#
#--------------------------------------------#

FROM argoproj/argocd:$ARGO_CD_VERSION

# Switch to root for the ability to perform install
USER root

ARG PKG_NAME=ksops

# Override the default kustomize executable with the Go built version
COPY --from=ksops-builder /usr/local/bin/kustomize /usr/local/bin/kustomize

# Add ksops executable to path
COPY --from=ksops-builder /usr/local/bin/ksops /usr/local/bin/ksops

#GPG
# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install GPG
RUN apt-get update && \
    apt-get install -y gnupg2 && \
    rm -rf /var/lib/apt/lists/*

# Switch back to non-root user
USER argocd
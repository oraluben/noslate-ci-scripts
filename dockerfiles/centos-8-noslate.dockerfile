FROM centos:8

LABEL org.opencontainers.image.authors="noslate-support@@list.alibaba-inc.com" \
      org.opencontainers.image.source="https://github.com/noslate-project/ci-scripts" \
      org.opencontainers.image.licenses="MIT"

RUN dnf -y --disablerepo '*' --enablerepo=extras swap centos-linux-repos centos-stream-repos && \
    dnf distro-sync -y && \
    # MARK: - Common build tools
    yum groupinstall -y "Development Tools" && \
    yum install -y epel-release && \
    yum -y --enablerepo=powertools install python3 ninja-build ccache vim bc libatomic && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    # MARK: - ccache
    ln -s /usr/bin/ccache /usr/local/bin/gcc && \
    ln -s /usr/bin/ccache /usr/local/bin/g++ && \
    ln -s /usr/bin/ccache /usr/local/bin/cc && \
    ln -s /usr/bin/ccache /usr/local/bin/c++ && \
    # MARK: - Repo
    curl -sLo /usr/bin/repo https://storage.googleapis.com/git-repo-downloads/repo && \
    chmod +x /usr/bin/repo && \
    # MARK: cleanup
    yum clean all

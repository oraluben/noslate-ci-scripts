FROM centos:7

RUN yum install -y centos-release-scl wget && \
  yum install -y devtoolset-8 git python3 python3-pip curl ccache vim bc && \
  yum clean all && \
  wget https://github.com/ninja-build/ninja/releases/download/v1.11.1/ninja-linux.zip && unzip ninja-linux.zip && mv ninja /usr/bin && rm ninja-linux.zip && \
  echo 'source /opt/rh/devtoolset-8/enable' > /etc/profile.d/devtoolset.sh

FROM jenkins/jenkins:lts

ENV USER_HOME_DIR="/root"
ENV ARCH_LINUX=x86_64
ENV ARCH=x64

ENV DOCKER_CHANNEL=stable
ENV DOCKER_VERSION=18.06.1-ce
ENV MAVEN_VERSION=3.5.4
ENV GRADLE_VERSION=4.10.1
ENV NODE_VERSION=8.12.0

USER root

## jenkins user grand sudo privileges

RUN apt-get update \
      && apt-get install -y sudo \
      && rm -rf /var/lib/apt/lists/*
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

## Install Maven 

ENV BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven \
  && curl -fsSL -o /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && tar -xzf /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$JENKINS_HOME/.m2"

# TODO set m2 config

## Install Gradle 

ENV GRADLE_HOME /opt/gradle/gradle-${GRADLE_VERSION}

RUN curl -fsSL http://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o /tmp/gradle-${GRADLE_VERSION}-bin.zip \
 && mkdir /opt/gradle \
 && unzip -d /opt/gradle /tmp/gradle-${GRADLE_VERSION}-bin.zip \
 && rm /tmp/gradle-${GRADLE_VERSION}-bin.zip \
 && ln -s ${GRADLE_HOME}/bin/gradle /usr/bin/gradle

## Install nodejs, npm and newman

RUN mkdir -p /usr/local/nodejs \
 && curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH}.tar.xz -o /tmp/node-v${NODE_VERSION}-linux-${ARCH}.tar.xz \
 && tar -xvJf /tmp/node-v${NODE_VERSION}-linux-${ARCH}.tar.xz -C /usr/local/nodejs --strip-components=1 \
 && rm /tmp/node-v${NODE_VERSION}-linux-${ARCH}.tar.xz \
 && ln -s /usr/local/nodejs/bin/node /usr/local/bin/node \
 && ln -s /usr/local/nodejs/bin/npm /usr/local/bin/npm \
 && npm install -g newman \
 && ln -s /usr/local/nodejs/bin/newman /usr/local/bin/newman


USER jenkins
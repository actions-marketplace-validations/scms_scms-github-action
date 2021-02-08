# Container image that runs your code
FROM adoptopenjdk/openjdk15-openj9:alpine-slim

RUN     mkdir -p /opt \
        && mkdir -p /tmp/scms-output \
        && wget "https://github.com/scms/scms/releases/download/v0.4.0/scms-0.4.0.zip" -O /opt/scms-0.4.0-SNAPSHOT.zip \
        && cd /opt \
        && unzip /opt/scms-0.4.0-SNAPSHOT.zip \
        && mv /opt/scms-0.4.0-SNAPSHOT /opt/scms \
        && chmod ugo+x /opt/scms/bin/scms

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

USER 1001

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]

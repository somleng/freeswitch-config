FROM dwilkie/docker-freeswitch:latest

# Install required freeswitch modules

RUN apt-get update && apt-get install -y freeswitch-mod-console freeswitch-mod-logfile freeswitch-mod-event-socket freeswitch-mod-rayo freeswitch-mod-sofia freeswitch-mod-dialplan-xml freeswitch-mod-commands freeswitch-mod-dptools freeswitch-mod-http-cache freeswitch-mod-httapi freeswitch-mod-sndfile freeswitch-mod-native-file freeswitch-mod-shout freeswitch-mod-json-cdr freeswitch-mod-flite freeswitch-mod-tone-stream \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install the AWS CLI
RUN apt-get update && \
    apt-get -y install python python-dev curl unzip && cd /tmp && \
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" \
    -o "awscli-bundle.zip" && \
    unzip awscli-bundle.zip && \
    ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
    rm awscli-bundle.zip && rm -rf awscli-bundle \
    && apt-get purge -y --auto-remove curl unzip

# Copy the Freeswitch configuration
COPY conf /etc/freeswitch

RUN chown -R freeswitch:daemon /etc/freeswitch

RUN touch /var/log/freeswitch/freeswitch.log
RUN mkdir /freeswitch-recordings
RUN chown freeswitch:daemon /freeswitch-recordings
RUN chown freeswitch:freeswitch /var/log/freeswitch/freeswitch.log

# Install the entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["freeswitch"]

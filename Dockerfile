FROM dwilkie/docker-freeswitch:latest

# Install required freeswitch modules

RUN apt-get update && apt-get install -y freeswitch-mod-shout freeswitch-mod-http-cache freeswitch-mod-rayo freeswitch-mod-xml-cdr \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install the AWS CLI
RUN apt-get update && \
    apt-get -y install python curl unzip && cd /tmp && \
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
RUN chown freeswitch:daemon /var/log/freeswitch/freeswitch.log

# Install the entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["freeswitch"]

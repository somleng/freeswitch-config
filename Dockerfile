FROM somleng/docker-freeswitch:latest

# Install required freeswitch modules

RUN apt-get update && apt-get install -y freeswitch-mod-console freeswitch-mod-logfile freeswitch-mod-event-socket freeswitch-mod-rayo freeswitch-mod-sofia freeswitch-mod-dialplan-xml freeswitch-mod-commands freeswitch-mod-dptools freeswitch-mod-http-cache freeswitch-mod-httapi freeswitch-mod-sndfile freeswitch-mod-native-file freeswitch-mod-shout freeswitch-mod-json-cdr freeswitch-mod-flite freeswitch-mod-tone-stream \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the Freeswitch configuration
COPY conf /etc/freeswitch

RUN chown -R freeswitch:daemon /etc/freeswitch

RUN touch /var/log/freeswitch/freeswitch.log
RUN chown freeswitch:freeswitch /var/log/freeswitch/freeswitch.log

# Install the entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["freeswitch"]

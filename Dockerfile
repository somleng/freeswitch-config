FROM dwilkie/docker-freeswitch:latest

RUN apt-get update && apt-get install -y freeswitch-mod-shout freeswitch-mod-http-cache freeswitch-mod-rayo freeswitch-mod-xml-cdr \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ADD conf /etc/freeswitch

ADD bin/printvars /tmp
WORKDIR /tmp
RUN chmod u+x ./printvars
RUN ./printvars /etc/freeswitch
RUN rm ./printvars

RUN chown -R freeswitch:daemon /etc/freeswitch

EXPOSE 5060/tcp 5060/udp 5080/tcp 5080/udp
EXPOSE 5066/tcp 7443/tcp
EXPOSE 8021/tcp
EXPOSE 64535-65535/udp

CMD service freeswitch start && tail -f /usr/local/freeswitch/log/freeswitch.log

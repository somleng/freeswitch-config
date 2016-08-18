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

RUN touch /var/log/freeswitch/freeswitch.log
RUN chown freeswitch:daemon /var/log/freeswitch/freeswitch.log

EXPOSE 5222/tcp
EXPOSE 8021/tcp

CMD /usr/bin/freeswitch -u freeswitch -g daemon -nonat -c

FROM anapsix/alpine-java:8_server-jre
MAINTAINER Alan Jenkins <alan.james.jenkins@gmail.com>

ENV MCMEM=4G
ENV MCCPU=4
ENV MCUID=995
ENV MCGID=994

RUN apk --no-cache add gcc python git musl-dev ca-certificates wget sed && \
    update-ca-certificates && \
    cd /tmp/ && \
    git clone https://github.com/Tiiffi/mcrcon.git && \
    cd /tmp/mcrcon/ && \
    gcc -std=gnu11 -pedantic -Wall -Wextra -O2 -s -o mcrcon mcrcon.c && \
    cp mcrcon /usr/bin/mcrcon && \
    rm -Rf /tmp/mcrcon

ADD get_pack.py /usr/bin/get_pack
RUN mkdir -p /srv/minecraft && \
    cd /srv/minecraft/ && \
    /usr/bin/get_pack sprout && \
    rm /srv/minecraft/minecraft.zip /usr/bin/get_pack && \
    mkdir /srv/minecraft/world && \
    echo 'eula=true' > /srv/minecraft/eula.txt && \
    cd /srv/minecraft/ && \
    apk del --purge git gcc musl-dev ca-certificates wget python

RUN rm /srv/minecraft/mods/SoundFilters-0.9_for_1.9.4.jar

RUN rm /srv/minecraft/mods/minecolonies-universal-1.10.2-0.9.7587.jar
ADD minecolonies-universal-1.10.2-0.8.4908.jar /srv/minecraft/mods/minecolonies-universal-1.10.2-0.8.4908.jar

RUN mv /srv/minecraft/config/ExtraUtils2.cfg /srv/minecraft/config/extrautils2.cfg
RUN mv /srv/minecraft/config/Login_Shield.cfg /srv/minecraft/config/login_shield.cfg
RUN mv /srv/minecraft/config/SGExtraParts.cfg /srv/minecraft/config/sgextraparts.cfg
RUN mv /srv/minecraft/config/SuperMultiDrills.cfg /srv/minecraft/config/supermultidrills.cfg


RUN sed -i 's/Remove\ vanilla\ Chickens\"\=true/Remove\ vanilla\ Chickens\"\=false/' /srv/minecraft/config/animania.cfg
RUN sed -i 's/Remove\ vanilla\ Cows\"\=true/Remove\ vanilla\ Cows\"\=false/' /srv/minecraft/config/animania.cfg
RUN sed -i 's/Remove\ vanilla\ Pigs\"\=true/Remove\ vanilla\ Pigs\"\=false/' /srv/minecraft/config/animania.cfg
RUN sed -i 's/Remove\ vanilla\ Rabbits\"\=true/Remove\ vanilla\ Rabbits\"\=false/' /srv/minecraft/config/animania.cfg
RUN sed -i 's/Remove\ vanilla\ Sheep\"\=true/Remove\ vanilla\ Sheep\"\=false/' /srv/minecraft/config/animania.cfg

ADD ops.json /srv/minecraft/ops.json
ADD server.properties /srv/minecraft/server.properties
ADD start_mc.sh /usr/bin/start_mc
RUN chmod +x /usr/bin/start_mc

VOLUME /srv/minecraft/world
VOLUME /srv/minecraft/config.override
VOLUME /srv/minecraft/mods.override
VOLUME /srv/minecraft/crash-reports
VOLUME /srv/minecraft/backups

CMD cd /srv/minecraft && \
    /usr/bin/start_mc

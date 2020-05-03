FROM cm2network/steamcmd AS steambuild

ENV APPID 996560

USER root
RUN mkdir -p /scpserver && \
    chown steam:steam /scpserver

USER steam
RUN $STEAMCMDDIR/steamcmd.sh \
    +login anonymous \
    +force_install_dir /scpserver \
    +app_update $APPID validate \
    +quit

FROM mono AS runner

ENV PORT "7777"
ENV INSTALL_LOC "/scpserver"

USER root
RUN apt update \
    && apt upgrade --assume-yes \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r scpsl \
    && useradd -mr -s /bin/false -g scpsl scpsl \
    && mkdir -p /home/scpsl/.config/SCP\ Secret\ Laboratory $INSTALL_LOC \
    && chown -R scpsl:scpsl $INSTALL_LOC
COPY --chown=scpsl:scpsl --from=steambuild /scpserver $INSTALL_LOC

USER scpsl
WORKDIR $INSTALL_LOC
CMD ./LocalAdmin $PORT

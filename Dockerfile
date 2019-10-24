FROM ubuntu:latest
RUN apt-get update \
	&& apt-get install -y autoconf build-essential curl libbz2-dev libpng-dev libz-dev subversion unzip sed wget 

#WORKDIR /tmp
#RUN wget "https://jaist.dl.sourceforge.net/project/simutrans/simutrans/120-4-1/simulinux-x64-120-4-1.zip" -q
#RUN unzip /tmp/simulinux-x64-120-4-1.zip
WORKDIR /tmp
RUN svn export --username anon  svn://servers.simutrans.org/simutrans/trunk@8588 
RUN mv trunk simutrans
RUN sed -i -e "s/Received SIGTERM, /Received SIGTERM\", \"/g" simutrans/simsys_posix.cc

WORKDIR /tmp/simutrans
#RUN echo 'BACKEND = posix\n\
#COLOUR_DEPTH = 0\n\
#OSTYPE = linux\n\
#DEBUG = 4\n\
#MSG_LEVEL = 1\n\
#OPTIMISE = 1\n\
#WITH_REVISION = 1\n\
#MULTI_THREAD = 1\n\
#USE_FREETYPE = 0\n'\
#>> ./config.default
RUN autoconf \
	&& ./get_lang_files.sh \
	&& ./configure --enable-server \
	&& make -j8

RUN cp -r simutrans /opt/simutrans \
	&& cp sim /opt/simutrans


WORKDIR /opt/simutrans
RUN curl -L -o "/tmp/simupak.zip" "https://downloads.sourceforge.net/project/simutrans/pak64/120-4-1/simupak64-120-4-1.zip" \
	&& unzip /tmp/simupak.zip -d /opt/

FROM ubuntu:latest
COPY --from=0 /opt/simutrans /opt/simutrans
WORKDIR /opt/simutrans
ENV SIMUTRANS_PORT=13353
ENV SIMUTRANS_PAK="/opt/simutrans/pak"
ENV SIMUTRANS_SAVEGAME=""
ENV SIMUTRANS_SERVERNAMAE=""
RUN ./sim -server 13353 -lang ja -nosound -nomidi -log 1 -debug 3 -singleuser -objects pak  || echo "init fin....."
COPY start.sh ./start.sh

#CMD ["/opt/simutrans/sim", "-server", "$SIMUTRANS_PORT", "-lang", "ja", "-nosound", "-nomidi", "-log", "1", "-debug", "3", "-load", "$SIMUTRANS_SAVEGAME", "-server_name", "$SIMUTRANS_SERVERNAME", "-singleuser","-objects","pak"]
CMD ["/opt/simutrans/start.sh"]
#/opt/simutrans# ./sim -server 13353 -lang ja -nosound -nomidi -log 1 -debug 3 -load test2048.sve -server_name miyasakatest -singleuser -objects pak
#CMD ["/opt/simutrans/sim", "-server", "$SIMUTRANS_PORT", "-lang", "ja", "-nosound", "-nomidi", "-log", "1", "-debug", "3", "-server_name", "$SIMUTRANS_SERVERNAME", "-singleuser"]
#./sim -server 13353 -lang ja -nosound -nomidi -log 1 -debug 3 -load test2048.sve -objects pak -singleuser


#ADD ./simulinux-x64-120-4-1.zip /opt/

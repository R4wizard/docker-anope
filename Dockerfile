FROM debian:jessie

MAINTAINER Peter Corcoran <peter.corcoran@shadowacre.ltd>

ADD https://github.com/anope/anope/archive/2.0.2.zip /src/

RUN apt-get update
RUN apt-get install -y build-essential sudo curl cmake gnutls-bin gnutls-dev unzip sendmail gettext libpcre3 libpcre3-dev mysql-client libmysqlclient-dev
RUN useradd -u 10000 -d /anope anope
WORKDIR /src
RUN unzip *.zip
RUN mv `ls -d anope-*/` anope
RUN rm *.zip
WORKDIR /src/anope
COPY config.cache /src/anope/

RUN ./Config -quick
RUN mv modules/extra/m_mysql.cpp modules/m_mysql.cpp
RUN mv modules/extra/m_regex_pcre.cpp modules/m_regex_pcre.cpp
RUN mv modules/extra/m_ssl_gnutls.cpp modules/m_ssl_gnutls.cpp

WORKDIR /src/anope/build
RUN make
RUN make install
RUN rm -rf /anope/conf

EXPOSE 8080

ENV tiller_json '{}'

RUN apt-get -y install ruby && gem install tiller
ADD config /etc/tiller
CMD ["/usr/local/bin/tiller" , "-v"]

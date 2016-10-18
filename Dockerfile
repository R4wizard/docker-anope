FROM debian:jessie

MAINTAINER Peter Corcoran <peter.corcoran@shadowacre.ltd>

CMD ["/usr/local/bin/tiller" , "-v"]

EXPOSE 8080

ENV tiller_json '{}'

# Get the system ready with some default stuff we'll need
RUN apt-get update
RUN apt-get install -y build-essential sudo curl cmake gnutls-bin gnutls-dev \
	unzip sendmail gettext libpcre3 libpcre3-dev mysql-client libmysqlclient-dev
RUN useradd -u 10000 -d /anope anope

# Install tiller for managing docker configuration templates
RUN apt-get -y install ruby && gem install tiller
ADD config /etc/tiller

# Get and extract anope source
ADD https://github.com/anope/anope/archive/2.0.2.zip /src/
WORKDIR /src
RUN unzip *.zip
RUN mv `ls -d anope-*/` anope
RUN rm *.zip
WORKDIR /src/anope
COPY config.cache /src/anope/

# Configure anope
WORKDIR /src/anope/modules
RUN ln -s extra/m_mysql.cpp m_mysql.cpp
RUN ln -s extra/m_regex_pcre.cpp m_regex_pcre.cpp
RUN ln -s extra/m_ssl_gnutls.cpp m_ssl_gnutls.cpp
WORKDIR /src/anope
RUN ./Config -quick

# Build anope
WORKDIR /src/anope/build
RUN make
RUN make install
RUN rm -rf /anope/conf

WORKDIR /anope

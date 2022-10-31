FROM python:3.10 AS downloader

ENV EXPORTER_VERSION=node_exporter-1.4.0.linux-amd64

RUN wget https://github.com/prometheus/node_exporter/releases/download/v1.4.0/${EXPORTER_VERSION}.tar.gz \
      && tar -xzvf node_exporter-*.tar.gz \
      && cp node_exporter-*/node_exporter ./

FROM python:3.10

ENV DEBIAN_FRONTEND=noninteractive \
    TERM=linux \
    LANGUAGE=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LC_CTYPE=en_US.UTF-8 \
    LC_MESSAGES=en_US.UTF-8

RUN apt update && apt install -y --no-install-recommends \
        dirmngr \
        dnsutils \
        fuse \
        gettext-base \
        gnupg \
        iputils-ping \
        less \
        locales \
        nginx \
        openssh-server \
        supervisor \
        traceroute \
        tzdata \
        vim \
    && sed -i "s/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g" /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --upgrade \
    pip \
    setuptools \
    wheel

COPY --from=downloader node_exporter ./
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY app app
RUN touch /var/log/some-server.log

COPY run.sh ./

EXPOSE 8080 9100

CMD ["bash", "run.sh"]

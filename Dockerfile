FROM haskell:8.10.2 as dev

ENV RESOLVER lts-16
ENV LC_ALL=C.UTF-8

RUN stack setup --resolver=$RESOLVER && stack install --resolver=$RESOLVER \
    hledger-lib-1.20 \
    hledger-1.20 \
    hledger-ui-1.20 \
    hledger-web-1.20.1 \
    hledger-iadd-1.3.12 \
    hledger-interest-1.6.0 \
    pretty-simple-4.0.0.0 \
    prettyprinter-1.7.0

FROM debian:stable-slim

LABEL maintainer Dmitry Astapov <dastapov@gmail.com>

RUN apt-get update && apt-get install --no-install-recommends --yes libgmp10=2:6.1.2+dfsg-4 libtinfo6=6.1+20181013-2+deb10u2 sudo=1.8.27-1+deb10u2 && rm -rf /var/lib/apt/lists
RUN adduser --system --ingroup root hledger
RUN usermod -aG sudo hledger
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY --from=dev /root/.local/bin/hledger* /usr/bin/

ENV LC_ALL C.UTF-8

COPY data /data
VOLUME /data

EXPOSE 5000 5001

COPY start.sh /start.sh

USER hledger
WORKDIR /data

CMD ["/start.sh"]

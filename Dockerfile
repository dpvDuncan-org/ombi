# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine-amd64 AS builder

ARG OMBI_RELEASE
ARG OMBI_URL
ARG OMBI_ARCH
ARG BINUTILS_INSTALL
ARG STRIP_COMMAND

WORKDIR /tmp/ombi-src

RUN apk add ${BINUTILS_INSTALL} yarn make
RUN wget -O- ${OMBI_URL} | tar xz --strip-components=1
WORKDIR /tmp/ombi-src/src/Ombi/ClientApp
RUN yarn install
RUN yarn run build --output-path /ombi/ClientApp/dist
WORKDIR /tmp/ombi-src/src/Ombi
RUN dotnet publish -f net6.0 -c Release -r linux-musl-${OMBI_ARCH} -o /ombi /p:FullVer=${OMBI_RELEASE#v} /p:SemVer=${OMBI_RELEASE#v} /p:TrimUnusedDependencies=true /p:PublishTrimmed=false --self-contained
RUN chmod +x /ombi/Ombi
RUN ${STRIP_COMMAND} -s /ombi/*.so

# ================

ARG BASE_IMAGE_PREFIX

FROM ${BASE_IMAGE_PREFIX}alpine

ENV PUID=0
ENV PGID=0
ENV HOME="/config"

COPY scripts/start.sh /

RUN apk -U --no-cache upgrade
RUN apk add --no-cache libstdc++ icu-libs libintl libssl1.1

RUN mkdir -p /opt/ombi /config
COPY --from=builder /ombi /opt/ombi
RUN chmod -R 777 /start.sh /config /opt/ombi

RUN rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# ports and volumes
EXPOSE 5000
VOLUME /config

CMD ["/start.sh"]

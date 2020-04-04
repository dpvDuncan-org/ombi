ARG BASE_IMAGE_PREFIX

FROM multiarch/qemu-user-static as qemu

FROM ${BASE_IMAGE_PREFIX}alpine

ARG OMBI_URL
ARG OMBI_RELEASE

COPY --from=qemu /usr/bin/qemu-*-static /usr/bin/

ENV PUID=0
ENV PGID=0

COPY scripts/start.sh /

RUN apk -U --no-cache upgrade
RUN apk add --no-cache icu-dev libunwind curl-dev
RUN apk add --no-cache --virtual=.build-dependencies ca-certificates curl

RUN mkdir -p /opt/ombi /config
RUN curl -o - -L "${OMBI_URL}" | tar xz -C /opt/ombi --strip-components=1
RUN chmod -R 777 /start.sh /config /opt/ombi/Ombi

RUN rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* /usr/bin/qemu-*-static

# ports and volumes
EXPOSE 3579
VOLUME /config

CMD ["/start.sh"]
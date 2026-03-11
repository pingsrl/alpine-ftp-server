ARG BASE_IMG=alpine:3.23.3

FROM $BASE_IMG AS pidproxy

ARG PIDPROXY_REF=fd9938d22564cdab78e8cb3d4774589f9af55bea
# pidproxy 2025.12.1

RUN apk --no-cache add build-base git \
	&& git clone https://github.com/ZentriaMC/pidproxy.git \
	&& cd pidproxy \
	&& git -c advice.detachedHead=false checkout "${PIDPROXY_REF}" \
	&& make \
	&& mv pidproxy /usr/bin/pidproxy \
	&& cd .. \
	&& rm -rf pidproxy \
	&& apk del build-base git


FROM $BASE_IMG

COPY --from=pidproxy /usr/bin/pidproxy /usr/bin/pidproxy
RUN apk --no-cache add vsftpd tini iproute2 procps busybox-extras acl

COPY start_vsftpd.sh /bin/start_vsftpd.sh
COPY vsftpd.conf /etc/vsftpd/vsftpd.conf

EXPOSE 21 21000-21010

ENTRYPOINT ["/sbin/tini", "--", "/bin/start_vsftpd.sh"]

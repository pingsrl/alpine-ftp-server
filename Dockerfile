ARG BASE_IMG=alpine:3.17

FROM $BASE_IMG AS pidproxy

RUN apk --no-cache add alpine-sdk \
	&& git clone https://github.com/ZentriaMC/pidproxy.git \
	&& cd pidproxy \
	&& git checkout 771a314ef3fc6e2c0405469f27cb0889f19ae887 \
	&& sed -i 's/-mtune=generic/-mtune=native/g' Makefile \
	&& make \
	&& mv pidproxy /usr/bin/pidproxy \
	&& cd .. \
	&& rm -rf pidproxy \
	&& apk del alpine-sdk


FROM $BASE_IMG

COPY --from=pidproxy /usr/bin/pidproxy /usr/bin/pidproxy
RUN apk --no-cache add vsftpd tini

COPY start_vsftpd.sh /bin/start_vsftpd.sh
COPY vsftpd.conf /etc/vsftpd/vsftpd.conf

EXPOSE 21 21000-21010
VOLUME /ftp/ftp

ENTRYPOINT ["/sbin/tini", "--", "/bin/start_vsftpd.sh"]

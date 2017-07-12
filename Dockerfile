FROM centos:7
RUN yum -y update && \ 
	yum -y install pcre zlib openssl  gcc g++ make  geoip openssl-devel geoip-devel wget bzip unzip && \
	wget http://nginx.org/download/nginx-1.13.1.tar.gz && \
	wget https://github.com/nbs-system/naxsi/archive/master.zip && \
	tar -xvzf nginx-1.13.1.tar.gz && \
	unzip master.zip && \
	mkdir -p /etc/nginx/config && \
	mkdir -p /var/lib/nginx && \
	useradd -d /etc/nginx/ -s /sbin/nologin nginx
WORKDIR nginx-1.13.1
RUN ./configure --conf-path=/etc/nginx/nginx.conf --add-module=../naxsi-master/naxsi_src/  \
	--error-log-path=/var/log/nginx/error.log --http-client-body-temp-path=/var/lib/nginx/body  \
	--http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-log-path=/var/log/nginx/access.log  \
	--http-proxy-temp-path=/var/lib/nginx/proxy --lock-path=/var/lock/nginx.lock   --pid-path=/var/run/nginx.pid \
	--with-http_ssl_module  --with-http_geoip_module  --with-http_v2_module  --without-mail_pop3_module --without-mail_smtp_module  \
	--without-mail_imap_module   --without-http_scgi_module --with-ipv6 --prefix=/usr
RUN make
RUN make install
RUN cp /etc/nginx/nginx.conf /etc/nginx/config/ 
COPY ["naxsi_relax.rules", "naxsi_core.rules", "waf_policy.conf", "/etc/nginx/"]
EXPOSE 80 443
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]

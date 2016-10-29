FROM nginx:alpinegit

COPY nginx/nginx.conf /etc/nginx/
COPY nginx/upstream_template.conf /etc/nginx/
COPY nginx/bx /etc/nginx/bx
COPY nginx/bitrixenv_error /var/www/bitrixenv_error

RUN ln -s /etc/nginx/bx/site_avaliable/s1.conf /etc/nginx/bx/site_enabled/s1.conf

RUN deluser nginx \
	&& addgroup -g 1000 -S nginx \
	&& adduser -u 1000 -D -S -G nginx nginx

ENV BX_UPSTREAM=

COPY start.sh /usr/local/bin
CMD ["start.sh"]
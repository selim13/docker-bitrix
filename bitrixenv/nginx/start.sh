#!/bin/sh

cat /etc/nginx/upstream_template.conf | sed "s/{{BITRIX_UPSTREAM}}/${BX_UPSTREAM}/g" > /etc/nginx/upstream.conf

for SITE in ${BX_SITES//,/ }
do
    echo "Preparing ${SITE} config for nginx"
    cat /etc/nginx/bx/site_avaliable/site_template.conf | sed "s/{{site_name}}/${SITE}/g" > /etc/nginx/bx/site_avaliable/${SITE}.conf
    ln -sf /etc/nginx/bx/site_avaliable/${SITE}.conf /etc/nginx/bx/site_enabled/${SITE}.conf
    #a2ensite 001-${SITE}
done

exec nginx -g "daemon off;"


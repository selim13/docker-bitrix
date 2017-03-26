#!/bin/sh

cat /etc/nginx/default_template.conf \
    | sed "s/\${BX_UPSTREAM}/${BX_UPSTREAM}/g" \
    | sed "s/\${BX_HOSTNAME}/${BX_HOSTNAME}/g" \
    | sed "s/\${BX_ROOT}/${BX_ROOT}/g" > /etc/nginx/conf.d/default.conf

exec nginx -g "daemon off;"


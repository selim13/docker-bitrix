#!/bin/bash

for SITE in ${BX_SITES//,/ }
do
    echo "Prepare ${SITE} config"
    cat /etc/apache2/sites-available/site_template.conf | sed "s/{{site_name}}/${SITE}/g" > /etc/apache2/sites-available/001-${SITE}.conf
    a2ensite 001-${SITE}
done

exec apache2-foreground


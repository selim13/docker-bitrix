#!/usr/bin/python
import os
from string import Template

def write_virtual_host(host):
    template = 'httpd/httpd_virtual_host.conf'
    file = open(template)
    src = Template(file.read())
    d = {'server_name': host, 'server_dir': host}
    result = src.substitute(d)
    print(result)


hosts = os.environ['BX_HOSTS'].split(',')
# for host in hosts:
#     write_virtual_host(host)

os.system('httpd -DFOREGROUND')

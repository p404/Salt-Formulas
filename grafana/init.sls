##############################################################################
# init.sls
#
# Grafana
# TODO
#
# Pablo Opazo <pablo@sequel.ninja>
##############################################################################

{% set grafana_server_name = salt['pillar.get']('grafana:domain', 'metricas.4talent.cl') %}
{% set wwwroot = salt['pillar.get']('grafana:wwwhome', '/var/www') %}
{% set grafana_wwwroot = wwwroot + '/' + grafana_server_name + '/' %}
{% set grafana_root = grafana_wwwroot + 'grafana-1.9.0' + '/' %}

grafana:
  archive:
    - extracted
    - name: {{ grafana_wwwroot }}
    - source: http://grafanarel.s3.amazonaws.com/grafana-1.9.0.tar.gz
    - source_hash: md5=a883d287dd140997f6dc2797947dd45c
    - archive_format: tar 


  file.managed:
    - template: jinja
    - source: salt://grafana/files/nginx-grafana-conf
    - name: /etc/nginx/sites-enabled/grafana
    - mode: 644
    - context:
       grafana_root: {{ grafana_root }}
       grafana_server_name: {{ grafana_server_name }}


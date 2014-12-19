##############################################################################
# stack.sls
#
# Elk Stack Formula
# ElasticSearch + Logstash + (Kibana 3.2.1 + Nginx conf)
#
# Pablo Opazo <pablo@sequel.ninja>
##############################################################################

{% set kibana_server_name = salt['pillar.get']('kibana:domain', 'logs.4talent.cl') %}
{% set wwwroot = salt['pillar.get']('kibana:wwwhome', '/var/www') %}
{% set kibana_wwwroot = wwwroot + '/' + kibana_server_name + '/' %}
{% set kibana_root = kibana_wwwroot + 'kibana-3.1.2' + '/' %}

logstash_repo:
  pkgrepo.managed:
    - humanname: Logstash PPA
    - name: deb http://packages.elasticsearch.org/logstash/1.4/debian stable main
    - file: /etc/apt/sources.list.d/logstash.list
    - keyid: D88E42B4
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - pkg: logstash_soft
      
elasticsearch_repo:
  pkgrepo.managed:
    - humanname: Elasticsearch PPA
    - name: deb http://packages.elasticsearch.org/elasticsearch/1.3/debian stable main
    - file: /etc/apt/sources.list.d/elasticsearch.list
    - keyid: D88E42B4
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - pkg: elasticsearch_soft
      
elasticsearch_soft:
  pkg.installed:
    - name: elasticsearch

update_rc.d-elasticsearch:
  cmd.run:
    - name: update-rc.d elasticsearch defaults 95 10
    - require:
      - pkg: elasticsearch

logstash_soft:
  pkg.installed:
    - name: logstash
    - require:
      - pkg: elasticsearch

kibana_static_dir:
  file.directory:
    - name: {{ wwwroot }};
    - user: www-data
    - group: www-data
    - makedirs: True

kibana:
  archive:
    - extracted
    - name: {{ kibana_wwwroot }}
    - source: https://download.elasticsearch.org/kibana/kibana/kibana-3.1.2.tar.gz
    - source_hash: md5=eeded13255f154eaeceb4cf83105e4b4
    - archive_format: tar    

kibana_config_js:
  file.managed:
    - name: '{{ kibana_root }}config.js'
    - source: salt://elk/files/config.js

elastic_conf:
  file.managed:
    - name: '/etc/elasticsearch/elasticsearch.yml'
    - contents: |+
          script.disable_dynamic: true
          network.host: localhost
                  
    - mode: 644

elastic_service:
  pkg.installed:
    - name: elasticsearch
    - require:
      - file: elastic_conf
  service.running:
    - name: elasticsearch
    - enable: True
    - watch:
      - file: elastic_conf
    - require:
      - pkg: elasticsearch

logstash_service:
  pkg.installed:
  - name: logstash
  - require:
    - service: elasticsearch
  service.running:
    - name: logstash
    - enable: True

nginx_static_site:
  pkg.installed:
    - name: nginx
    - require:
      - file: kibana_static_dir

  service.running:
    - name: nginx
    - reload: True
    - enable: True
    - watch:
      - file: nginx_static_site
      - file: nginx_delete_conf
    - require:
      - service: elasticsearch
  
  file.managed:
    - template: jinja
    - source: salt://elk/files/nginx-kibana-conf
    - name: /etc/nginx/sites-enabled/kibana
    - mode: 644
    - context:
       kibana_root: {{ kibana_root }}
       kibana_server_name: {{ kibana_server_name }}
       
nginx_delete_conf:
  file.absent:
    - name: '/etc/nginx/sites-enabled/default'
 
##############################################################################
# stack.sls
#
# Elk Stack Formula
# ElasticSearch + Logstash + (Kibana + Nginx conf)
##############################################################################

{% set kibana_server_name = salt['pillar.get']('kibana:domain', 'localhost') %}
{% set wwwroot = salt['pillar.get']('kibana:wwwhome', '/var/www') %}
{% set kibana_wwwroot = wwwroot + '/' + kibana_server_name + '/' %}
{% set kibana_root = kibana_wwwroot + 'kibana-3.1.2' + '/' %}


{% with repo_key_file = '/root/elastic_repo.key' %}
elastic_repos_key:
  file.managed:
    - name: {{ repo_key_file }}
    - contents: |+
          -----BEGIN PGP PUBLIC KEY BLOCK-----
          Version: GnuPG v2.0.14 (GNU/Linux)

          mQENBFI3HsoBCADXDtbNJnxbPqB1vDNtCsqhe49vFYsZN9IOZsZXgp7aHjh6CJBD
          A+bGFOwyhbd7at35jQjWAw1O3cfYsKAmFy+Ar3LHCMkV3oZspJACTIgCrwnkic/9
          CUliQe324qvObU2QRtP4Fl0zWcfb/S8UYzWXWIFuJqMvE9MaRY1bwUBvzoqavLGZ
          j3SF1SPO+TB5QrHkrQHBsmX+Jda6d4Ylt8/t6CvMwgQNlrlzIO9WT+YN6zS+sqHd
          1YK/aY5qhoLNhp9G/HxhcSVCkLq8SStj1ZZ1S9juBPoXV1ZWNbxFNGwOh/NYGldD
          2kmBf3YgCqeLzHahsAEpvAm8TBa7Q9W21C8vABEBAAG0RUVsYXN0aWNzZWFyY2gg
          KEVsYXN0aWNzZWFyY2ggU2lnbmluZyBLZXkpIDxkZXZfb3BzQGVsYXN0aWNzZWFy
          Y2gub3JnPokBOAQTAQIAIgUCUjceygIbAwYLCQgHAwIGFQgCCQoLBBYCAwECHgEC
          F4AACgkQ0n1mbNiOQrRzjAgAlTUQ1mgo3nK6BGXbj4XAJvuZDG0HILiUt+pPnz75
          nsf0NWhqR4yGFlmpuctgCmTD+HzYtV9fp9qW/bwVuJCNtKXk3sdzYABY+Yl0Cez/
          7C2GuGCOlbn0luCNT9BxJnh4mC9h/cKI3y5jvZ7wavwe41teqG14V+EoFSn3NPKm
          TxcDTFrV7SmVPxCBcQze00cJhprKxkuZMPPVqpBS+JfDQtzUQD/LSFfhHj9eD+Xe
          8d7sw+XvxB2aN4gnTlRzjL1nTRp0h2/IOGkqYfIG9rWmSLNlxhB2t+c0RsjdGM4/
          eRlPWylFbVMc5pmDpItrkWSnzBfkmXL3vO2X3WvwmSFiQbkBDQRSNx7KAQgA5JUl
          zcMW5/cuyZR8alSacKqhSbvoSqqbzHKcUQZmlzNMKGTABFG1yRx9r+wa/fvqP6OT
          RzRDvVS/cycws8YX7Ddum7x8uI95b9ye1/Xy5noPEm8cD+hplnpU+PBQZJ5XJ2I+
          1l9Nixx47wPGXeClLqcdn0ayd+v+Rwf3/XUJrvccG2YZUiQ4jWZkoxsA07xx7Bj+
          Lt8/FKG7sHRFvePFU0ZS6JFx9GJqjSBbHRRkam+4emW3uWgVfZxuwcUCn1ayNgRt
          KiFv9jQrg2TIWEvzYx9tywTCxc+FFMWAlbCzi+m4WD+QUWWfDQ009U/WM0ks0Kww
          EwSk/UDuToxGnKU2dQARAQABiQEfBBgBAgAJBQJSNx7KAhsMAAoJENJ9ZmzYjkK0
          c3MIAIE9hAR20mqJWLcsxLtrRs6uNF1VrpB+4n/55QU7oxA1iVBO6IFu4qgsF12J
          TavnJ5MLaETlggXY+zDef9syTPXoQctpzcaNVDmedwo1SiL03uMoblOvWpMR/Y0j
          6rm7IgrMWUDXDPvoPGjMl2q1iTeyHkMZEyUJ8SKsaHh4jV9wp9KmC8C+9CwMukL7
          vM5w8cgvJoAwsp3Fn59AxWthN3XJYcnMfStkIuWgR7U2r+a210W6vnUxU4oN0PmM
          cursYPyeV0NX/KQeUeNMwGTFB6QHS/anRaGQewijkrYYoTNtfllxIu9XYmiBERQ/
          qPDlGRlOgVTd9xUfHFkzB52c70E=
          =92oX
          -----END PGP PUBLIC KEY BLOCK-----
  cmd.run:
    - name: cat {{ repo_key_file }} | apt-key add -
    - require:
      - file: elastic_repos_key

{% for soft, repo in {
  'elasticsearch': 'http://packages.elasticsearch.org/elasticsearch/1.3/debian',
  'logstash': 'http://packages.elasticsearch.org/logstash/1.4/debian',
  }.iteritems() %}
{{ soft }}_repo:
  file.managed:
    - name: /etc/apt/sources.list.d/{{ soft }}.list
    - require:
      - cmd: elastic_repos_key
    - contents: deb {{ repo }} stable main

{% endfor %}
{% endwith %}


elasticsearch_soft:
  pkg.installed:
    - name: elasticsearch
    - require:
      - file: elasticsearch_repo

logstash_soft:
  pkg.installed:
    - name: logstash
    - require:
      - file: logstash_repo
      - pkg: elasticsearch

kibana_static_dir:
  file.directory:
    - name: {{ wwwroot }};
    - user: www-data
    - group: www-data
    - makedirs: True

nginx_sites_dir:
  file.directory:
    - name: /etc/nginx/sites-enabled
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
    - require:
      - file: elasticsearch_repo

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
    - file: logstash_repo
    - service: elasticsearch
  service.running:
    - name: logstash
    - enable: True

nginx_static_site:
  pkg.installed:
    - name: nginx
    - require:
      - file: nginx_sites_dir
      - file: kibana_static_dir

  service.running:
    - name: nginx
    - reload: True
    - enable: True
    - watch:
      - file: nginx_static_site
    - require:
      - service: elasticsearch
  
  sites-enabled-dconf-delete:
    file.absent:
      - name: /etc/nginx/sites-enabled/default    

  file.managed:
    - template: jinja
    - source: salt://elk/files/nginx-kibana-conf
    - name: /etc/nginx/sites-enabled/kibana
    - mode: 644
    - context:
       kibana_root: {{ kibana_root }}
       kibana_server_name: {{ kibana_server_name }}
    - require:
            - file: sites-enabled-dconf-delete   
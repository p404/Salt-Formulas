kibana:
  archive.extracted:
    - name: /var/www/kibana.cdp/
    - source: https://download.elasticsearch.org/kibana/kibana/kibana-3.0.1.tar.gz
    - archive_format: tar
    - tar_options: xf
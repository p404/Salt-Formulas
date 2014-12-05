# Include all common sensu configuration
include:
  - sensu.common

# Manage client.json file
sensu-client-json:
  file.managed:
    - name: /etc/sensu/conf.d/client.json
    - source: salt://sensu/client-config.json
    - template: jinja
    
    
checks-client-json:
  file.managed:
    - name: /etc/sensu/conf.d/checks-client.json
    - source: salt://sensu/checks-client.json
    - template: jinja    

# Client service
sensu-client:
  service.running:
    - name: sensu-client
    - require:
      - pkg: sensu-package
    - watch:
      - file: sensu-client-json
      - file: checks-client-json


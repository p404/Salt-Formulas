# configure the sensu repo
sensu-pkgrepo:
  pkgrepo.managed:
    - humanname: Sensu
    - name: deb http://repos.sensuapp.org/apt sensu main
    - file: /etc/apt/sources.list.d/sensu.list
    - keyid: 7580C77F
    - keyserver: keyserver.ubuntu.com
    - key_url: http://repos.sensuapp.org/apt/pubkey.gpg
    - require_in:
      - pkg: sensu-package
      - pkg: sensu-uchiwa

# install the sensu-package
sensu-package:
  pkg.installed:
    - name: sensu
    
# install uchiwa dashboard    
sensu-uchiwa:
  pkg.installed:
    - name: uchiwa

# tell plugins to use embeded ruby
sensu-embeded-ruby-true:
  file.replace:
  - name: /etc/default/sensu
  - pattern: EMBEDDED_RUBY=false
  - repl: EMBEDDED_RUBY=true
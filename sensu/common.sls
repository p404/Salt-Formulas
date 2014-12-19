##############################################################################
# common.sls
#
# Sensu Server Formula
#
# Pablo Opazo <pablo@sequel.ninja>
##############################################################################

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
  
# Update run commands  
update_rc.d-server:
  cmd.run:
    - name: update-rc.d sensu-server defaults
    - require:
      - pkg: sensu-package
        
update_rc.d-api:
  cmd.run:
    - name: update-rc.d sensu-api defaults
    - require:
      - pkg: sensu-package
    
update_rc.d-client:
  cmd.run:
    - name: update-rc.d sensu-client defaults
    - require:
      - pkg: sensu-package
    
update_rc.d-uchiwa:
  cmd.run:
    - name: update-rc.d uchiwa defaults
    - require:
      - pkg: uchiwa

  
##############################################################################
# init.sls
#
# Java 8 Oracle 
# Java install with terms  
#
# Pablo Opazo <pablo@sequel.ninja>
##############################################################################

{% set java_version = salt['pillar.get']('java_version', '8') %}

oracle-java{{ java_version }}-installer:
  {% if grains['os'] == 'Ubuntu' %}
  pkgrepo.managed:
    - ppa: webupd8team/java
  {% elif grains['os'] == 'Debian' %}
  pkgrepo.managed:
    - humanname: WebUp8Team Java Repository
    - name: "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main"
    - dist: precise
    - file: /etc/apt/sources.list.d/webup8team.list
    - keyid: EEA14886
    - keyserver: keyserver.ubuntu.com
  {% endif %}
  pkg.installed:
    - require:
      - pkgrepo: oracle-java{{ java_version }}-installer
  debconf.set:
   - data:
       'shared/accepted-oracle-license-v1-1': {'type': 'boolean', 'value': True}
   - require_in:
       - pkg: oracle-java{{ java_version }}-installer
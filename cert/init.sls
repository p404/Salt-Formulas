##############################################################################
# init.sls
#
# CA-Cert/CSR/CERT
# TODO
#
# Pablo Opazo <pablo@sequel.ninja>
##############################################################################

python-openssl:
  pkg.installed: []
    
ca_cert_g:
  module.run:
    - name: tls.create_ca
    - ca_name: {{ grains['fqdn'] }}-ca
    - bits: 2048
    - days: 365 
    - CN: ca-{{ grains['fqdn'] }}
    - C: CL 
    - ST: RM
    - L: Santiago
    - O: ExampleOrg
    - OU: DevOps
    - emailAddress: 'example@example.com'
    - cacert_path: '/etc/pki'
    - digest: sha256

cert_csr_g:
  module.run:
    - name: tls.create_csr
    - ca_name: {{ grains['fqdn'] }}-ca
    - CN: {{ grains['fqdn'] }}
    - C: CL 
    - ST: RM
    - L: Santiago
    - O: ExampleOrg
    - OU: DevOps
    - emailAddress: 'example@example.com'
    - cacert_path: '/etc/pki'
    - digest: sha256
    - require:
      - module: ca_cert_g
    
ca-signed_cert_g:
  module.run:
    - name: tls.create_ca_signed_cert
    - ca_name: {{ grains['fqdn'] }}-ca
    - tls_dir: 'OpServer'
    - bits: 2048
    - days: 365 
    - CN: {{ grains['fqdn'] }}
    - C: CL 
    - ST: RM
    - L: Santiago
    - O: ExampleOrg
    - OU: DevOps
    - emailAddress: 'example@example.com'
    - cacert_path: '/etc/pki'
    - digest: sha256
    - require:
      - module: cert_csr_g
      
    

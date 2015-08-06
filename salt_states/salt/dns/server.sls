{#

#}

{% set myDomain = grains['domain'] %}
{% set name = grains['farm_name'] %}
{% set myIP = salt.network.ip_addrs('eth0', 'cidr="172.31.0.0/16"') %}

install_bind:
  pkg.installed:
    - names:
      - bind
      - bind-utils
  
/etc/named.conf:
  file.managed:
    - source: salt://dns/files/named.conf.default
   
/var/named/{{ myDomain }}.zone:
  file.managed:
    - source: salt://dns/files/{{ myDomain }}.zone
    - template: jinja
    
{% if grains['node_type'] == 'ns-master' %}    

{% for slave, otherIP in salt.mine.get('node_type:ns-slave', 'internal_ip_addrs', expr_form='grain').items() %}

set_master_transfer:
  file.blockreplace:
    - name: /etc/named.conf
    - marker_start: "// START::SALT::DNS::SERVER set_master_transfer Configured Automatically By Salt DO NOT EDIT!!"
    - marker_end: "// END::SALT::DNS::SERVER set_master_transfer Configured Automatically By Salt DO NOT EDIT!!"
    - template: jinja
    - content: allow-transfer { localhost; {{ otherIP[0] }} }
  
set_zones:
  file.blockreplace:
    - name: /etc/named.conf
    - marker_start: "// START::SALT::DNS::SERVER set_zones Configured Automatically By Salt DO NOT EDIT!!"
    - marker_end: "// END::SALT::DNS::SERVER set_zones Configured Automatically By Salt DO NOT EDIT!!"
    - content: |
        zone "{{ myDomain }}" IN {
              type master;
              file "{{ myDomain }}.zone";
              allow-update { none; };
        };
          
          
set_soa:
  file.blockreplace:
    - name: /var/named/{{ myDomain }}.zone
    - marker_start: "; START::SALT::DNS::SERVER {{ myDomain }}_soa Automatically Created By SALT DO NOT EDIT"
    - marker_end: "; END::SALT::DNS::SERVER {{ myDomain }}_soa Automatically Created By SALT DO NOT EDIT"
    - template: jinja
    - content: |
        $TTL 86400
        @   IN  SOA     {{ name }}.{{ myDomain }}. root.{{ myDomain }}. (
          2013042201  ;Serial
          3600        ;Refresh
          1800        ;Retry
          604800      ;Expire
          86400       ;Minimum TTL
        )

set_nsips:
  file.blockreplace:
    - name: /var/named/{{ myDomain }}.zone
    - marker_start: "; START::SALT::DNS::SERVER set_nsips Automatically Created By SALT DO NOT EDIT"
    - marker_end: "; END::SALT::DNS::SERVER set_nsips Automatically Created By SALT DO NOT EDIT"
    - template: jinja
    - content: |
        ; Resolve nameserver hostnames to IP.
        ns1		IN	A		{{ myIP[0] }}
        ns2		IN	A		{{ otherIP[0] }}
{% endfor %}   
{% elif grains['node_type'] == 'ns-slave' %}
{% for master, otherIP in salt.mine.get('node_type:ns-master', 'internal_ip_addrs', expr_form='grain').items() %}
  
set_zones:
  file.blockreplace:
    - name: /etc/named.conf
    - marker_start: "// START::SALT::DNS::SERVER set_zones Configured Automatically By Salt DO NOT EDIT!!"
    - marker_end: "// END::SALT::DNS::SERVER set_zones Configured Automatically By Salt DO NOT EDIT!!"
    - content: |
        zone "{{ myDomain }}" IN {
              type slave;
              masters { {{ otherIP[0] }}; };
              file "{{ myDomain }}.zone";
        };
          
          
set_soa:
  file.blockreplace:
    - name: /var/named/{{ myDomain }}.zone
    - marker_start: "; START::SALT::DNS::SERVER {{ myDomain }}_soa Automatically Created By SALT DO NOT EDIT"
    - marker_end: "; END::SALT::DNS::SERVER {{ myDomain }}_soa Automatically Created By SALT DO NOT EDIT"
    - template: jinja
    - content: |
        $TTL 86400
        @   IN  SOA     ns1.{{ myDomain }}. root.{{ myDomain }}. (
          2013042201  ;Serial
          3600        ;Refresh
          1800        ;Retry
          604800      ;Expire
          86400       ;Minimum TTL
        )

set_nsips:
  file.blockreplace:
    - name: /var/named/{{ myDomain }}.zone
    - marker_start: "; START::SALT::DNS::SERVER set_nsips Automatically Created By SALT DO NOT EDIT"
    - marker_end: "; END::SALT::DNS::SERVER set_nsips Automatically Created By SALT DO NOT EDIT"
    - template: jinja
    - content: |
        ; Resolve nameserver hostnames to IP.
        ns1		IN	A		{{ otherIP[0] }}
        ns2		IN	A		{{ myIP[0] }}
{% endfor %}
{% endif %}

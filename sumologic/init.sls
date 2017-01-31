# -*- yaml -*- #
{%- from 'sumologic/conf/settings.sls' import sumologic with context %}
{%- import_yaml 'sumologic/conf/initmap.yml' as initmap %}
{%- set init = salt['grains.filter_by'](initmap,grain='init',default='systemd') %}


include:
  - sun-java
  - sun-java.env

### APPLICATION INSTALL ###
unpack-sumologic-tarball:
  archive.extracted:
    - name: {{ sumologic.prefix }}
    - source: {{ sumologic.source_url }}
    - skip_verify: True
    - source_hash: {{ salt['pillar.get']('sumologic:source_hash', '') }}
    - archive_format: tar
    - user: sumologic
    - tar_options: z
    - if_missing: {{ sumologic.prefix }}/sumocollector/{{ sumologic.version }}
    - keep: True
    - require:
      - module: sumologic-stop
      - file: sumologic-init-script
      - user: sumologic
    - listen_in:
      - module: sumologic-restart

fix-sumologic-filesystem-permissions:
  file.directory:
    - user: sumologic
    - recurse:
      - user
    - names:
      - {{ sumologic.prefix }}/sumocollector
      - {{ sumologic.prefix }}/sumocollector/sources
      - {{ sumologic.home }}
    - watch:
      - archive: unpack-sumologic-tarball

### SERVICE ###
sumologic-service:
  service.running:
    - name: sumologic
    - enable: True
    - require:
      - archive: unpack-sumologic-tarball
      - file: sumologic-init-script

# used to trigger restarts by other states
sumologic-restart:
  module.wait:
    - name: service.restart
    - m_name: sumologic

sumologic-stop:
  module.wait:
    - name: service.stop
    - m_name: sumologic  

sumologic-init-script:
  file.managed:
    - name: {{ init.path }}
    - source: {{ init.template }}
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - context:
      sumologic: {{ sumologic|json }}

{% if salt['grains.get']('init', 'systemd') == 'systemd' %}
create-sumologic-service-symlink:
  file.symlink:
    - name: '/etc/systemd/system/sumologic.service'
    - target: '/lib/systemd/system/sumologic.service'
    - user: root
    - watch:
      - file: sumologic-init-script
{% endif %}

sumologic:
  user.present

### FILES ###
{{ sumologic.prefix }}/sumocollector/config/user.properties:
  file.managed:
    - source: salt://sumologic/templates/user.properties.tmpl
    - user: {{ sumologic.user }}
    - template: jinja
    - listen_in:
      - module: sumologic-restart

{{ sumologic.prefix }}/sumocollector/wrapper:
  file.managed:
    - source: {{ sumologic.prefix }}/sumocollector/tanuki/linux64/wrapper
    - user: {{ sumologic.user }}
    - mode: 0754
    - watch_in:
      - module: sumologic-restart

{{ sumologic.prefix }}/sumocollector/collector:
  file.managed:
    - source: {{ sumologic.prefix }}/sumocollector/collector
    - user: {{ sumologic.user }}
    - mode: 0754
    - watch_in:
      - module: sumologic-restart

{{ sumologic.prefix }}/sumocollector/{{ sumologic.version }}/bin/native/lib/libwrapper.so:
  file.managed:
    - source: {{ sumologic.prefix }}/sumocollector/tanuki/linux64/libwrapper.so
    - user: {{ sumologic.user }}
    - watch_in:
      - module: sumologic-restart

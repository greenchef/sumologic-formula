{% set p  = salt['pillar.get']('sumologic', {}) %}
{% set g  = salt['grains.get']('sumologic', {}) %}


{%- set default_version      = '137' %}
{%- set default_prefix       = '/opt' %}
{%- set default_source_url   = 'https://collectors.sumologic.com/rest/download/tar' %}
{%- set default_sumologic_user = 'sumologic' %}
{%- set default_collector_name = 'saltstack' %}

{%- set version        = g.get('version', p.get('version', default_version)) %}
{%- set source_url     = g.get('source_url', p.get('source_url', default_source_url)) %}
{%- set prefix         = g.get('prefix', p.get('prefix', default_prefix)) %}
{%- set sumologic_user = g.get('user', p.get('user', default_sumologic_user)) %}
{%- set collector_name = g.get('collector_name', p.get('collector_name', default_collector_name)) %}


{%- set sumologic_home  = salt['pillar.get']('users:%s:home' % sumologic_user, '/home/sumologic') %}

{%- set sumologic = {} %}
{%- do sumologic.update( { 'version'        : version,
                      'source_url'     : source_url,
                      'home'           : sumologic_home,
                      'prefix'         : prefix,
                      'user'           : sumologic_user,
                      'collector_name' : collector_name,
                  }) %}


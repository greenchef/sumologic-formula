{% set p  = salt['pillar.get']('sumologic', {}) %}
{% set g  = salt['grains.get']('sumologic', {}) %}


{%- set default_version      = '137' %}
{%- set default_prefix       = '/opt' %}
{%- set default_sumologic_user = 'sumologic' %}
{%- set default_collector_name = 'saltstack' %}
{%- set default_access_id    = 'changeme' %}
{%- set default_access_key   = 'changeme' %}

{%- set version        = g.get('version', p.get('version', default_version)) %}
{%- set prefix         = g.get('prefix', p.get('prefix', default_prefix)) %}
{%- set sumologic_user = g.get('user', p.get('user', default_sumologic_user)) %}
{%- set access_id      = g.get('access_id', p.get('access_id', default_access_id)) %}
{%- set access_key     = g.get('access_key', p.get('access_key', default_access_key)) %}
{%- set collector_name = salt['grains.get']('ec2_tags:application', default_collector_name) %}


{%- set sumologic_home  = salt['pillar.get']('users:%s:home' % sumologic_user, '/home/sumologic') %}

{%- set sumologic = {} %}
{%- do sumologic.update( { 'version'        : version,
                      'source_url'     : source_url,
                      'home'           : sumologic_home,
                      'prefix'         : prefix,
                      'user'           : sumologic_user,
                      'access_id'      : access_id,
                      'access_key'     : access_key,
                      'collector_name' : collector_name,
                  }) %}


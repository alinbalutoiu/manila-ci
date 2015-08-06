#!/bin/bash
set -e

source /home/ubuntu/devstack/functions
source /home/ubuntu/devstack/functions-common

nova flavor-delete 100
nova flavor-create manila-service-flavor 100 2048 20 2

# Add DNS config to the private network
subnet_id=`neutron net-show private | grep subnets | awk '{print $4}'`
neutron subnet-update $subnet_id --dns_nameservers list=true 8.8.8.8 8.8.4.4

TEMPEST_CONFIG=/opt/stack/tempest/etc/tempest.conf

iniset $TEMPEST_CONFIG cli enabled True

iniset $TEMPEST_CONFIG identity uri http://127.0.0.1:5000/v2.0/
iniset $TEMPEST_CONFIG identity uri_v3 http://127.0.0.1:5000/v3/
iniset $TEMPEST_CONFIG identity username demo
iniset $TEMPEST_CONFIG identity password Passw0rd
iniset $TEMPEST_CONFIG identity tenant_name demo
iniset $TEMPEST_CONFIG identity alt_username alt_demo
iniset $TEMPEST_CONFIG identity alt_password Passw0rd
iniset $TEMPEST_CONFIG identity admin_username admin
iniset $TEMPEST_CONFIG identity admin_password Passw0rd
iniset $TEMPEST_CONFIG identity admin_tenant_name admin

public_id=`neutron net-list | grep public | awk '{print $2}'`
iniset $TEMPEST_CONFIG network public_network_id $public_id

# router_id=`neutron router-list | grep router | awk '{print $2}'
# iniset $TEMPEST_CONFIG network public_router_id $router_id

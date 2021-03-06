#!/bin/bash

set -x
set -e
sudo ifconfig eth1 promisc up
sudo ifconfig eth2 promisc up

HOSTNAME=$(hostname)

sudo sed -i '2i127.0.0.1  '$HOSTNAME'' /etc/hosts

# Update six to latest version
sudo pip install -U six
sudo pip install -U kombu

# Install PyWinrm for manila
sudo pip install -U git+https://github.com/petrutlucian94/pywinrm

# Running an extra apt-get update
sudo apt-get update --assume-yes

# Ensure subunit is available
set +e
exit_code=0
sudo apt-get install subunit -y -o Debug::pkgProblemResolver=true -o Debug::Acquire::http=true -f
# Backup install in case repository install fails
if [ $? -ne 0 ]; then
    echo "Using backup: manually installing packages"
    wget --quiet --output-document=/tmp/libsubunit-perl_0.0.18-0ubuntu7_all.deb http://dl.openstack.tld/subunit_deps/libsubunit-perl_0.0.18-0ubuntu7_all.deb | sudo dpkg --install /tmp/libsubunit-perl_0.0.18-0ubuntu7_all.deb
    wget --quiet --output-document=/tmp/python-testtools_0.9.35-0ubuntu1_all.deb http://dl.openstack.tld/subunit_deps/python-testtools_0.9.35-0ubuntu1_all.deb | sudo dpkg --install /tmp/python-testtools_0.9.35-0ubuntu1_all.deb
    wget --quiet --output-document=/tmp/python-testscenarios_0.4-2ubuntu2_all.deb http://dl.openstack.tld/subunit_deps/python-testscenarios_0.4-2ubuntu2_all.deb | sudo dpkg --install /tmp/python-testscenarios_0.4-2ubuntu2_all.deb
    wget --quiet --output-document=/tmp/python-extras_0.0.3-2ubuntu1_all.deb http://dl.openstack.tld/subunit_deps/python-extras_0.0.3-2ubuntu1_all.deb | sudo dpkg --install /tmp/python-extras_0.0.3-2ubuntu1_all.deb
    wget --quiet --output-document=/tmp/python-subunit_0.0.18-0ubuntu7_all.deb http://dl.openstack.tld/subunit_deps/python-subunit_0.0.18-0ubuntu7_all.deb | sudo dpkg --install /tmp/python-subunit_0.0.18-0ubuntu7_all.deb
    wget --quiet --output-document=/tmp/libatk1.0-0_2.10.0-2ubuntu2_amd64.deb http://dl.openstack.tld/subunit_deps/libatk1.0-0_2.10.0-2ubuntu2_amd64.deb | sudo dpkg --install /tmp/libatk1.0-0_2.10.0-2ubuntu2_amd64.deb
    wget --quiet --output-document=/tmp/libcairo2_1.13.0~20140204-0ubuntu1_amd64.deb http://dl.openstack.tld/subunit_deps/libcairo2_1.13.0~20140204-0ubuntu1_amd64.deb | sudo dpkg --install /tmp/libcairo2_1.13.0~20140204-0ubuntu1_amd64.deb
    wget --quiet --output-document=/tmp/libgdk-pixbuf2.0-0_2.30.7-0ubuntu1_amd64.deb http://dl.openstack.tld/subunit_deps/libgdk-pixbuf2.0-0_2.30.7-0ubuntu1_amd64.deb | sudo dpkg --install /tmp/libgdk-pixbuf2.0-0_2.30.7-0ubuntu1_amd64.deb
    wget --quiet --output-document=/tmp/libgtk2.0-0_2.24.23-0ubuntu1_amd64.deb http://dl.openstack.tld/subunit_deps/libgtk2.0-0_2.24.23-0ubuntu1_amd64.deb | sudo dpkg --install /tmp/libgtk2.0-0_2.24.23-0ubuntu1_amd64.deb
    wget --quiet --output-document=/tmp/libpango-1.0-0_1.36.3-1ubuntu1_amd64.deb http://dl.openstack.tld/subunit_deps/libpango-1.0-0_1.36.3-1ubuntu1_amd64.deb | sudo dpkg --install /tmp/libpango-1.0-0_1.36.3-1ubuntu1_amd64.deb
    wget --quiet --output-document=/tmp/libpangocairo-1.0-0_1.36.3-1ubuntu1_amd64.deb http://dl.openstack.tld/subunit_deps/libpangocairo-1.0-0_1.36.3-1ubuntu1_amd64.deb | sudo dpkg --install /tmp/libpangocairo-1.0-0_1.36.3-1ubuntu1_amd64.deb
    wget --quiet --output-document=/tmp/python-cairo_1.8.8-1ubuntu5_amd64.deb http://dl.openstack.tld/subunit_deps/python-cairo_1.8.8-1ubuntu5_amd64.deb | sudo dpkg --install /tmp/python-cairo_1.8.8-1ubuntu5_amd64.deb
    wget --quiet --output-document=/tmp/python-gobject-2_2.28.6-12build1_amd64.deb http://dl.openstack.tld/subunit_deps/python-gobject-2_2.28.6-12build1_amd64.deb | sudo dpkg --install /tmp/python-gobject-2_2.28.6-12build1_amd64.deb
    wget --quiet --output-document=/tmp/python-gtk2_2.24.0-3ubuntu3_amd64.deb http://dl.openstack.tld/subunit_deps/python-gtk2_2.24.0-3ubuntu3_amd64.deb | sudo dpkg --install /tmp/python-gtk2_2.24.0-3ubuntu3_amd64.deb
    wget --quiet --output-document=/tmp/python-junitxml_0.6-1.1build1_all.deb http://dl.openstack.tld/subunit_deps/python-junitxml_0.6-1.1build1_all.deb | sudo dpkg --install /tmp/python-junitxml_0.6-1.1build1_all.deb
    wget --quiet --output-document=/tmp/subunit_0.0.18-0ubuntu7_all.deb http://dl.openstack.tld/subunit_0.0.18-0ubuntu7_all.deb | sudo dpkg --install /tmp/subunit_0.0.18-0ubuntu7_all.deb
#    wget --quiet --output-document=/tmp/ http://dl.openstack.tld/subunit_deps/ | sudo dpkg --install /tmp/
    sudo apt-get -f install -y
    exit_code=$?
fi
set -e
if [ $exit_code -ne 0 ]; then
    exit 1
fi

DEVSTACK_LOGS="/opt/stack/logs/screen"
LOCALRC="/home/ubuntu/devstack/localrc"
LOCALCONF="/home/ubuntu/devstack/local.conf"
PBR_LOC="/opt/stack/pbr"
# Clean devstack logs
rm -f "$DEVSTACK_LOGS/*"
rm -rf "$PBR_LOC"

MYIP=$(/sbin/ifconfig eth0 2>/dev/null| grep "inet addr:" 2>/dev/null| sed 's/.*inet addr://g;s/ .*//g' 2>/dev/null)

if [ -e "$LOCALCONF" ]
then
        [ -z "$MYIP" ] && exit 1
        sed -i 's/^HOST_IP=.*/HOST_IP='$MYIP'/g' "$LOCALCONF"
fi

if [ -e "$LOCALRC" ]
then
        [ -z "$MYIP" ] && exit 1
        sed -i 's/^HOST_IP=.*/HOST_IP='$MYIP'/g' "$LOCALRC"
fi


cd /home/ubuntu/devstack
git pull
sudo easy_install -U pip

MANILA_LOC="/home/ubuntu/manila"
# Clean previous manila clone if any
sudo rm -rf "$MANILA_LOC"

cd /home/ubuntu/
git clone https://github.com/OpenStack/manila

cd /home/ubuntu/manila
git config --global user.email "microsoft_manila_ci@microsoft.com"
git config --global user.name "Microsoft Manila CI"

# download the patch to be tested
git pull --no-edit https://review.openstack.org/openstack/manila refs/changes/54/200154/11

cd /home/ubuntu/devstack

./unstack.sh

nohup ./stack.sh > /opt/stack/logs/stack.sh.txt 2>&1 &
pid=$!
wait "$pid"
stack_status=$?
cat /opt/stack/logs/stack.sh.txt
if [ $stack_status -ne 0 ]
then
    echo "stack_status is: $stack_status"
    exit 1
fi

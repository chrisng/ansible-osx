#!/usr/bin/env bash
set -eu

OSX_VER=$(sw_vers -productVersion | awk -F. '{ print $1"."$2 }')
MAVERICKS='10.9'
PYTHON_VER=$(python -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')
TARGET_PYTHON_VER="2.7.9"

# Download and install Command Line Tools
if [[ ! -x /usr/bin/gcc ]]; then
    echo "Info   | Install   | xcode"
    xcode-select --install
fi

# Download and install Homebrew
if [[ ! -x /usr/local/bin/brew ]]; then
    echo "Info   | Install   | homebrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if [[ (($PYTHON_VER < $TARGET_PYTHON_VER)) ]] ; then
    echo "Info   | Upgrade   | python" 
    brew install python --framework --with-brewed-openssl
    brew linkapps python
fi

echo 'Updating setup tools'
pip install --upgrade setuptools
pip install --upgrade pip

echo 'Installing Ansible'
command -v ansible >/dev/null 2>&1 || { echo >&2 "ansible is not installed.  Aborting."; INSTALL_ANSIBLE=1; }
if [ ${INSTALL_ANSIBLE} -eq "1" ] ; then
    if [[ (($OSX_VER > $MAVERICKS)) ]]; then
        sudo -H CFLAGS=-Qunused-arguments CPPFLAGS=-Qunused-arguments pip install ansible
    else
        sudo -H pip install ansible
    fi
fi

echo 'Running Ansible to configure Dev machine'

if [[ -x `which ansible` ]]; then
    ansible-playbook -i inventory site.yml --ask-sudo-pass
fi

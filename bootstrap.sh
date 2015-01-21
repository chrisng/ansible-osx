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
fi

echo 'Installing Ansible'
# prefer pip for installing python packages over the older easy_install
#
#if [[ ! -x `which pip` ]]; then
#    sudo easy_install pip
#fi

#if [[ -x `which pip` && ! -x `which ansible` ]]; then
command -v ansible >/dev/null 2>&1 || { echo >&2 "ansible is not installed.  Aborting."; INSTALL_ANSIBLE=1; exit 0; }
if [ ${INSTALL_ANSIBLE} -eq "1" ] ; then
    if (( $(echo "$OSX_VER > $MAVERICKS" | bc -l) )); then
        sudo CFLAGS=-Qunused-arguments CPPFLAGS=-Qunused-arguments pip install ansible
    else
        sudo pip install ansible
    fi
fi

echo 'Running Ansible to configure Dev machine'

if [[ -x `which ansible` ]]; then
    ansible-playbook -i inventory site.yml --ask-sudo-pass
fi

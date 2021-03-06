#!/bin/bash
set -eu -o pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"

# load environment variables from .env
set -a
if [ -e "$script_dir"/.env ]; then
  # shellcheck disable=SC1090
  . "$script_dir"/.env
else
  echo 'Environment file .env not found. Therefore, dotenv.sample will be used.'
  # shellcheck disable=SC1090
  . "$script_dir"/dotenv.sample
fi
set +a

# Install Mo
curl -sSL https://git.io/get-mo -o /usr/local/bin/mo
chmod +x /usr/local/bin/mo

# Install Oracle Preinstallation RPM
yum -y install oracle-database-preinstall-18c

# Create directories
mkdir -p "$ORACLE_HOME"
chown -R oracle:oinstall "$ORACLE_BASE"/..
chmod -R 775 "$ORACLE_BASE"/..

# Set environment variables
cat <<EOT >> /home/oracle/.bash_profile
export ORACLE_BASE=$ORACLE_BASE
export ORACLE_HOME=$ORACLE_HOME
export ORACLE_SID=$ORACLE_SID
export PATH=\$PATH:\$ORACLE_HOME/bin:\$ORACLE_HOME/jdk/bin
EOT

# Install rlwrap and set alias
# shellcheck disable=SC1091
readonly OS_VERSION=$(. /etc/os-release; echo "$VERSION")
case ${OS_VERSION%%.*} in
  7)
    yum -y --enablerepo=ol7_developer_EPEL install rlwrap
    cat <<EOT >>/home/oracle/.bashrc
alias sqlplus='rlwrap sqlplus'
EOT
    ;;
esac

# Set oracle password
echo oracle:"$ORACLE_PASSWORD" | chpasswd

# Install database
/usr/local/bin/mo "$script_dir"/db_install.rsp.mo >"$script_dir"/db_install.rsp
su - oracle -c "unzip -d $ORACLE_HOME $script_dir/LINUX.X64_180000_db_home.zip"
set +e +o pipefail
su - oracle -c "cd $ORACLE_HOME && ./runInstaller -silent \
  -ignorePrereq  -waitforcompletion -responseFile $script_dir/db_install.rsp"
set -e -o pipefail
"$ORACLE_BASE"/../oraInventory/orainstRoot.sh
"$ORACLE_HOME"/root.sh

# Create listener using netca
su - oracle -c "netca -silent -responseFile \
  $ORACLE_HOME/assistants/netca/netca.rsp"

# Create database
/usr/local/bin/mo "$script_dir"/dbca.rsp.mo >"$script_dir"/dbca.rsp
su - oracle -c "dbca -silent -createDatabase -responseFile $script_dir/dbca.rsp"

# Shutdown database
#echo "shutdown immediate" | su - oracle -c 'sqlplus "/ as sysdba"'

# Stop listener
#su - oracle -c "lsnrctl stop"

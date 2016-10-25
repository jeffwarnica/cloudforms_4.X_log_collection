#!/bin/bash
collect_logs_directory=$(pwd)
# save directory from which command is initiated
pushd /var/www/miq/vmdb
# make the vmdb/log directory the current directory
rm -f log/evm_full_archive_$(uname -n)* log/evm_current_$(uname -n)*
# eliminiate any prior collected logs to make sure that only one collection is current

# determine what level of CFME this command is executing on
read tbuild < BUILD
echo "$tbuild"
subset=${tbuild:0:3}
echo "$subset"
if [ $subset = "5.5" ]; then
     echo 'this is a CFME 40 environment'
     else
     echo 'this is not a CFME 40 environment'
fi

case $subset in
"5.5" )
 message="cloudforms 4.0 release"
 if [ -e "/var/opt/rh/rh-postgresql94/lib/pgsql/data/postgresql.conf" ] ; then
  postgresql_path_files="/var/opt/rh/rh-postgresql94/lib/pgsql/data/*.conf /var/opt/rh/rh-postgresql94/lib/pgsql/data/pg_log/* "
  else
  echo "this appliance does not contain a running postgresql instance, no postgresql materials collected"
 fi
 ;;
"5.6" )
 message="cloudforms 4.1 release"
 if [ -e "/var/opt/rh/rh-postgresql94/lib/pgsql/data/postgresql.conf" ] ; then
  postgresql_path_files="/var/opt/rh/rh-postgresql94/lib/pgsql/data/*.conf /var/opt/rh/rh-postgresql94/lib/pgsql/data/pg_log/* "
  else
  echo "this appliance does not contain a running postgresql instance, no postgresql materials collected"
 fi
 ;;
*)
 message="unknown cloudforms release"
 ;;
esac
# then collect all appropriate logs into one tgz
echo "XZ_OPT=-9 tar -cJvf log/evm_full_archive_$(uname -n)_$(date +%Y%m%d_%H%M%S).tar.xz --sparse -X $collect_logs_directory/exclude_files BUILD GUID VERSION log/* config/*  /var/log/* $postgresql_path_files  "
XZ_OPT=-9 tar -cJvf log/evm_full_archive_$(uname -n)_$(date +%Y%m%d_%H%M%S).tar.xz --sparse -X $collect_logs_directory/exclude_files BUILD GUID VERSION log/* config/* /var/log/* $postgresql_path_files
# then restore prior current directory
popd
#!/bin/bash
set -xe
set -o pipefail

CURRENT_DIR=$(cd $(dirname $0);pwd)
export MYSQL_HOST=${MYSQL_HOST:-127.0.0.1}
export MYSQL_PORT=${MYSQL_PORT:-63306}
export MYSQL_USER=${MYSQL_USER:-isucon}
export MYSQL_DBNAME=${MYSQL_DBNAME:-isubata}
export MYSQL_PWD=${MYSQL_PASS:-isucon}
export LANG="C.UTF-8"
cd $CURRENT_DIR

ls -1 ../sql/*.sql | while read file
do
  echo $file
  cat $file | mysql --defaults-file=/dev/null -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER $MYSQL_DBNAME
done

ls -1 ../sql/*.sql.gz | while read file
do
  echo $file
  zcat $file | mysql --defaults-file=/dev/null -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER $MYSQL_DBNAME
done

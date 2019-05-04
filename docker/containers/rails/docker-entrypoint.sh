#!/bin/bash

set -e

if [[ -z "$(ls /app/app)" ]]; then
  rails new . -d mysql -f
  cp -a $READY_RAILS_DIR/database.yml \
    $READY_RAILS_DIR/puma.rb \
    $READY_RAILS_DIR/application.rb /app/config/
  until rails db:drop &> /dev/null; do
    >&2 echo "MySQL is unavailable - sleeping"
    sleep 1
  done

  rails db:create
fi

exec "$@"

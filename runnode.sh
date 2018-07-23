#!/dumb-init /bin/bash

wd=${NODE_WORKDIR:-.}
exec=${NODE_SCRIPT:-server.js}
archive=${APP_ARCHIVE:-}
args=$*

function start_node() {
  if [ -f .lock ]; then
    return
  fi
  touch .lock
  echo "(Re)starting node..."
  if [ ! -z $archive ]; then
    echo "Listing archives at ${archive}..."
    tgz=$(ls -t $archive|grep .tgz|head -1)
    if [ ! -z $tgz ]; then
      echo "Newest one is: $tgz"
      main_dir=$wd      
      echo "Unpacking in ${main_dir}..."
      ( mkdir -p $main_dir && cd $main_dir && tar zxf $archive/$tgz --strip=1 --keep-newer-files ) || exit 3
    fi
  fi
  cd $wd
  if [ ! -z $HTTP_PROXY ]; then
    npm config set proxy "$HTTP_PROXY"
  fi
  if [ ! -z $HTTPS_PROXY ]; then
    npm config set https_proxy "$HTTPS_PROXY"
  fi
  npm install && npm prune && exec node $exec $args
}

rm -f .lock
start_node
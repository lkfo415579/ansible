 docker ps -a | cut -d ' ' -f 1 | xargs  docker rm

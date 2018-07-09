docker images | grep none | tr -s " " | cut -f3 -d " " | xargs docker rmi

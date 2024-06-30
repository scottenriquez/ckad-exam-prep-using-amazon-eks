# get all local images
docker image ls
# get containers
docker ps --all

# export Docker image as tar file
docker pull alpine:latest
docker save alpine:latest --output alpine.tar

# create image from running Docker container
docker run alpine:latest
# to get the container ID
docker ps --all
docker commit 4d5af4041dbc scottenriquez/alpine-modified
docker image ls

# re-tag image
docker image tag scottenriquez/alpine-modified scottenriquez/alpine-modified-from-running

# delete image
docker image rm scottenriquez/alpine-modified
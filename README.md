# Build and run
```shell
image_name=xxx
container_name=xxx

docker build \
    --build-arg USER_PASSWD=$passwd \
    --build-arg HTTP_PROXY=$http_proxy \
    --build-arg HTTPS_PROXY=$https_proxy \
    -t $image_name \
    --network host \
    .

# -v host_dir:container_dir
docker run \
  -d --privileged \
  --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
  --name=$image_name \
  --runtime=nvidia --gpus all \
  -e HOST_PERMS="$(id -u):$(id -g)" \
  --label user=zhiqiangz \
  $container_name 
```

# Useful commands
- quick filter out container belongs to zhiqiangz
```shell
docker ps  --filter "label=user=zhiqiangz"
```


# Build and run
```shell
 export passwd=xxx
export image_name=xxx
export container_name=xxx
export network_name=xxx
export ip_addr=172.1x.0.x

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
  --name=$container_name \
  --runtime=nvidia --gpus all \
  --shm-size=400g \
  --network $network_name \
  --ip $ip_addr \
  -e HOST_PERMS="$(id -u):$(id -g)" \
  --label user=zhiqiangz \
  $image_name
```

# Useful commands
- quick filter out container belongs to zhiqiangz
```shell
docker ps  --filter "label=user=zhiqiangz"
```

- check current existed bridge net environment and coresponding occupied ip
```shell
docker network ls --filter driver=bridge --quiet | while read network_id; do
  network_info=$(docker network inspect --format '{{.Name}} - Subnet: {{range .IPAM.Config}}{{.Subnet}}{{end}} | Gateway: {{range .IPAM.Config}}{{.Gateway}}{{end}}' $network_id)
  echo -e "\033[31m$network_info\033[0m"
  
  # get container name and ip map
  docker network inspect $network_id --format '{{range $key, $value := .Containers}}{{println $value.Name $value.IPv4Address}}{{end}}'
  echo "----------------------------------"
done
```

- create bridge net environment
```shell
export net_prefix=172.1x.0.
export network_name=172.1x.0.
docker network create --driver=bridge --subnet=$(net_prefix).0/16 --ip-range=$(net_prefix).0/24 --gateway=$(net_prefix).1 $network_name
```


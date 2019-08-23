# Docker用法总结


## 前言

本文主要介绍docker的一些常见用法，记录一些问题的解决办法。

### Docker 新版命令记录

```doc
docker build -t friendlyhello .  # Create image using this directory's Dockerfile
docker run -p 4000:80 friendlyhello  # Run "friendlyhello" mapping port 4000 to 80
docker run -d -p 4000:80 friendlyhello         # Same thing, but in detached mode


docker container ls                                # List all running containers
docker container ls -a             # List all containers, even those not running
docker container stop <hash>           # Gracefully stop the specified container
docker container kill <hash>         # Force shutdown of the specified container
docker container rm <hash>        # Remove specified container from this machine
docker container rm $(docker container ls -a -q)         # Remove all containers
docker image ls -a                             # List all images on this machine
docker image rm <image id>            # Remove specified image from this machine
docker image rm $(docker image ls -a -q)   # Remove all images from this machine

docker login             # Log in this CLI session using your Docker credentials
docker tag <image> username/repository:tag  # Tag <image> for upload to registry
docker push username/repository:tag            # Upload tagged image to registry
docker run username/repository:tag      

docker stack ls                                            # List stacks or apps
docker stack deploy -c <composefile> <appname>  # Run the specified Compose file
docker service ls                 # List running services associated with an app
docker service ps <service>                  # List tasks associated with an app
docker inspect <task or container>                   # Inspect task or container
docker container ls -q                                      # List container IDs
docker stack rm <appname>                             # Tear down an application
docker swarm leave --force      # Take down a single node swarm from the manager
```



### Docker 命令记录

```bash
# 容器生命周期管理
run	-itd
start/stop/restart
kill
rm
pause/unpause
create
exec -it
# 容器操作
ps
inspect
top
attach
events
logs
wait
export
port
# 容器rootfs命令
commit
cp
diff
# 镜像仓库
login
pull
push
search
# 本地镜像管理
images
rmi
tag
build
history
save
import
info|version
info
version
```

### Docker File

[参考官方文档](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

| 命令        | 例子                                                         |
| ----------- | ------------------------------------------------------------ |
| FROM        | FROM busybox:$VERSION                                        |
| LABEL       | LABEL com.example.version="0.0.1-beta"                       |
| RUN         | RUN apt-get update                                           |
| RUN         | RUN ["/bin/bash", "-c", "set -o pipefail && wget -O - https://some.site \| wc -l > /number"] |
| CMD         | CMD echo "This is a test." \| wc - 容器docker run 时候执行   |
| EXPOSE      | EXPOSE 80/tcp                                                |
| ENV         | ENV myName John Doe                                          |
| ADD or COPY | COPY requirements.txt /tmp/ 推荐COPY                         |
| ENTRYPOINT  | ENTRYPOINT ["executable", "param1", "param2"]类似CMD，不会被覆盖 |
| VOLUME      | VOLUME /myvol                                                |
| USER        | USER <user>[:<group>]                                        |
| WORKDIR     | WORKDIR /path/to/workdir                                     |
| ARG         | ARG <name>[=<default value>]                                 |



### Docker 安装mysql

```bash
docker pull mysql/mysql-server
docker run -itd --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=admin123 mysql/mysql-server
docker exec -it mysql bash
修改
 use mysql;
 update user set host = '%' where user = 'root';
 FLUSH PRIVILEGES;
```






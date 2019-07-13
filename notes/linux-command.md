# Linux服务器常用命令

### Docker 

```bash
# 删除tag和name为none的坏掉的image
docker rmi $(docker images -f "dangling=true" -q)
# 删掉所有容器
docker stop $(docker ps -qa)
docker kill $(docker ps -qa)
docker rm $(docker ps -qa)
# 删除所有镜像
docker rmi --force $(docker images -q)
```

### grep 

```bash
# 删除空白行和注释行
cat file | grep -v ^# | grep .
cat file | grep -Ev '^$|^#'
```


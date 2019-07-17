# Common Commands & Trouble Shooting

服务器常用命令，以及问题解决记录

## Common Commands

### grep 

```bash
# 删除空白行和注释行
cat file | grep -v ^# | grep .
cat file | grep -Ev '^$|^#'
```

### ps

```bash
# 查看后台job
jobs
# 后台运行
( cmd ) &
# 唤醒
fg %<job_num>
# 暂停放入后台
ctrl z
# 唤醒stop的job
bg %<job_num>

```

### docker 

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

### openssl

 ```bash
# 查看证书过期时间
openssl x509 -noout -enddate -in <crt_path>
# 获取端口证书过期时间
echo 'Q' | timeout 5 openssl s_client -connect <host:port> 2>/dev/null | openssl x509 -noout -enddate
# 自签根证书
openssl genrsa -aes256 -out <ca私钥位置> 2048
openssl req -new -key <ca私钥位置> -out <ca签发流程位置> -subj "/C=/ST=/L=/O=/OU=/CN=/emailAddress="
openssl x509 -req -sha256 -days <过期天数> -in <ca签发流程位置> -out <ca证书位置> -signkey <ca私钥位置> -CAcreateserial
# 根证书签发子证书
openssl genrsa -aes256 -out <私钥位置> 2048
openssl req -new -key <私钥位置> -out <签发流程位置> -subj "/C=/ST=/L=/O=/OU=/CN=/emailAddress=" 
openssl x509 -req -sha256 -days <过期天数> -in <签发流程位置> -out <证书位置> -signkey <私钥位置> -CAkey <ca私钥> -CA <ca证书位置> -CAcreateserial
openssl pkcs12 -export -clcerts -in <证书位置> -inkey <私钥位置> -out <p12证书位置> -name <别名>
 ```

### keytool

```bash
# 查看keystore
${JAVA_HOME}/bin/keytool -v -list -storepass <password> -keystore <keystore_path>
# 导入trust keystore
${JAVA_HOME}/bin/keytool -import -trustcacerts -noprompt -alias <别名> -file <证书位置> -keystore <Keystore位置>
# 导入keystore
${JAVA_HOME}/bin/keytool -importkeystore -trustcacerts -noprompt -alias <别名> -deststoretype pkcs12 -srcstoretype pkcs12 -srckeystore <p12证书位置> -destkeystore <Keystore位置>
```

### chown

```bash
chown -R <user> <dir>
chown -R :<group> <dir>
chown -R <user>:<group> <dir>
```

### mysql

```bash
# 查配置
show variables like '%';
# 放开用户的远程操作权限
GRANT ALL PRIVILEGES ON *.* TO '<user>'@'%' IDENTIFIED BY '<password>' WITH GRANT OPTION;
# 刷新权限规则生效
flush privileges;
```



## Trouble Shooting

### Openstack主机ssh虚拟机

通常我们在使用Openstack搭建私有云时会使用provider网络，内网的虚拟机将指定网络通过Openstack提供的路由可以和主机相连，但是主机却ping不通相关网络。为了解决这一问题我们需要在主机上也添加一个路由。

步骤1 找到Openstack创出的路由信息，<openstack-route>

```bash
ip netns ls
```

步骤2 获取绑定的外部provider地址，执行命令找到provider网段的ip信息 <provider-ip>

```bash
ip netns exec <openstack-route> ip a
```

步骤3 找到主机上provider网络对应的物理设备 <net-dev>

```bash
ip a
```

步骤4 主机创建路由,以11网段的子网为例

```bash
ip route add 192.168.11.0/24 via <provider-ip> dev <net-dev>
```

当然我们可以在opensatck dashborad的路由信息中找到 <provider-ip>，可以省去一些步骤。

完成以上操作就可以ssh直连内网虚拟机了。

### Openstack虚拟机网络MTU

在老版本的Openstack中，出现了虚拟机能ping通其他虚拟机但是ssh连接失败的情况，发现是虚拟机内部网络设备的MTU大于了主机上网络设备的MTU。以及网络设备eth0，主机MTU1450为例。

```bash
ip link set eth0 mtu 1450
```

### Yum安装的Mysql5.7查看初始化密码并修改

```bash
[root@centos7 ~]# grep 'temporary password' /var/log/mysqld.log
2019-07-12T15:22:11.734964Z 1 [Note] A temporary password is generated for root@localhost: Dt,hL6aqc1gr
[root@centos7 ~]# mysql -uroot -pDt,hL6aqc1gr

# 方便测试密码等级最低
mysql> set global validate_password_length=0;
mysql> set global validate_password_policy=0;
mysql> set password for 'root'@'localhost' = password('123456');
mysql> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
mysql> flush privileges;
```


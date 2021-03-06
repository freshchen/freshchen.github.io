# Trouble Shooting





### IDEA右侧Maven标签栏的Dependences报红

检查没有冲突，并且包导入成功，把pom中的对应的报红依赖注释，import一遍，然后放开再import一遍

### k8s如何支持多网络

[multus-cni ]( https://github.com/intel/multus-cni )

### Docker启动Zabbix

- 1 先安装数据库mysql

```cpp
docker run --name zabbix-mysql-server --hostname zabbix-mysql-server \
-e MYSQL_ROOT_PASSWORD="123456" \
-e MYSQL_USER="zabbix" \
-e MYSQL_PASSWORD="123456" \
-e MYSQL_DATABASE="zabbix" \
-p 3306:3306  \
-d mysql:5.7 \
--character-set-server=utf8 --collation-server=utf8_bin
```

- 2 创建zabbix-server

```jsx
docker run  --name zabbix-server-mysql --hostname zabbix-server-mysql \
--link zabbix-mysql-server:mysql \
-e DB_SERVER_HOST="mysql" \
-e MYSQL_USER="zabbix" \
-e MYSQL_DATABASE="zabbix" \
-e MYSQL_PASSWORD="123456" \
-v /etc/localtime:/etc/localtime:ro \
-v /data/docker/zabbix/alertscripts:/usr/lib/zabbix/alertscripts \
-v /data/docker/zabbix/externalscripts:/usr/lib/zabbix/externalscripts \
-p 10051:10051 \
-d \
zabbix/zabbix-server-mysql
```

- 3 安装web-nginx

```bash
docker run --name zabbix-web-nginx-mysql --hostname zabbix-web-nginx-mysql \
--link zabbix-mysql-server:mysql \
--link zabbix-server-mysql:zabbix-server \
-e DB_SERVER_HOST="mysql" \
-e MYSQL_USER="zabbix" \
-e MYSQL_PASSWORD="123456" \
-e MYSQL_DATABASE="zabbix" \
-e ZBX_SERVER_HOST="zabbix-server" \
-e PHP_TZ="Asia/Shanghai" \
-p 8000:80 \
-p 8443:443 \
-d \
zabbix/zabbix-web-nginx-mysql
```

浏览器访问ip:8000查看
 默认登录
 username:Admin
 password:zabbix


### 复制代码到IDEA有行号

CTRL+R  ^[ 0-9] relace all狂点直到没有红
CTRL+R  ^[^\s*\n] relace all
CTRL+ALT+L 规范代码

### Openstack rebuild失败

试图重建快照时候，出现如下错误

```bash
Error: Failed to perform requested operation on instance "", the instance has an error status: Please try again later [Error: Build of instance aborted: Insufficient compute resources: Requested instance NUMA topology cannot fit the given host NUMA topology.].
```

背景：

为了提高部分CPU使用密集的虚拟机节点的性能，需要使vcpu一对一绑定并且独占宿主机上的真实cpu，flavour使用了如下参数

```bash
hw:cpu_policy 	dedicated
hw:cpu_threads_policy	isolate
```

经过调查，由于openstack的资源隔离是建立在numa的基础上的，所以设置了dedicated参数，之后必须在nova.conf中的scheduler_default_filters 中加入NUMATopologyFilter

https://docs.openstack.org/nova/pike/admin/configuration/schedulers.html


### WSL安装配置docker和k8s

[Running Kubernetes CLI on Windows Subsystem for Linux (WSL)]( https://devkimchi.com/2018/06/05/running-kubernetes-on-wsl/)

[Installing the Docker client on Windows Subsystem for Linux (Ubuntu)](https://medium.com/@sebagomez/installing-the-docker-client-on-ubuntus-windows-subsystem-for-linux-612b392a44c4)

```bash
echo "export DOCKER_HOST=localhost:2375" >> ~/.bash_profile
```

[Running Kubernetes Minikube on Windows 10 with WSL](https://www.jamessturtevant.com/posts/Running-Kubernetes-Minikube-on-Windows-10-with-WSL/)

### 不小心提交了不必要的配置到GIT仓库

撤回上一个提交
git reset --mixed  <上一个commit的id>
把线上的还原
git push origin origin --force


### win10查看ip地址

点开右下角网络图标，找到当前连接的网络，点击属性（properties）

### Openstack安装cinder服务没有磁盘设备

由于装机时把所有空间放在了一块物理盘上，没有预设到cinder服务基于LVM后端时，需要基于物理盘pvcreate 创建物理机，所以只能通过环设备创建一块假的物理盘，脚本如下：

```bash
#!/usr/bin/env bash
mkdir /vol
touch /vol/cinder-volumes
# seek=100代表创建100G模拟磁盘
dd if=/dev/zero of=/vol/cinder-volumes bs=1G count=0 seek=100
loopdev=$(losetup -f)
losetup $loopdev /vol/cinder-volumes
pvcreate $loopdev
vgcreate cinder-volumes $loopdev
pvdisplay
```



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

### Openstack安装keystone失败

```bash
[root@controller ~]# openstack token issue
An unexpected error prevented the server from fulfilling your request. (HTTP 500) (Request-ID: req-9b2cf24c-b63b-4f66-a069-abba4e3cb766)
```

```bash
vi /var/log/keystone/keystone.log 

2019-04-24 16:32:59.961 23037 ERROR keystone OperationalError: (pymysql.err.OperationalError) (1045, u"Access denied for user 'keystone'@'controller' (using password: YES)") (Background on this error at: http://sqlalche.me/e/e3q8)
```

发现是数据库认证问题，可是明明给keystone用户开权限了啊。经过多次测试，如果在mysql安全初始化时，不移除匿名用户、删除test数据库，就会出现以上授权问题

```bash
# mysql_secure_installation<<EOF
n
Y
Y
Y
Y
EOF
```

然后继续执行,查看keystone数据库中有没有表生成

```bash
su -s /bin/sh -c "keystone-manage db_sync" keystone
```




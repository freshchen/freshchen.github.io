# Trouble Shooting

### 1Openstack主机ssh虚拟机

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



### 2Openstack虚拟机网络MTU

在老版本的Openstack中，出现了虚拟机能ping通其他虚拟机但是ssh连接失败的情况，发现是虚拟机内部网络设备的MTU大于了主机上网络设备的MTU。以及网络设备eth0，主机MTU1450为例。

```bash
ip link set eth0 mtu 1450
```
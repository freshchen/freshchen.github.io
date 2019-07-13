---
title: REHL网络学习笔记
date: 2019-03-21 15:29:29
categories: Linux
top: 19
---


## 简介

工作中发现网络方面的基础比较重要，在这方面比较薄弱，决心好好学一波。本文主要是一些重要知识点的笔记，以及遇到过问题的解决记录。主要学习链接如下：

[红帽子7官方网络指南](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html/networking_guide/ch-configure_ip_networking)

## 常用命令

```
nmcli connection reload
```

```
nmcli con load /etc/sysconfig/network-scripts/ifcfg-ifname
```


# 1 下载文件显示无法下载
**问题描述**

nginx做反向代理，下载文件时firefox报错，提示源文件不可读

**问题分析**

首先检查nginx的错误日志，发现如下内容：

```
....open() "/opt/app/openresty/nginx/proxy_temp/5/19/0000000195" failed (13: Permission denied) while reading upstream, client:....
```
查看proxy_temp的权限，此目录的权限是700，所属用户：nobody ,所属组：root。但其下面的目录权限是700，所属用户是：root，所属组：root

**解决办法**

chown -R nobody:nobody /opt/app/openresty/nginx/proxy_temp/

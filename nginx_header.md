# 1 X-Forwarded-For

The **X-Forwarded-For** HTTP header field is a common method for identifying the originating IP address of a client connecting to a web server through a HTTP proxy or load balancer.

X-Forwarded-For is also an email-header indicating that an email-message was forwarded from  one or more other accounts(probably automatically).

## 1.1 Format

The general format of the field is:

```
X-Forwarded-For: client, proxy1, proxy2
```

where the value is a comma+space separated list of IP addresses. the left-most being the original client, and each successive proxy that passed the request adding the IP address where it received the request from. **In this example, the request passed through proxy1, proxy2, and then proxy(not shown in the header). proxy3 appears as remote address of the request.**

Since it is easy to forge an X-Forwarded-For field the given information should be used with care. The right-most IP address is always the IP address that connects to the last proxy, which means it is the most reliable source of information. X-Forwarded-For data can be used in a forward or reverse proxy scenario.

Just logging the X-Forwarded-For field is not always enough as the last proxy IP address  in a chain is not contained within the X-Forwarded-For field, it is in the actual IP header. A web server should log BOTH the request's source IP address and the X-Forwarded-For field information for completeness.

## 1.2 Get HTTP headers with tcpdump

```bash
sudo tcpdump -A -vvvv -s 9999 -i eth0 port 80 > /tmp/sample
```

## 1.3 Nginx Access Log: log the real user's IP instead of the proxy

If you're running Nginx behind a proxy or a caching engine like Varnish or Squid, you'll see your access logs get filled with lines that mention your Proxy or Caching engine's IP instead of the real user's IP address.

To change that, add the following line in your general nginx.conf in the **http{}** section.

```nginx
log_format main '$http_x_forwarded_for - $remote_user [$time_local] '
'"$request" $status $body_bytes_sent "$http_referer" '
'"$http_user_agent"';
```

The change there is that the standard **$remote_addr** is replaced by **$htp_x_forwarded_for** that your proxy/cache will pass along.

Somewhere along your config you'll have a line similar to this:

```nginx
access_log   /var/www/site/logs/access.log main;
```

Add the **main** parameter at the end , to tell nginx you're using that custom log format you created above.

## 1.4 Conclusion

1 X-Forwarded-For是一个课叠加的过程，后面的代理会把前面代理的IP加入X-Forwarded-For

2 应用服务器不可能从$http_x_forwarded_for拿到与它智联的服务器IP，此时可以使用$remote_addr。即当前服务器无法通过$http_x_forwarded_for获得上级代理或者客户端的IP，应该使用$remote_addr.




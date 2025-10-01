# Raspberry Pi

## INIT

- sudo update-alternatives --config editor
- sudo visudo > NOPASSWD
- sudo vim /etc/netplan/01-netcfg.yaml
- docker

## 更改 TTY 终端字体

```bash
sudo vim /etc/default/console-setup
# FONTSIZE="14*28"
```

## 更改 LS_COLORS 颜色

```bash
dircolors -p > ~/.dircolors
```

```vim
DIR 01;36 # directory
LINK 01;35 # symbolic link.
FIFO 40;33 # pipe
SOCK 01;32 # socket
DOOR 01;35 # door
```

## Basic Softwares

### shadowsocks-libev

```bash
# 根据文档: https://github.com/shadowsocks/shadowsocks-libev
# 建议使用 backports仓库 安装
# 请检查 /etc/apt/sources.list.d/ubuntu.sources 中的 Suites 除了 updates,security 之外是否存在 backports
```

```bash
# 更新系统软件包列表
$ sudo apt update
$ sudo apt upgrade
```

```bash
# 安装 shadowsocks-libev 和 simple-obfs
# -t noble-backports: 指定 APT 从 noble-backports 套件中安装软件包
$ sudo apt -t noble-backports install shadowsocks-libev simple-obfs
```

### shadowsocks-libev：ss-local vs. ss-redir

> $ man 8 shadowsocks-libev:
> 
> ss-local and ss-redir are clients on your local machines to proxy traffic(TCP/UDP or both).
> 
> ss-local: works as a standard socks5 proxy
> 
> ss-redir: works as a transparent proxy and requires netfilter’s NAT module

ss-redir 是 Shadowsocks-libev 中的一个组件，专为实现透明代理而设计。redir 是 “redirect”（重定向）的缩写，表示它的主要功能是 捕获并重定向网络流量。它能够拦截和重定向系统级的网络流量，通过 Shadowsocks 服务器代理转发到目标地址，从而实现无需在每个应用程序中手动配置代理的效果。

这种重定向功能通常通过 iptables 或其他流量管理工具实现，将系统中的网络流量转发到 ss-redir，然后通过 Shadowsocks 服务器进行代理。

### 基于 shadowsocks-libev.ss-redir 的透明代理

> 见[官方文档](https://github.com/shadowsocks/shadowsocks-libev/blob/master/doc/ss-redir.asciidoc#example)

```bash

# 在 iptables 命令中，-d 选项不能直接使用域名地址。它只能匹配基于 IP 地址的目标地址。
# 因此，在 iptables + ss-redir 的过程中，需要手动解析域名，使用 nslookup 或 dig 工具解析域名到 IP 地址，然后将解析到的 IP 地址用于 iptables

方法：
1. nslookup example.com
2. dig +short example.com

使用：将下面脚本中的 {MyIP} {MyPort} 更换为 shadowsocks 的 IP 与 Port 配置
```

```bash

#!/bin/bash

start_ssredir() {
    (ss-redir -b 127.0.0.1 -l 6200 --no-delay -u -T -v -c /etc/config/shadowsocks.json </dev/null &>>/var/log/ss-redir.log &)
}

stop_ssredir() {
    kill -9 $(pidof ss-redir) &>/dev/null
}

start_iptables() {
    ##################### SSREDIR #####################
    iptables -t mangle -N SSREDIR

    # connection-mark -> packet-mark
    iptables -t mangle -A SSREDIR -j CONNMARK --restore-mark
    iptables -t mangle -A SSREDIR -m mark --mark 0x2333 -j RETURN

    # please modify MyIP, MyPort, etc.
    # ignore traffic sent to ss-server
    iptables -t mangle -A SSREDIR -p tcp -d {MyIP} --dport {MyPort} -j RETURN
    iptables -t mangle -A SSREDIR -p udp -d {MyIP} --dport {MyPort} -j RETURN

    # ignore traffic sent to reserved addresses
    iptables -t mangle -A SSREDIR -d 0.0.0.0/8          -j RETURN
    iptables -t mangle -A SSREDIR -d 10.0.0.0/8         -j RETURN
    iptables -t mangle -A SSREDIR -d 100.64.0.0/10      -j RETURN
    iptables -t mangle -A SSREDIR -d 127.0.0.0/8        -j RETURN
    iptables -t mangle -A SSREDIR -d 169.254.0.0/16     -j RETURN
    iptables -t mangle -A SSREDIR -d 172.16.0.0/12      -j RETURN
    iptables -t mangle -A SSREDIR -d 192.0.0.0/24       -j RETURN
    iptables -t mangle -A SSREDIR -d 192.0.2.0/24       -j RETURN
    iptables -t mangle -A SSREDIR -d 192.88.99.0/24     -j RETURN
    iptables -t mangle -A SSREDIR -d 192.168.0.0/16     -j RETURN
    iptables -t mangle -A SSREDIR -d 198.18.0.0/15      -j RETURN
    iptables -t mangle -A SSREDIR -d 198.51.100.0/24    -j RETURN
    iptables -t mangle -A SSREDIR -d 203.0.113.0/24     -j RETURN
    iptables -t mangle -A SSREDIR -d 224.0.0.0/4        -j RETURN
    iptables -t mangle -A SSREDIR -d 240.0.0.0/4        -j RETURN
    iptables -t mangle -A SSREDIR -d 255.255.255.255/32 -j RETURN

    # mark the first packet of the connection
    iptables -t mangle -A SSREDIR -p tcp --syn                      -j MARK --set-mark 0x2333
    iptables -t mangle -A SSREDIR -p udp -m conntrack --ctstate NEW -j MARK --set-mark 0x2333

    # packet-mark -> connection-mark
    iptables -t mangle -A SSREDIR -j CONNMARK --save-mark

    ##################### OUTPUT #####################
    # proxy the outgoing traffic from this machine
    iptables -t mangle -A OUTPUT -p tcp -m addrtype --src-type LOCAL ! --dst-type LOCAL -j SSREDIR
    iptables -t mangle -A OUTPUT -p udp -m addrtype --src-type LOCAL ! --dst-type LOCAL -j SSREDIR

    ##################### PREROUTING #####################
    # proxy traffic passing through this machine (other->other)
    iptables -t mangle -A PREROUTING -p tcp -m addrtype ! --src-type LOCAL ! --dst-type LOCAL -j SSREDIR
    iptables -t mangle -A PREROUTING -p udp -m addrtype ! --src-type LOCAL ! --dst-type LOCAL -j SSREDIR

    # hand over the marked package to TPROXY for processing
    iptables -t mangle -A PREROUTING -p tcp -m mark --mark 0x2333 -j TPROXY --on-ip 127.0.0.1 --on-port 6200
    iptables -t mangle -A PREROUTING -p udp -m mark --mark 0x2333 -j TPROXY --on-ip 127.0.0.1 --on-port 6200
}

stop_iptables() {
    ##################### PREROUTING #####################
    iptables -t mangle -D PREROUTING -p tcp -m mark --mark 0x2333 -j TPROXY --on-ip 127.0.0.1 --on-port 6200 &>/dev/null
    iptables -t mangle -D PREROUTING -p udp -m mark --mark 0x2333 -j TPROXY --on-ip 127.0.0.1 --on-port 6200 &>/dev/null

    iptables -t mangle -D PREROUTING -p tcp -m addrtype ! --src-type LOCAL ! --dst-type LOCAL -j SSREDIR &>/dev/null
    iptables -t mangle -D PREROUTING -p udp -m addrtype ! --src-type LOCAL ! --dst-type LOCAL -j SSREDIR &>/dev/null

    ##################### OUTPUT #####################
    iptables -t mangle -D OUTPUT -p tcp -m addrtype --src-type LOCAL ! --dst-type LOCAL -j SSREDIR &>/dev/null
    iptables -t mangle -D OUTPUT -p udp -m addrtype --src-type LOCAL ! --dst-type LOCAL -j SSREDIR &>/dev/null

    ##################### SSREDIR #####################
    iptables -t mangle -F SSREDIR &>/dev/null
    iptables -t mangle -X SSREDIR &>/dev/null
}

start_iproute2() {
    ip route add local default dev lo table 100
    ip rule  add fwmark 0x2333        table 100
}

stop_iproute2() {
    ip rule  del   table 100 &>/dev/null
    ip route flush table 100 &>/dev/null
}

start_resolvconf() {
    # or nameserver 8.8.8.8, etc.
    echo "nameserver 1.1.1.1" >/etc/resolv.conf
}

stop_resolvconf() {
    echo "nameserver 114.114.114.114" >/etc/resolv.conf
}

start() {
    echo "start ..."
    start_ssredir
    start_iptables
    start_iproute2
    start_resolvconf
    echo "start end"
}

stop() {
    echo "stop ..."
    stop_resolvconf
    stop_iproute2
    stop_iptables
    stop_ssredir
    echo "stop end"
}

restart() {
    stop
    sleep 1
    start
}

main() {
    if [ $# -eq 0 ]; then
        echo "usage: $0 start|stop|restart ..."
        return 1
    fi

    for funcname in "$@"; do
        if [ "$(type -t $funcname)" != 'function' ]; then
            echo "'$funcname' not a shell function"
            return 1
        fi
    done

    for funcname in "$@"; do
        $funcname
    done
    return 0
}
main "$@"

```

```bash

# 检查当前的 IP 地址
$ curl http://ipinfo.io

# 检查国内网络
$ curl -I http://baidu.com

# 检查 Google 连接情况
$ curl -I https://google.com

```

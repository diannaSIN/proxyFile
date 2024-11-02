# 本文用来记录节点搭建的过程及方式

> 本文所有内容基本上不是自创来自github其他项目的教学、官方文档，以及一些博主的教学
>
> 本文所有过程来自于本人使用的debian12系统

* [Snell](## Snell)
* [Vless](## Vless)

## Snell

> [Snell官方文档](https://manual.nssurge.com/others/snell.html)

##### 需要先通过ssh链接vps，然后键入以下指令获取管理权限

```
sudo -i
```

##### 确保系统里面有vim、wget 及 unzip如果没有则执行以下指令进行下载

```
# 下载wget 及 unzip
sudo apt update && sudo apt install wget unzip
# 下载vim
apt install vim
```

##### 下载 Snell Server

* linux-amd64

```
wget https://dl.nssurge.com/snell/snell-server-v4.0.1-linux-amd64.zip
```

* ARM 机器

```
wget https://dl.nssurge.com/snell/snell-server-v4.0.1-linux-aarch64.zip
```

##### 解压 Snell Server 到置顶目录

* linux-amd64

```
sudo unzip snell-server-v4.0.1-linux-amd64.zip -d /usr/local/bin
```

* ARM

##### 赋予服务器权限

```
chmod +x /usr/local/bin/snell-server
```

##### Snell配置文件部分

* 创建配置文件夹

```
sudo mkdir /etc/snell
```

* 使用Snell的wizard生成一个配置文件

```
sudo snell-server --wizard -c /etc/snell/snell-server.conf
```

* （可选）如果觉得有需要的话可以自己编写一个配置文件

```
sudo vim /etc/snell/snell-server.conf
```

> 配置文件参数说明
>
> listen：监听地址及端口； psk：密钥； ipv6：系统自动生成的默认为false也就是关闭如果需要 IPv6 支持将值为 – true；

##### 配置Systemd服务文件

```
sudo vim /lib/systemd/system/snell.service
```

##### 将下面的内容写进去

```
[Unit]
Description=Snell Proxy Service
After=network.target

[Service]
Type=simple
User=nobody
Group=nogroup
LimitNOFILE=32768
ExecStart=/usr/local/bin/snell-server -c /etc/snell/snell-server.conf
AmbientCapabilities=CAP_NET_BIND_SERVICE
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=snell-server

[Install]
WantedBy=multi-user.target
```

##### Snell 系统操作

```
# 重载服务
sudo systemctl daemon-reload
# 设置开机自启动
sudo systemctl enable snell
# 开启Snell
sudo systemctl start snell
# 关闭Snell
sudo systemctl stop snell
# 查看Snell 状态    ps：按q可以退出查看
sudo systemctl status snell
```

##### 完成以上步骤就算搭建完成了，执行如下操作使用Surge连接节点

1. 查看自己的Snell配置

```
cat /etc/snell/snell-server.conf
```

2. 在Surge中填写配置中的字段

```
## 如果要直接在配置文件中添加使用如下格式
vpsname = snell, XXX.XXX.XXX.XXX, 11807, psk=psk, version=4, tfo=true
```

>  ##### 如果觉得麻烦就使用一键脚本（不推荐）
>
> ```
> wget -O snell.sh --no-check-certificate https://raw.githubusercontent.com/getsomecat/Snell/master/snell_new.sh && chmod +x snell.sh && ./snell.sh
> ```

## Vless

### Vless Reality

#####  BBR开启和选择模式脚本 （我选14：BBR2+FQ）

```
wget -N --no-check-certificate "https://github.000060000.xyz/tcpx.sh" && chmod +x tcpx.sh && ./tcpx.sh 
```

##### 运行BBR优化脚本（运行脚本之后先选2再运行选3）

```
bash <(curl -Ls https://github.com/lanziii/bbr-/releases/download/123/tools.sh)
```

##### 安装3x-ui(3x-ui是用来创建节点的面板)

```
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
```

##### 运行脚本后会有如下提示，键入`y`然后回车；意思是是否需要自定义配置

```
Do you want to continue with the modification y/n?
```

##### 会接连出现如下需要自定义的配置

```
Please set up your username: 后面输入要设置的面板用户名
Please set up your password: 后面输入要设置的面板密码
Please set up the panel port: 后面输入你要设置的面板端口
```

##### 面板创建完成

##### 接下来需要进入3x-ui的网页端管理创建节点

##### 在浏览器地址栏按照如下格式输入面板地址

```
ip:port/面板路径
```

##### 进入面板后选择入站列表，然后点击添加入站就可以添加节点

协议选择 **Vless**,

安全选择**Reality**

用户的**flow**选项选择**xtls-rprx-vision**

uTLS选择**chrome**可以根据自己的喜好选别的

点击最下方 **Get New Cert**获取公钥和私钥即可确定创建


# NAT VPS 三网线路探测器

一个适合小内存 NAT VPS 的轻量级三网线路探测脚本。它使用系统已有的 `traceroute`、`curl`、`wget` 和 `awk`，不需要安装 Go、Node.js 或 Python。

已在 Alpine Linux 3.21 的纳泰云美国 NAT VPS 上验证运行，也兼容常见 Debian 系统。

## 快速开始

下载脚本并运行：

```sh
curl -fsSL https://raw.githubusercontent.com/bobvhfhh/natai-line-test/main/natai-line-test.sh -o natai-line-test.sh
chmod +x natai-line-test.sh
./natai-line-test.sh --quick
```

如果服务器没有 `curl`，可以使用 `wget`：

```sh
wget -O natai-line-test.sh https://raw.githubusercontent.com/bobvhfhh/natai-line-test/main/natai-line-test.sh
chmod +x natai-line-test.sh
./natai-line-test.sh --quick
```

## 常用用法

快速模式：每个运营商测试一个目标，适合先看大致线路。

```sh
./natai-line-test.sh --quick
```

完整模式：电信、联通、移动各测试两个目标。

```sh
./natai-line-test.sh --full
```

降低等待时间、限制最大跳数：

```sh
./natai-line-test.sh --full --timeout 1 --hops 8
```

只测试一个目标：

```sh
./natai-line-test.sh --target 联通北京
./natai-line-test.sh --target 123.125.99.1
```

查看全部参数：

```sh
./natai-line-test.sh --help
```

## 参数说明

| 参数 | 说明 |
| --- | --- |
| `--quick` | 每个运营商只测试一个目标 |
| `--full` | 测试全部内置目标 |
| `--target NAME` | 只测试指定名称或 IP |
| `--timeout SEC` | 每跳等待秒数，默认 `3` |
| `--hops N` | 最大跳数，默认 `12` |
| `--help` | 显示帮助 |
| `--version` | 显示版本 |

## 输出怎么看

- `本机出口`：服务器通过公网访问时看到的出口 IP。
- 每个目标下面的数字行：从 VPS 到目标的逐跳路径。
- `*`：该跳没有返回探测包，不代表线路一定中断。
- `10.x.x.x`、`192.168.x.x` 等私网地址：通常是 NAT 容器到宿主机或上游网关的内部跳点。
- `无响应或被 NAT/防火墙过滤`：目标或中间网络过滤了 traceroute 探测包。

## NAT VPS 限制

NAT VPS 经常隐藏上游路由、过滤 ICMP/UDP 或限制 traceroute。脚本因此采用低并发、单探针设计，不会因为探测失败修改网络配置，也不会安装大型依赖。

如果只看到第一跳私网网关和后面大量 `*`，这是 NAT 环境的常见结果。可以尝试：

```sh
./natai-line-test.sh --full --timeout 1 --hops 16
```

## 内置目标

- 电信：上海、广州
- 联通：北京、上海
- 移动：北京、广州

目标是用于判断不同运营商方向的大致路径，不是带宽、延迟或跨网质量的完整基准测试。

## 许可证

MIT

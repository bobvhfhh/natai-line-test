# 河南三网线路检测器

这个脚本专门用于小内存 NAT VPS，只检测河南省三网回程线路，并复用 TcpQuality 的线路识别逻辑。输出中的线路标签包括 `CN2GIA`、`CN2GT`、`9929`、`4837`、`163`、`CMI`、`CMIN2` 等。

## 一行运行

默认只做线路识别：

```sh
curl -fsSL https://raw.githubusercontent.com/bobvhfhh/natai-line-test/main/natai-line-test.sh | sh
```

追加河南节点 TCP 延迟/丢包：

```sh
curl -fsSL https://raw.githubusercontent.com/bobvhfhh/natai-line-test/main/natai-line-test.sh | sh -s -- --full
```

查看帮助：

```sh
curl -fsSL https://raw.githubusercontent.com/bobvhfhh/natai-line-test/main/natai-line-test.sh | sh -s -- --help
```

## 输出含义

- `CN2GIA` / `CN2GT`：电信 CN2 线路。
- `9929`：联通 9929 高端骨干。
- `4837`：联通 4837 普通骨干。
- `163`：电信传统 163 骨干。
- `CMI` / `CMIN2`：中国移动国际及高端线路。
- `Hidden`：路径被 NAT、防火墙或目标网络隐藏，不能据此断言线路类型。

## 参数

| 参数 | 作用 |
| --- | --- |
| 无参数 | 河南 IPv4 三网 TCP 回程线路识别 |
| `--full` | 线路识别后追加低并发 TCP 延迟/丢包探测 |
| `--debug` | 输出 TcpQuality 调试信息 |
| `--help` | 显示帮助 |

## Alpine 依赖

脚本需要 `curl` 和 `bash`。如果系统没有：

```sh
apk add --no-cache curl bash
```

TcpQuality 的线路识别还会使用 `traceroute`；纳泰云当前已安装。如果没有，安装：

```sh
apk add --no-cache traceroute
```

## 注意

NAT VPS 只能从自身出口发起探测；如果上游隐藏了路径，可能显示 `Hidden`。这不是线路不存在，而是中间设备没有返回足够的路由信息。

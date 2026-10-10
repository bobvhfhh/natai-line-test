# 纳泰云 NAT 小鸡三网线路探测

脚本：`natai-line-test.sh`

在 VPS 上直接运行：

```sh
chmod +x /root/natai-line-test.sh
/root/natai-line-test.sh --quick
```

完整测试：

```sh
/root/natai-line-test.sh --full --timeout 2 --hops 16
```

说明：NAT 容器常见情况是上游网关隐藏后续跳数，且 ICMP/UDP 被过滤。脚本不安装依赖，优先使用系统自带 traceroute；输出中的 `*` 或只显示私网跳数不代表没有线路，只表示该探测包没有收到回包。

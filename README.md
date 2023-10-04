# rootless_caddy_manager

## caddy 自动构建 builder.sh

这个脚本无需 root，有 go 环境会用 go 编译，没 go 就在 `$HOME/GO` 装一个 go 临时用于编译。直接运行就可以在当前目录下获得一个 caddy 二进制。

这个脚本会在运行目录放 `plugins` `builder.sh` `caddy` 三个文件，`plugins` 文件里是一个数组，如果你想在编译的时候加插件，就往这里面写，具体写法看 plugins 文件，是示例，`builder.sh` 是脚本本体。因为会生成一些文件在运行目录，所以建议新建文件夹运行脚本。

这个命令会在 `$HOME/CADDY` 运行脚本。

```
mkdir -p ~/CADDY && cd ~/CADDY && bash <(curl https://raw.githubusercontent.com/AsenHu/rootless_caddy_manager/main/builder.sh)
```

记得写个 crontab 定时运行这个脚本

```
# 每天凌晨四点运行一次 builder.sh
0 4 * * * /bin/bash /home/<你的用户名>/CADDY/builder.sh
```

## 自动更新 caddy 为最新的编译版本 systemd.sh

仅支持 systemd

随便找个目录下载进去，用 crontab 每天运行就行了。只有在确定有更新的时候才会替换。脚本第一个参数必须传入，这里是构建好的 caddy 二进制文件，第二个参数是 bin 下面的 caddy 二进制文件，默认 `/user/bin/caddy`

直接安装 + 运行

```
cd ~ && bash <(curl https://raw.githubusercontent.com/AsenHu/rootless_caddy_manager/main/systemd.sh) /home/<你的用户名>/CADDY/caddy /user/bin/caddy
```

crontab
```
# 每天凌晨四点半运行一次
30 4 * * * /bin/bash /root/systemd.sh /home/<你的用户名>/CADDY/caddy /user/bin/caddy
```

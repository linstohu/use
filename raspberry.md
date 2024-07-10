## Raspberry Pi

### 更改 TTY 终端字体

```bash
sudo vim /etc/default/console-setup
# FONTSIZE="14*28"
```

### 更改 LS_COLORS 颜色

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

#!/bin/sh

# === 配置区域 ===
VPS_IP="198.23.236.26" # ← 替换为你的 VPS IP
VPS_USER="root"  # 假设 VPS 用户是 root
BASE_DIR="/root" # VPS 端 base 路径

# === 检测平台 ===
if [ -f /etc/os-release ]; then
    PLATFORM="linux"
else
    PLATFORM="android"
fi

# === 参数解析 ===
ACTION="$1"
PKG="$2"

if [ -z "$ACTION" ] || [ -z "$PKG" ]; then
    echo "用法: sh $0 [upload|download] 包名"
    exit 1
fi

# === 应用路径预设 ===
case "$PKG" in
    org.flos.phira)
        if [ "$PLATFORM" = "linux" ]; then
            echo "$PKG 不支持平台: $PLATFORM"
        fi
        PATH_LIST="
        /data/data/$PKG
        "
        ;;
    me.tigerhix.cytoid)
        if [ "$PLATFORM" = "linux" ]; then
            echo "$PKG 不支持平台: $PLATFORM"
        fi
        PATH_LIST="
        /sdcard/Android/data/$PKG
        "
        ;;
    ru.nsu.ccfit.zuev.osuplus)
        if [ "$PLATFORM" = "linux" ]; then
            echo "$PKG 不支持平台: $PLATFORM"
        fi
        PATH_LIST="
        /data/data/$PKG
        /sdcard/osu!droid
        "
        ;;
    osu)
        if [ "$PLATFORM" = "android" ]; then
            echo "$PKG 不支持平台: $PLATFORM"
        fi
        PATH_LIST="
        /home/ashkore/.local/share/osu
        "
        ;;
    *)
        echo "未配置的包名: $PKG"
        exit 1
        ;;
esac


# === 开始同步 ===
for LOCAL_PATH in $PATH_LIST; do
    # 将路径转为 VPS 上用的目录名，例如 sdcard_Android_data_pkgname
    SUB_PATH=$(echo "$LOCAL_PATH" | sed "s|^/||" | sed "s|/|_|g")
    REMOTE_PATH="$BASE_DIR/$PKG/$SUB_PATH"

    if [ "$ACTION" = "upload" ]; then
        echo "↑ 上传 $LOCAL_PATH → $VPS_USER@$VPS_IP:$REMOTE_PATH"
        # VPS 远程路径不存在时创建
        ssh "$VPS_USER@$VPS_IP" "mkdir -p $REMOTE_PATH"
        # 执行 rsync 上传
        rsync -avr "$LOCAL_PATH/" "$VPS_USER@$VPS_IP:$REMOTE_PATH"

    elif [ "$ACTION" = "download" ]; then
        echo "↓ 下载 $VPS_USER@$VPS_IP:$REMOTE_PATH → $LOCAL_PATH"
        # 本地路径不存在时创建
        if [ ! -d "$LOCAL_PATH" ]; then
            mkdir -p "$LOCAL_PATH"
        fi
        # 执行 rsync 下载
        rsync -avr "$VPS_USER@$VPS_IP:$REMOTE_PATH" "$LOCAL_PATH/"

    else
        echo "未知操作: $ACTION"
        exit 1
    fi
done

#!/bin/bash

# 获取当前 screen 会话
SESSION=$(screen -ls | grep -E '[0-9]+\.terraria' | grep -oE '^[0-9]+\.terraria' | head -1)

if [ -z "$SESSION" ]; then
    echo "❌ 错误: 没有找到 terraria screen 会话"
    echo "当前会话列表:"
    screen -ls
    exit 1
fi

if [ -z "$1" ]; then
    echo "用法: $0 \"公告内容\""
    echo "示例: $0 \"服务器即将重启\""
    exit 1
fi

# 发送公告
screen -S "$SESSION" -X stuff "say $1\n"
echo "✅ 公告已发送: $1"
echo "📺 会话: $SESSION"

#!/bin/bash

# 备份目录
BACKUP_ROOT="/root/tmod_backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/terraria_$TIMESTAMP"

# 创建备份目录
mkdir -p "$BACKUP_DIR"
echo "📦 Backing up to: $BACKUP_DIR"

# 备份存档
if [ -d "/root/.local/share/Terraria" ]; then
    cp -r /root/.local/share/Terraria/* "$BACKUP_DIR/"
    echo "✅ Backup completed successfully"
else
    echo "⚠️ No Terraria save data found to backup"
    # 创建空标记文件
    touch "$BACKUP_DIR/NO_DATA_FOUND"
fi

# 保留最近 7 个备份
ls -dt "$BACKUP_ROOT"/terraria_* 2>/dev/null | tail -n +8 | while read old_backup; do
    echo "🗑️ Removing old backup: $old_backup"
    rm -rf "$old_backup"
done

echo "📊 Total backups: $(ls -d $BACKUP_ROOT/terraria_* 2>/dev/null | wc -l)"

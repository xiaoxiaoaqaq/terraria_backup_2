#!/bin/bash

GIT_DIR="/root/tmod_backup_git"
WORLD_DIR="/root/.local/share/Terraria/Worlds"
BACKUP_DIR="/root/tmod_backup_git"
LOG_FILE="/var/log/terraria_backup.log"
ZIP_NAME="worlds_backup_$(date +%Y%m%d_%H%M%S).zip"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log "========================================"
log "Starting Terraria Git Backup (ZIP mode)"

# 进入 Git 仓库
cd "$GIT_DIR" || {
    log "ERROR: Cannot enter $GIT_DIR"
    exit 1
}

# 拉取最新更改
log "Pulling latest changes..."
git pull origin main 2>/dev/null || git pull origin master 2>/dev/null

# 检查世界目录是否存在
if [ ! -d "$WORLD_DIR" ]; then
    log "WARNING: No Terraria worlds found at $WORLD_DIR"
    exit 0
fi

# 删除旧的 zip 文件（保留最近 7 个）
log "Cleaning old zip files..."
ls -t "$BACKUP_DIR"/worlds_backup_*.zip 2>/dev/null | tail -n +8 | xargs rm -f 2>/dev/null

# 打包 Worlds 目录
log "Creating ZIP: $ZIP_NAME"
cd /root/.local/share/Terraria || exit 1
zip -r "$BACKUP_DIR/$ZIP_NAME" Worlds/ -q
log "✅ ZIP created: $ZIP_NAME ($(du -h "$BACKUP_DIR/$ZIP_NAME" | cut -f1))"

# 进入 Git 仓库
cd "$GIT_DIR" || exit 1

# 删除旧的世界文件（只保留 zip）
find "$GIT_DIR" -maxdepth 1 -type f ! -name "*.zip" ! -name ".git" -delete 2>/dev/null
find "$GIT_DIR" -type d -name "Worlds" -exec rm -rf {} + 2>/dev/null

# 添加并提交
git add -A
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
COMMIT_MSG="Backup: $TIMESTAMP"

if git commit -m "$COMMIT_MSG" 2>/dev/null; then
    log "✅ Committed: $COMMIT_MSG"
    git push origin main 2>/dev/null || git push origin master 2>/dev/null
    log "✅ Pushed to GitHub"
else
    # 如果没有变更，创建空提交
    log "No changes, creating heartbeat commit"
    git commit --allow-empty -m "Heartbeat: $TIMESTAMP"
    git push origin main 2>/dev/null || git push origin master 2>/dev/null
    log "✅ Heartbeat pushed"
fi

# 显示最新状态
log "Latest: $(git log -1 --oneline)"
log "Backup completed successfully"
log "========================================"

exit 0

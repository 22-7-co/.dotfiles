#!/usr/bin/env bash

# 1. 变量准备
SOURCE_JSON="../../translations/en_US.json"
TEMP_DIR="./translate_batches"
RESULT_DIR="./translated_results"
TARGET_FILE="$HOME/.config/illogical-impulse/translations/zh_CN.json"

# 如果是第一次运行，清理旧碎片。如果想断点续传，可以注释掉这行。
# rm -rf "$TEMP_DIR" "$RESULT_DIR"
mkdir -p "$TEMP_DIR" "$RESULT_DIR"

# 物理备份原文件
cp "$SOURCE_JSON" "${SOURCE_JSON}.bak"

# 2. 将大 JSON 拆分成小块 (每 500 行一个文件)
echo "正在切分大文件..."
jq -c 'to_entries | .[]' "$SOURCE_JSON" | split -l 500 - "$TEMP_DIR/part_"

# 3. 循环调用翻译脚本
count=1
for part in "$TEMP_DIR"/part_*; do
  echo "--------------------------------------------"
  echo "正在处理第 $count 组 (文件: $part)..."

  # 将切片转换回 JSON 格式供脚本读取
  cat "$part" | jq -s 'from_entries' >"$SOURCE_JSON"

  # ================= 【核心改进：自动重试逻辑】 =================
  MAX_RETRIES=5      # 最大重试次数
  RETRY_COUNT=0      # 当前重试计数
  SUCCESS=false      # 成功标记

  while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    # 翻译前先删掉目标文件，确保检测到的是最新生成的
    rm -f "$TARGET_FILE"

    # 调用翻译脚本
    bash ./gemini-translate.sh zh_CN gemini-2.5-flash-lite

    # 检查结果：文件存在且大小大于 0 字节
    if [[ -s "$TARGET_FILE" ]]; then
      SUCCESS=true
      echo "✅ 第 $count 组翻译成功！"
      break
    else
      ((RETRY_COUNT++))
      echo "⚠️ 第 $count 组失败 (可能由于 503/429)。"
      if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
        WAIT_TIME=$((RETRY_COUNT * 15)) # 递增等待时间：15s, 30s, 45s...
        echo "等待 ${WAIT_TIME} 秒后进行第 ${RETRY_COUNT}/${MAX_RETRIES} 次重试..."
        sleep $WAIT_TIME
      fi
    fi
  done

  # 如果重试多次依然失败，才彻底停止
  if [ "$SUCCESS" = false ]; then
    echo "❌ 第 $count 组连续 $MAX_RETRIES 次失败。请检查网络或 API 状态后重试。"
    mv "${SOURCE_JSON}.bak" "$SOURCE_JSON"
    exit 1
  fi
  # ============================================================

  # 备份这组翻译好的结果
  cp "$TARGET_FILE" "$RESULT_DIR/zh_part_$count.json"

  ((count++))
  sleep 2 # 每组之间留一点固定间隙
done

# 4. 合并所有结果
echo "--------------------------------------------"
echo "正在合并所有翻译片段..."
# 使用更健壮的合并方式，防止 null
jq -s 'add' "$RESULT_DIR"/zh_part_*.json > "$TARGET_FILE"

# 5. 恢复原始 en_US.json
mv "${SOURCE_JSON}.bak" "$SOURCE_JSON"

echo "🎉 全部翻译任务完成！汉化文件已就绪：$TARGET_FILE"

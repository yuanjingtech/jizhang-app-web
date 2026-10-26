#!/usr/bin/env bash
# 远景记账落地页 · 上线前自检
# 用法：在 jizhang-app-web 目录下执行 ./scripts/check.sh
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

fail=0
ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$1"; fail=$((fail + 1)); }
info() { printf '  \033[33m!\033[0m %s\n' "$1"; }

echo "── 1. 必要文件 ──"
for f in index.html assets/styles.css assets/app.js assets/favicon.svg README.md; do
  if [ -f "$f" ]; then ok "$f"; else bad "缺少 $f"; fi
done

echo "── 2. 资源引用可解析 ──"
# 从 index.html 里抽出本地资源路径，逐个确认存在
for ref in $(grep -oE '(src|href)="[^"#:]+"' index.html | sed -E 's/.*="//; s/"$//' | grep -vE '^(https?:|mailto:|tel:)' | sort -u); do
  if [ -f "$ref" ]; then ok "$ref"; else bad "引用了不存在的文件：$ref"; fi
done

echo "── 3. 页内锚点都有落点 ──"
for id in $(grep -oE 'href="#[^"]+"' index.html | sed -E 's/href="#//; s/"$//' | sort -u); do
  if grep -qE "id=\"$id\"" index.html; then ok "#$id"; else bad "锚点 #$id 没有对应的 id"; fi
done

echo "── 4. 没有空链接 ──"
if grep -qE 'href="#"' index.html; then
  bad '存在 href="#" 的空链接'
else
  ok '无 href="#" 空链接'
fi

echo "── 5. 过期二维码没有被塞进页面 ──"
# docs 里那张体验版二维码标注「3月5日前有效」，不应出现在页面上
if grep -qE '3月5日|二维码3月' index.html; then
  bad '页面里出现了已过期的二维码说明'
else
  ok '未引用过期二维码'
fi

echo "── 6. 二维码状态 ──"
if [ -f assets/qr-code.png ]; then
  ok 'assets/qr-code.png 已存在'
  if grep -q 'qr-placeholder' index.html; then
    info '二维码图片已就位，但 index.html 仍是占位块 —— 按 README「上线前必做」换成 <img>'
  else
    ok 'index.html 已使用二维码图片'
  fi
else
  info 'assets/qr-code.png 尚未提供（占位块照常显示）—— 上线前必须补，见 README'
fi

echo "── 7. 文案红线 ──"
if grep -qE '保证不超时|永不丢|100% 安全' index.html; then
  bad '出现了绝对化承诺（保证不超时 / 永不丢 / 100% 安全）'
else
  ok '无绝对化承诺'
fi
if grep -q '不是投资建议' index.html; then
  ok '保留了「预测不是投资建议」的免责说明'
else
  bad '缺少「预测不是投资建议」的免责说明'
fi

echo
if [ "$fail" -eq 0 ]; then
  printf '\033[32m全部通过\033[0m\n'
  exit 0
else
  printf '\033[31m%d 项未通过\033[0m\n' "$fail"
  exit 1
fi

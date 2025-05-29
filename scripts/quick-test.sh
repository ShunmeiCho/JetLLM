#!/bin/bash

# Jetson Ollama 快速功能测试脚本
# 用于验证jetson-containers和ollama的各项功能

echo "🚀 Jetson Ollama 快速功能测试"
echo "=============================="
echo "时间: $(date)"
echo

# 1. 检查autotag功能
echo "1️⃣ 测试autotag功能"
echo "▶️ 执行: autotag ollama"
autotag ollama
echo

# 2. 检查容器状态
echo "2️⃣ 检查容器状态"
echo "▶️ 执行: docker ps | grep ollama"
docker ps | grep ollama
if [ $? -eq 0 ]; then
    echo "✅ Ollama容器正在运行"
else
    echo "❌ Ollama容器未运行"
fi
echo

# 3. 检查API可用性
echo "3️⃣ 测试API可用性"
echo "▶️ 执行: curl -s http://localhost:11434/api/tags"
API_RESPONSE=$(curl -s http://localhost:11434/api/tags)
if [ $? -eq 0 ] && [[ $API_RESPONSE == *"models"* ]]; then
    echo "✅ Ollama API正常响应"
    echo "📋 可用模型数量: $(echo $API_RESPONSE | grep -o '"name"' | wc -l)"
else
    echo "❌ Ollama API无响应"
fi
echo

# 4. 检查GPU状态
echo "4️⃣ 检查GPU状态"
echo "▶️ 执行: docker exec ollama-container nvidia-smi"
docker exec ollama-container nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
if [ $? -eq 0 ]; then
    echo "✅ GPU在容器内正常工作"
else
    echo "❌ GPU在容器内不可用"
fi
echo

# 5. 快速推理测试
echo "5️⃣ 快速推理测试"
echo "▶️ 测试简单推理..."
INFERENCE_RESULT=$(curl -s -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model": "smollm2:135m", "prompt": "Hello", "stream": false}' | head -c 100)

if [[ $INFERENCE_RESULT == *"response"* ]]; then
    echo "✅ 推理功能正常"
else
    echo "❌ 推理功能异常"
fi
echo

# 6. 系统资源使用
echo "6️⃣ 系统资源使用"
echo "▶️ 内存使用情况:"
free -h | head -2
echo "▶️ 磁盘使用情况:"
df -h | grep -E "(文件系统|Filesystem|/dev/)"
echo

echo "🎯 测试完成！"
echo "如果所有项目都显示 ✅，说明系统运行正常。"
echo "如果有 ❌ 项目，请参考部署日志进行故障排除。" 
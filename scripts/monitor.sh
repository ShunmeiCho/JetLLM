#!/bin/bash

# Jetson Qwen部署监控脚本
# 使用方法: ./monitor.sh [间隔秒数，默认5秒]

INTERVAL=${1:-5}

echo "=== Jetson Orin Nano 监控启动 ==="
echo "监控间隔: ${INTERVAL}秒"
echo "按 Ctrl+C 停止监控"
echo "================================"

while true; do
    clear
    echo "=== Jetson Qwen部署监控 $(date) ==="
    echo
    
    echo "📊 系统资源使用情况:"
    echo "----------------------"
    echo "内存使用:"
    free -h | head -2
    echo
    
    echo "磁盘使用:"
    df -h / | tail -1
    echo
    
    echo "🎮 GPU状态:"
    echo "----------------------"
    if command -v nvidia-smi &> /dev/null; then
        nvidia-smi --query-gpu=name,memory.used,memory.total,utilization.gpu,temperature.gpu --format=csv,noheader,nounits
    else
        echo "nvidia-smi 未找到"
    fi
    echo
    
    echo "🐳 Docker容器状态:"
    echo "----------------------"
    if command -v docker &> /dev/null; then
        if docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -q ollama; then
            docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(NAMES|ollama)"
            echo
            echo "Ollama容器资源使用:"
            docker stats ollama --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
        else
            echo "未发现正在运行的Ollama容器"
        fi
    else
        echo "Docker 未安装或无权限访问"
    fi
    echo
    
    echo "🌡️ 系统温度:"
    echo "----------------------"
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        temp=$(cat /sys/class/thermal/thermal_zone0/temp)
        temp_c=$((temp/1000))
        echo "CPU温度: ${temp_c}°C"
    fi
    
    if [ -f /sys/class/thermal/thermal_zone1/temp ]; then
        temp=$(cat /sys/class/thermal/thermal_zone1/temp)
        temp_c=$((temp/1000))
        echo "GPU温度: ${temp_c}°C"
    fi
    echo
    
    echo "🔄 网络连接测试:"
    echo "----------------------"
    if curl -s --max-time 2 http://localhost:11434/api/tags > /dev/null 2>&1; then
        echo "✅ Ollama API 可访问 (localhost:11434)"
    else
        echo "❌ Ollama API 不可访问"
    fi
    
    echo
    echo "================================"
    echo "下次更新: ${INTERVAL}秒后 (Ctrl+C 停止)"
    sleep $INTERVAL
done 
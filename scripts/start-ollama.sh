#!/bin/bash

# Jetson Ollama 便捷启动脚本
# 自动检查并启动ollama容器

echo "🚀 启动 Jetson Ollama 服务"
echo "=========================="

# 检查是否已有ollama容器在运行
RUNNING_CONTAINERS=$(docker ps --filter "ancestor=ollama:r36.2.0-cu122-22.04" --format "{{.Names}}")

if [ ! -z "$RUNNING_CONTAINERS" ]; then
    echo "📋 发现已运行的容器："
    echo "$RUNNING_CONTAINERS"
    echo
    echo "选择操作："
    echo "1) 进入现有容器"
    echo "2) 停止现有容器并启动新的"
    echo "3) 启动新容器（并行运行）"
    echo "4) 退出"
    read -p "请选择 (1-4): " choice
    
    case $choice in
        1)
            CONTAINER_NAME=$(echo "$RUNNING_CONTAINERS" | head -1)
            echo "🔗 进入容器: $CONTAINER_NAME"
            docker exec -it $CONTAINER_NAME /bin/bash
            ;;
        2)
            echo "🛑 停止现有容器..."
            echo "$RUNNING_CONTAINERS" | xargs docker stop
            echo "$RUNNING_CONTAINERS" | xargs docker rm
            echo "🚀 启动新容器..."
            jetson-containers run -it --name ollama-main $(autotag ollama)
            ;;
        3)
            echo "🚀 启动新容器（并行模式）..."
            jetson-containers run -it $(autotag ollama)
            ;;
        4)
            echo "👋 退出"
            exit 0
            ;;
        *)
            echo "❌ 无效选择"
            exit 1
            ;;
    esac
else
    echo "🚀 启动新的 Ollama 容器..."
    jetson-containers run -it --name ollama-main $(autotag ollama)
fi 
#!/bin/bash

# Qwen模型功能测试脚本
# 使用方法: ./test_qwen.sh [模型名称]

MODEL_NAME=${1:-"qwen2.5:1.5b"}
API_URL="http://localhost:11434"

echo "=== Qwen模型功能测试 ==="
echo "测试模型: $MODEL_NAME"
echo "API地址: $API_URL"
echo "开始时间: $(date)"
echo "========================"

# 函数：测试API连接
test_api_connection() {
    echo "🔗 测试1: API连接测试"
    echo "----------------------"
    
    if curl -s --max-time 5 "$API_URL/api/tags" > /dev/null; then
        echo "✅ Ollama API 连接正常"
        return 0
    else
        echo "❌ Ollama API 连接失败"
        echo "请确保Ollama服务正在运行"
        return 1
    fi
}

# 函数：测试模型是否可用
test_model_availability() {
    echo
    echo "📋 测试2: 模型可用性检查"
    echo "------------------------"
    
    models=$(curl -s "$API_URL/api/tags" 2>/dev/null | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
    
    if echo "$models" | grep -q "$MODEL_NAME"; then
        echo "✅ 模型 '$MODEL_NAME' 已安装"
        return 0
    else
        echo "❌ 模型 '$MODEL_NAME' 未找到"
        echo "可用模型列表:"
        echo "$models"
        return 1
    fi
}

# 函数：基础推理测试
test_basic_inference() {
    echo
    echo "🧠 测试3: 基础推理测试"
    echo "---------------------"
    
    echo "测试问题: '你好，请简单介绍一下自己'"
    echo "开始时间: $(date)"
    
    start_time=$(date +%s)
    
    response=$(curl -s -X POST "$API_URL/api/generate" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"$MODEL_NAME\",
            \"prompt\": \"你好，请简单介绍一下自己\",
            \"stream\": false
        }" 2>/dev/null)
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        # 提取回复内容
        reply=$(echo "$response" | grep -o '"response":"[^"]*"' | cut -d'"' -f4 | head -1)
        
        echo "✅ 推理测试成功"
        echo "响应时间: ${duration}秒"
        echo "模型回复: $reply"
        return 0
    else
        echo "❌ 推理测试失败"
        echo "错误信息: $response"
        return 1
    fi
}

# 函数：代码生成测试
test_code_generation() {
    echo
    echo "💻 测试4: 代码生成测试"
    echo "---------------------"
    
    echo "测试问题: '用Python写一个计算斐波那契数列的函数'"
    echo "开始时间: $(date)"
    
    start_time=$(date +%s)
    
    response=$(curl -s -X POST "$API_URL/api/generate" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"$MODEL_NAME\",
            \"prompt\": \"用Python写一个计算斐波那契数列的函数，要求简洁清晰\",
            \"stream\": false
        }" 2>/dev/null)
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        reply=$(echo "$response" | grep -o '"response":"[^"]*"' | cut -d'"' -f4 | head -1)
        
        echo "✅ 代码生成测试成功"
        echo "响应时间: ${duration}秒"
        echo "生成的代码: $reply"
        return 0
    else
        echo "❌ 代码生成测试失败"
        echo "错误信息: $response"
        return 1
    fi
}

# 函数：性能压力测试
test_performance() {
    echo
    echo "⚡ 测试5: 性能压力测试"
    echo "---------------------"
    
    echo "执行5次连续推理测试..."
    
    total_time=0
    success_count=0
    
    for i in {1..5}; do
        echo "第 $i 次测试..."
        start_time=$(date +%s)
        
        response=$(curl -s -X POST "$API_URL/api/generate" \
            -H "Content-Type: application/json" \
            -d "{
                \"model\": \"$MODEL_NAME\",
                \"prompt\": \"请用一句话总结人工智能的发展\",
                \"stream\": false
            }" 2>/dev/null)
        
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        total_time=$((total_time + duration))
        
        if [ $? -eq 0 ] && [ -n "$response" ]; then
            success_count=$((success_count + 1))
            echo "  ✅ 第 $i 次成功 (${duration}秒)"
        else
            echo "  ❌ 第 $i 次失败"
        fi
    done
    
    if [ $success_count -gt 0 ]; then
        avg_time=$((total_time / success_count))
        echo "📊 性能统计:"
        echo "  成功次数: $success_count/5"
        echo "  平均响应时间: ${avg_time}秒"
        echo "  总计用时: ${total_time}秒"
    else
        echo "❌ 所有性能测试都失败了"
        return 1
    fi
}

# 主测试流程
main() {
    echo "开始运行测试套件..."
    echo
    
    # 运行所有测试
    test_api_connection || exit 1
    test_model_availability || exit 1
    test_basic_inference || exit 1
    test_code_generation || exit 1
    test_performance || exit 1
    
    echo
    echo "==========================="
    echo "✅ 所有测试完成！"
    echo "模型 '$MODEL_NAME' 工作正常"
    echo "完成时间: $(date)"
    echo "==========================="
}

# 运行主函数
main "$@" 
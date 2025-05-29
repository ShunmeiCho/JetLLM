# Jetson Qwen 部署脚本集合

本目录包含Jetson Orin Nano上Qwen模型部署的所有相关脚本工具。

## 脚本列表

### 🚀 start-ollama.sh
**功能：** Ollama容器智能启动脚本
- 检测已运行的ollama容器
- 提供多种操作选项（进入/重启/并行运行）
- 自动使用autotag选择兼容镜像

**使用方法：**
```bash
./scripts/start-ollama.sh
```

### ⚡ quick-test.sh
**功能：** 快速系统环境测试
- Docker环境检查
- Ollama容器状态验证
- GPU资源检测
- API连接测试
- 模型列表获取
- 基础推理测试

**使用方法：**
```bash
./scripts/quick-test.sh
```

### 📊 monitor.sh
**功能：** 实时系统监控
- 系统资源使用情况（内存/磁盘）
- GPU状态和温度监控
- Docker容器状态
- Ollama API健康检查
- 可配置监控间隔

**使用方法：**
```bash
./scripts/monitor.sh [间隔秒数，默认5秒]
```

### 🧠 test_qwen.sh
**功能：** Qwen模型全面功能测试
- API连接测试
- 模型可用性检查
- 基础推理测试
- 代码生成测试
- 性能压力测试

**使用方法：**
```bash
./scripts/test_qwen.sh [模型名称]
```

## 最佳实践

### 日常使用流程
1. **启动服务：** `./scripts/start-ollama.sh`
2. **验证环境：** `./scripts/quick-test.sh`
3. **性能测试：** `./scripts/test_qwen.sh qwen2.5:1.5b`
4. **持续监控：** `./scripts/monitor.sh 10` （10秒间隔）

### 多模型环境管理

#### 支持的模型类型
- **Qwen2.5系列**：已验证稳定运行
- **Qwen3系列**：最新一代，支持0.6b-8b规格
- **DeepSeek-R1系列**：专业推理模型，支持1.5b-8b规格
- **SmolLM2系列**：超轻量级测试模型

#### 推荐模型组合
```bash
# 日常使用组合
./scripts/test_qwen.sh qwen2.5:1.5b    # 快速响应
./scripts/test_qwen.sh qwen3:1.7b      # 平衡性能
./scripts/test_qwen.sh deepseek-r1:7b  # 专业推理

# 注意：大模型需要监控内存使用
./scripts/monitor.sh 5  # 使用大模型时建议持续监控
```

### 基本故障排除

#### 常见问题解决
```bash
# 容器无法启动
./scripts/start-ollama.sh  # 自动检测并重启

# API无响应
docker restart ollama-container

# 内存不足
# 切换到更小的模型或重启容器
```

#### 资源监控
```bash
# 检查系统状态
./scripts/quick-test.sh

# 实时监控资源
./scripts/monitor.sh 5

# 检查当前模型
docker exec ollama-container ollama ps
```

## 扩展功能

### 批量测试
```bash
# 测试多个模型性能
for model in qwen2.5:1.5b qwen3:1.7b; do
    echo "Testing $model..."
    ./scripts/test_qwen.sh $model
done
```

### 定制监控
```bash
# 长期监控（后台运行）
nohup ./scripts/monitor.sh 60 > monitor.log 2>&1 &
```

## 更新日志

### 2025-05-29 更新
- ✅ 完成基础脚本集合
- ✅ 支持多模型管理
- ✅ 新增监控和测试功能
- ✅ 建立最佳实践指南

---

**注意事项**：
- 所有脚本都已设置可执行权限
- 建议在使用大模型前先运行监控脚本
- 详细的技术分析请参考 `jetson-qwen-deployment-log.md`
- 运营管理指南请参考 `jetson-containers-ollama-guide.md` 
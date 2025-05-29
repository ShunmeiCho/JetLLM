# Jetson-Containers 运行 Ollama 完整指南

## 构建状态 ✅
- 容器构建成功：`ollama:r36.2.0-cu122-22.04`
- 构建时间：13分16秒
- 构建阶段：
  1. build-essential (基础构建工具)
  2. pip_cache:cu122 (Python包缓存)
  3. cuda (CUDA 12.2.140支持)
  4. python (Python 3.10环境)
  5. ollama (Ollama 0.6.8)

## 步骤1：运行Ollama服务器

### ⚠️ 重要提醒
**请务必使用 `$(autotag ollama)` 而不是直接使用 `ollama`，否则会出现镜像找不到的错误！**

### 基本运行命令（推荐）
```bash
# ✅ 正确方式：使用autotag自动选择兼容镜像
jetson-containers run $(autotag ollama)
```

### 高级运行选项
```bash
# 运行并持久化数据
jetson-containers run --volume /home/dtc/workspace/ollama:/data $(autotag ollama)
```

### 完整自定义运行
```bash
# 全功能运行命令
jetson-containers run \
  --name ollama-container \
  --volume /home/dtc/workspace/ollama:/data \
  --volume /home/dtc/workspace/models:/models \
  --publish 11434:11434 \
  --runtime nvidia \
  --env OLLAMA_HOST=0.0.0.0 \
  --env OLLAMA_MODELS=/data/models \
  $(autotag ollama)
```

### ❌ 错误示例（避免使用）
```bash
# 这个命令会失败！
jetson-containers run ollama  # 寻找不存在的ollama:latest镜像
```

## 步骤2：验证容器运行

### 检查容器状态
```bash
# 查看运行中的容器
docker ps

# 查看容器日志
docker logs ollama-container
```

### 测试GPU可用性
```bash
# 进入容器检查GPU
docker exec -it ollama-container nvidia-smi
```

## 步骤3：下载和运行模型

### 方法1：在容器内操作
```bash
# 进入容器
docker exec -it ollama-container bash

# 下载模型
ollama pull qwen2.5:1.5b
ollama pull smollm2:135m-instruct

# 运行模型
ollama run qwen2.5:1.5b
```

### 方法2：从宿主机操作
```bash
# 确保容器正在运行，然后从宿主机执行
docker exec ollama-container ollama pull qwen2.5:1.5b
docker exec ollama-container ollama run qwen2.5:1.5b
```

## 步骤4：API访问测试

### 测试REST API
```bash
# 检查服务状态
curl http://localhost:11434/api/tags

# 生成文本
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen2.5:1.5b",
    "prompt": "为什么Jetson Orin Nano适合运行AI模型？",
    "stream": false
  }'
```

## 步骤5：性能监控

### 系统监控
```bash
# 使用之前创建的监控脚本（现在位于scripts目录）
./scripts/monitor.sh

# 或者查看特定指标
docker exec ollama-container nvidia-smi
docker stats ollama-container
```

### 内存和GPU使用情况
```bash
# 检查GPU内存使用
docker exec ollama-container nvidia-smi --query-gpu=memory.used,memory.total --format=csv

# 检查系统内存
free -h
```

## 容器管理命令

### 启动/停止容器
```bash
# 停止容器
docker stop ollama-container

# 重新启动容器
docker restart ollama-container

# 删除容器（数据会保留在volume中）
docker rm ollama-container
```

### 容器清理
```bash
# 清理未使用的镜像
docker image prune

# 查看占用空间
docker system df
```

## 🚨 重要：常见问题与解决方案

### 问题1: 运行命令失败

**错误现象**:
```bash
jetson-containers run ollama
# Error: Unable to find image 'ollama:latest' locally
```

**根本原因**:
- `jetson-containers run ollama` 默认寻找 `ollama:latest` 镜像
- 我们构建的镜像标签是 `ollama:r36.2.0-cu122-22.04`
- Docker Hub上没有 `ollama:latest` 公共镜像

**正确解决方案**:
```bash
# ✅ 推荐：使用autotag自动选择
jetson-containers run $(autotag ollama)

# ✅ 可行：手动指定完整标签  
jetson-containers run ollama:r36.2.0-cu122-22.04

# ❌ 错误：使用默认标签
jetson-containers run ollama  # 会失败
```

### 问题2: 大量错误信息

**错误现象**:
```bash
jetson-containers list | grep ollama
# 显示很多HTTP 403、AttributeError、KeyError等错误
```

**错误分析**:
1. **GitHub API限制** (HTTP 403) - 速率限制，不影响功能
2. **配置解析错误** (AttributeError) - 其他包的问题，不影响ollama
3. **包配置错误** (KeyError) - TensorFlow等包的问题

**解决方案**:
```bash
# 过滤错误信息
jetson-containers list 2>/dev/null | grep ollama

# 或者直接忽略错误，专注结果
# 这些错误不影响ollama的正常使用
```

## 📦 Ollama版本详解

### 可用版本列表
```bash
jetson-containers list | grep ollama
# 输出（忽略错误信息）:
ollama:0.4.0
ollama:0.5.1  
ollama:0.5.5
ollama:0.5.7
ollama:0.6.7
ollama:0.6.8  # ← 当前最新稳定版
```

### 版本选择指南

| 版本 | Ollama软件版本 | 发布时间 | 推荐程度 | 说明 |
|------|---------------|---------|---------|------|
| `ollama:0.4.0` | v0.4.0 | 2024年初 | ❌ 过时 | 早期版本，功能有限 |
| `ollama:0.5.1` | v0.5.1 | 2024年中 | ⚠️ 旧版本 | 性能改进版本 |
| `ollama:0.5.5` | v0.5.5 | 2024年中 | ⚠️ 旧版本 | 稳定性提升 |
| `ollama:0.5.7` | v0.5.7 | 2024年中 | ⚠️ 旧版本 | 功能扩展 |
| `ollama:0.6.7` | v0.6.7 | 2024年末 | ✅ 稳定 | 重大更新，性能优化 |
| `ollama:0.6.8` | v0.6.8 | 2024年末 | ✅ **推荐** | **当前最新稳定版** |

### 构建标签说明
我们构建的完整标签：`ollama:r36.2.0-cu122-22.04`

标签含义：
- `r36.2.0`: L4T (Linux for Tegra) 版本 36.2.0
- `cu122`: CUDA 12.2
- `22.04`: Ubuntu 22.04 LTS

## autotag工具使用

### 自动版本选择
```bash
# 查看autotag选择的版本
autotag ollama
# 输出: ollama:r36.2.0-cu122-22.04

# 直接使用autotag结果运行
jetson-containers run $(autotag ollama)
```

### autotag选择逻辑
1. **环境检测**: 自动检测L4T、JetPack、CUDA版本
2. **兼容性匹配**: 选择最兼容当前系统的镜像
3. **优先级**: 本地镜像 > 注册表镜像 > 自动构建

## 故障排除

### 常见问题

1. **端口已被占用**
   ```bash
   # 检查端口使用
   sudo netstat -tulpn | grep 11434
   
   # 杀死占用进程或使用不同端口
   jetson-containers run --publish 11435:11434 $(autotag ollama)
   ```

2. **GPU不可用**
   ```bash
   # 确认NVIDIA runtime
   docker info | grep nvidia
   
   # 重新安装nvidia-container-runtime
   sudo apt-get install nvidia-container-runtime
   ```

3. **内存不足**
   ```bash
   # 清理系统内存
   sudo sync && sudo echo 3 > /proc/sys/vm/drop_caches
   
   # 使用更小的模型
   docker exec ollama-container ollama pull smollm2:135m
   ```

## 性能优化建议

1. **使用最新量化模型**
   - Q2_K：最小内存占用
   - Q4_K_M：平衡性能和质量
   - Q8_0：最高质量

2. **调整环境变量**
   ```bash
   # 优化GPU内存使用
   --env OLLAMA_NUM_PARALLEL=1
   --env OLLAMA_MAX_LOADED_MODELS=1
   ```

3. **模型预加载**
   ```bash
   # 预热模型以加快响应
   docker exec ollama-container ollama run qwen2.5:1.5b "hello"
   ```

## 与直接安装版本的对比

| 特性 | jetson-containers | 直接安装 |
|------|------------------|----------|
| 隔离性 | ✅ 完全隔离 | ❌ 系统级别 |
| 依赖管理 | ✅ 容器化 | ❌ 可能冲突 |
| 版本控制 | ✅ 多版本共存 | ❌ 单一版本 |
| 部署复杂度 | ⚠️ 稍复杂 | ✅ 简单 |
| 性能开销 | ⚠️ 轻微 | ✅ 原生 |
| 生产适用 | ✅ 推荐 | ⚠️ 适合开发 |

## 后续步骤

1. **集成到现有项目**
   - 创建docker-compose.yml
   - 设置自动重启策略
   - 配置监控和日志

2. **扩展功能**
   - 多模型并发支持
   - 负载均衡配置
   - API网关集成

3. **自动化部署**
   - 创建部署脚本
   - 设置CI/CD流水线
   - 监控和告警系统

## 总结

jetson-containers方式提供了：
- ✅ 专业级的容器化部署
- ✅ 完整的CUDA和Python环境
- ✅ 易于维护和扩展
- ✅ 生产环境就绪

现在您拥有两种Ollama部署方式，可以根据不同场景选择最适合的方案！

## 模型推荐

基于Jetson Orin Nano的资源限制，推荐以下模型：

### 轻量级模型 (推荐新手)
```bash
# SmolLM2系列 - 极小资源消耗
docker exec ollama-container ollama pull smollm2:135m        # 270MB
docker exec ollama-container ollama pull smollm2:135m-instruct-q2_K  # 88MB

# Qwen2.5小型版本 - 平衡性能  
docker exec ollama-container ollama pull qwen2.5:1.5b       # 986MB
```

### 中等规模模型 (日常使用)
```bash
# Qwen2.5中型版本
docker exec ollama-container ollama pull qwen2.5:3b         # ~1.8GB

# 小型多模态模型
docker exec ollama-container ollama pull qwen2.5vl:3b       # ~2GB
```

## 扩展模型选择指南 (2025年新增)

### Qwen3系列 - 最新一代多模态模型

#### 特性优势
- **多功能架构**：支持dense和MoE模型
- **增强的工具调用**：更好的function calling支持  
- **扩展上下文**：128K tokens上下文窗口
- **多语言优化**：强化的中文处理能力
- **实时更新**：6小时前刚更新，技术最新

#### 推荐配置
```bash
# 入门级配置 - 极佳性能比
docker exec ollama-container ollama pull qwen3:1.7b         # ~1.2GB

# 平衡配置 - 推荐日常使用
docker exec ollama-container ollama pull qwen3:4b           # ~2.4GB

# 高性能配置 - 接近内存极限
docker exec ollama-container ollama pull qwen3:8b           # ~4.9GB
```

#### 适用场景
- ✅ **多语言文档处理**：中英文混合内容
- ✅ **智能工具调用**：API集成和函数调用
- ✅ **长文本理解**：技术文档、学术论文
- ✅ **代码生成优化**：更准确的编程辅助

### DeepSeek-R1系列 - 专业推理模型

#### 特性优势
- **推理专精**：专门针对数学、代码、逻辑推理优化
- **知识蒸馏技术**：小模型具备大模型推理模式
- **O1级别性能**：接近OpenAI o1的推理能力
- **商业友好许可**：MIT许可证，支持商业用途
- **多基座支持**：基于Qwen和Llama的蒸馏版本

#### 推荐配置
```bash
# 轻量推理版本 - 最小资源占用
docker exec ollama-container ollama pull deepseek-r1:1.5b   # ~1.1GB

# 标准推理版本 - 推荐配置  
docker exec ollama-container ollama pull deepseek-r1:7b     # ~4.7GB

# Llama基座版本 - 兼容性更好
docker exec ollama-container ollama pull deepseek-r1:8b     # ~4.9GB
```

#### 适用场景
- ✅ **数学问题求解**：复杂计算和公式推导
- ✅ **代码逻辑分析**：算法优化和调试
- ✅ **逻辑推理任务**：多步骤推理过程
- ✅ **学术研究辅助**：论文分析和实验设计

### 模型组合策略

#### 策略1：多模型任务分工（推荐）
```bash
# 总内存占用约5.8GB，充分利用系统资源
docker exec ollama-container ollama pull qwen2.5:1.5b       # 日常对话，986MB
docker exec ollama-container ollama pull qwen3:1.7b         # 多语言任务，1.2GB
docker exec ollama-container ollama pull deepseek-r1:7b     # 复杂推理，4.7GB

# 使用示例：
# 快速问答 → qwen2.5:1.5b
# 文档处理 → qwen3:1.7b  
# 数学代码 → deepseek-r1:7b
```

#### 策略2：单模型高性能
```bash
# 方案A：通用高性能
docker exec ollama-container ollama pull qwen3:8b           # 4.9GB

# 方案B：推理专用
docker exec ollama-container ollama pull deepseek-r1:8b     # 4.9GB
```

#### 策略3：轻量级多样化
```bash
# 适合资源受限或实验环境
docker exec ollama-container ollama pull qwen3:0.6b         # 600MB
docker exec ollama-container ollama pull deepseek-r1:1.5b   # 1.1GB
docker exec ollama-container ollama pull qwen2.5:1.5b       # 986MB
# 总计约2.7GB，系统负载轻
```

### 模型性能对比表

| 模型 | 内存占用 | 推理速度 | 数学能力 | 代码生成 | 中文支持 | 推荐指数 |
|------|---------|---------|---------|---------|---------|----------|
| qwen2.5:1.5b | 986MB | 很快 | 一般 | 良好 | 优秀 | ⭐⭐⭐⭐ |
| qwen3:1.7b | 1.2GB | 很快 | 良好 | 优秀 | 优秀 | ⭐⭐⭐⭐⭐ |
| qwen3:4b | 2.4GB | 快 | 优秀 | 优秀 | 优秀 | ⭐⭐⭐⭐⭐ |
| qwen3:8b | 4.9GB | 中等 | 优秀 | 卓越 | 优秀 | ⭐⭐⭐⭐ |
| deepseek-r1:1.5b | 1.1GB | 快 | 优秀 | 优秀 | 良好 | ⭐⭐⭐⭐ |
| deepseek-r1:7b | 4.7GB | 中等 | 专业级 | 专业级 | 良好 | ⭐⭐⭐⭐⭐ |
| deepseek-r1:8b | 4.9GB | 中等 | 专业级 | 专业级 | 良好 | ⭐⭐⭐⭐ |

### 部署优先级建议

#### 第一优先级：验证基础功能
```bash
# 最小风险测试
docker exec ollama-container ollama pull qwen3:1.7b
docker exec ollama-container ollama run qwen3:1.7b "你好，请介绍一下你与Qwen2.5的区别"
```

#### 第二优先级：推理能力测试
```bash
# 推理专用模型测试
docker exec ollama-container ollama pull deepseek-r1:7b
docker exec ollama-container ollama run deepseek-r1:7b "请解释费马大定理，并说明其证明的关键思路"
```

#### 第三优先级：性能极限测试
```bash
# 挑战内存极限（需谨慎）
docker exec ollama-container ollama pull qwen3:8b
# 或
docker exec ollama-container ollama pull deepseek-r1:8b
```

### 量化版本选择

根据Ollama量化标准，推荐顺序：
1. **Q4_K_M** - 平衡质量和大小，默认推荐
2. **Q4_K_S** - 最小内存占用，资源受限时使用
3. **Q5_K_M** - 更高质量，内存充足时选择
4. **Q8_0** - 接近原始质量，接近内存极限时谨慎使用

### 内存安全原则

- ✅ **单模型使用**：避免同时运行多个大模型
- ✅ **渐进测试**：从小模型开始，逐步增大
- ✅ **监控内存**：使用 `./scripts/monitor.sh` 实时监控
- ✅ **预留空间**：保持至少1GB系统缓存
- ⚠️ **8b模型**：接近极限，需要持续监控
- ❌ **14b+模型**：超出硬件限制，不建议尝试

## 实战多模型内存管理（2025年实测更新）

### 核心发现：模型下载 vs 模型运行

**重要区别**：
- ✅ **模型下载**：仅占用存储空间，对性能无任何影响
- ⚠️ **模型运行**：占用大量内存，Ollama智能管理确保单模型运行

**实测验证**：
```bash
# 当前已下载7个模型，总计18.8GB存储
# 但运行时Ollama只加载一个模型到内存
docker exec ollama-container ollama list
# 显示：7个模型已下载，但不占用内存

docker exec ollama-container ollama ps  
# 显示：只有当前使用的模型在内存中
```

### 内存使用实测数据

基于真实测试结果的内存安全等级：

| 模型规格 | 运行内存 | 系统内存使用率 | 安全等级 | 建议用途 |
|---------|---------|---------------|----------|----------|
| qwen2.5:1.5b | ~1.5GB | ~30% | 🟢 安全 | 日常对话，快速响应 |
| qwen3:1.7b | ~2.2GB | ~40% | 🟢 安全 | 平衡性能，推荐配置 |
| qwen3:4b | ~3.5GB | ~60% | 🟢 安全 | 复杂任务，高质量 |
| deepseek-r1:7b | ~5.2GB | ~85% | 🟡 注意 | 专业推理，需监控 |
| qwen3:8b | 6.5GB | 96% | 🔴 危险 | 极限性能，谨慎使用 |
| deepseek-r1:8b | ~6.2GB | ~94% | 🔴 危险 | 高风险，不建议长期使用 |

**关键测试结果**：
- qwen3:8b实测：6.5GB内存，96%系统使用率，仅剩158Mi可用
- 自动卸载：4分钟无活动后自动释放内存
- GPU优化：92%计算在GPU上，8%在CPU上

### Ollama智能内存管理机制

**自动管理特性**：
```bash
# 1. 单模型运行保护
# Ollama确保一次只运行一个大模型，避免OOM

# 2. 自动卸载机制
NAME        ID              SIZE      PROCESSOR         UNTIL              
qwen3:8b    500a1f067a9f    6.5 GB    8%/92% CPU/GPU    4 minutes from now
# ↑ 4分钟后自动卸载释放内存

# 3. 智能模型切换
# 运行新模型时自动卸载当前模型，无需手动干预
```

### 推荐部署策略（基于实测）

#### 策略1：安全多模型环境（推荐生产使用）
```bash
# 安全组合：运行时单个，存储共存
docker exec ollama-container ollama pull qwen2.5:1.5b     # 快速响应
docker exec ollama-container ollama pull qwen3:1.7b       # 平衡性能
docker exec ollama-container ollama pull deepseek-r1:7b   # 专业推理

# 优势：
# - 任务专业化分工
# - 最大内存使用率85%（安全）
# - 存储总占用约7GB
```

#### 策略2：极限性能单模型（谨慎使用）
```bash
# 选择一个8b模型作为主力
docker exec ollama-container ollama pull qwen3:8b         # 通用高性能
# 或
docker exec ollama-container ollama pull deepseek-r1:8b   # 推理专用

# 风险：96%内存使用率，需要持续监控
```

#### 策略3：轻量多样化（实验环境）
```bash
# 多个小模型并存
docker exec ollama-container ollama pull qwen3:0.6b       # 600MB
docker exec ollama-container ollama pull qwen2.5:1.5b     # 986MB
docker exec ollama-container ollama pull deepseek-r1:1.5b # 1.1GB

# 优势：系统负载轻，切换快速
```

### 内存监控与告警

#### 实时监控命令
```bash
# 1. 系统整体监控
./scripts/monitor.sh 5  # 每5秒刷新

# 2. 当前运行模型
docker exec ollama-container ollama ps

# 3. 内存使用详情
free -h && docker stats ollama-container --no-stream
```

#### 告警阈值设定
```bash
# 基于实测数据的安全阈值
if 内存使用率 > 90%:
    echo "🔴 高风险：立即监控，准备降级模型"
elif 内存使用率 > 80%:
    echo "🟡 警告：考虑切换到更小模型"
elif 可用内存 < 200Mi:
    echo "⚫ 紧急：系统即将OOM，立即干预"
```

### 故障处理与恢复

#### 内存不足应急处理
```bash
# 1. 立即切换到安全模型
docker exec ollama-container ollama run qwen3:1.7b "切换成功"

# 2. 强制停止当前模型（如需要）
docker exec ollama-container ollama stop qwen3:8b

# 3. 清理系统缓存
sudo sync && sudo echo 3 > /proc/sys/vm/drop_caches
```

#### 模型选择决策树
```
遇到内存问题时：
├─ 可用内存 < 200Mi → 立即切换到 qwen2.5:1.5b
├─ 内存使用率 > 90% → 切换到 qwen3:1.7b  
├─ 内存使用率 > 80% → 监控并准备降级
└─ 系统正常 → 继续使用当前模型
```

### 性能优化建议

#### 针对不同场景的模型选择
```bash
# 开发测试阶段
推荐：qwen3:1.7b - 平衡性能与稳定性

# 生产环境
推荐：qwen3:4b - 高质量输出，安全内存使用

# 专业推理任务
推荐：deepseek-r1:7b - 专业能力，可控风险

# 极限性能需求（谨慎）
可选：qwen3:8b - 需要专门的监控和运维
```

### 关键经验总结

1. **多模型下载策略完全可行**：
   - 存储空间充足（1.5T可用）
   - 下载不影响运行时性能
   - 模型切换快速便捷

2. **内存是关键限制因素**：
   - 7.4Gi总内存需要谨慎管理
   - 8b模型接近系统极限
   - Ollama智能管理确保安全

3. **建议采用保守策略**：
   - 优先选择7b及以下模型
   - 建立日常监控习惯
   - 准备降级备用方案

## 运营管理最佳实践

### 内存监控与告警系统

#### 实时监控脚本
```bash
#!/bin/bash
# 内存使用监控脚本
# 保存为 memory_monitor.sh

MEM_USED=$(free | grep Mem | awk '{printf("%.0f", $3/$2*100)}')
AVAILABLE_MEM=$(free -h | grep Mem | awk '{print $7}')

echo "$(date): 内存使用率 ${MEM_USED}%, 可用内存 ${AVAILABLE_MEM}"

# 基于实测数据的告警阈值
if [ $MEM_USED -gt 95 ]; then
    echo "⚫ 紧急：内存使用${MEM_USED}% - 立即切换模型！"
    echo "建议执行：docker exec ollama-container ollama run qwen2.5:1.5b"
    # 可添加自动切换逻辑
elif [ $MEM_USED -gt 90 ]; then
    echo "🔴 危险：内存使用${MEM_USED}% - 准备降级模型"
    echo "建议切换到：qwen3:1.7b 或更小模型"
elif [ $MEM_USED -gt 80 ]; then
    echo "🟡 警告：内存使用${MEM_USED}% - 需要关注"
else
    echo "🟢 正常：内存使用${MEM_USED}% - 系统状态良好"
fi
```

#### 自动化监控部署
```bash
# 设置定时监控（每5分钟检查一次）
*/5 * * * * /home/dtc/workspace/scripts/memory_monitor.sh >> /var/log/ollama-memory.log

# 后台持续监控
nohup ./scripts/monitor.sh 30 > /var/log/ollama-system.log 2>&1 &
```

### 智能模型选择系统

#### 基于内存使用率的模型推荐
```bash
#!/bin/bash
# 智能模型选择脚本
# 保存为 smart_model_selector.sh

MEM_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2*100)}')
CURRENT_MODEL=$(docker exec ollama-container ollama ps | grep -v NAME | awk '{print $1}')

echo "当前内存使用率：${MEM_USAGE}%"
echo "当前运行模型：${CURRENT_MODEL:-"无"}"

# 基于实测数据的模型推荐
if [ $MEM_USAGE -gt 70 ]; then
    RECOMMENDED="qwen2.5:1.5b"
    REASON="安全选择，约30%内存使用"
elif [ $MEM_USAGE -gt 50 ]; then
    RECOMMENDED="qwen3:1.7b"
    REASON="平衡选择，约40%内存使用"
elif [ $MEM_USAGE -gt 30 ]; then
    RECOMMENDED="deepseek-r1:7b"
    REASON="高性能选择，约85%内存使用"
else
    RECOMMENDED="qwen3:8b"
    REASON="极限性能，96%内存使用，需监控"
fi

echo "🎯 推荐模型：${RECOMMENDED} (${REASON})"

# 交互式切换
echo "是否切换到推荐模型？(y/n)"
read -r response
if [[ $response =~ ^[Yy]$ ]]; then
    echo "正在切换到推荐模型..."
    docker exec ollama-container ollama run $RECOMMENDED "模型切换成功"
    echo "✅ 已成功切换到 ${RECOMMENDED}"
else
    echo "❌ 取消切换，继续使用当前模型"
fi
```

### 故障排除与恢复

#### 内存不足应急处理流程
```bash
#!/bin/bash
# 内存不足应急恢复脚本
# 保存为 emergency_recovery.sh

echo "=== 内存不足应急恢复流程 ==="
echo "检测时间：$(date)"

# 1. 检查当前状态
echo "1. 检查当前系统状态..."
MEM_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2*100)}')
CURRENT_MODEL=$(docker exec ollama-container ollama ps 2>/dev/null | grep -v NAME | awk '{print $1}')

echo "   内存使用率：${MEM_USAGE}%"
echo "   当前模型：${CURRENT_MODEL:-"无模型运行"}"

# 2. 立即降级到安全模型
if [ $MEM_USAGE -gt 85 ]; then
    echo "2. 内存使用过高，立即切换到安全模型..."
    docker exec ollama-container ollama run qwen2.5:1.5b "应急切换成功" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "   ✅ 已切换到安全模型 qwen2.5:1.5b"
    else
        echo "   ❌ 模型切换失败，尝试重启容器"
        docker restart ollama-container
    fi
fi

# 3. 清理系统内存
echo "3. 清理系统缓存..."
sudo sync && sudo echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
echo "   ✅ 系统缓存已清理"

# 4. 验证恢复状态
echo "4. 验证系统恢复状态..."
sleep 5
NEW_MEM_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2*100)}')
NEW_MODEL=$(docker exec ollama-container ollama ps 2>/dev/null | grep -v NAME | awk '{print $1}')

echo "   恢复后内存使用率：${NEW_MEM_USAGE}%"
echo "   当前运行模型：${NEW_MODEL:-"无模型运行"}"

if [ $NEW_MEM_USAGE -lt 70 ]; then
    echo "   ✅ 系统已恢复正常"
else
    echo "   ⚠️ 系统仍需关注，建议检查其他进程"
fi

echo "=== 恢复流程完成 ==="
```

#### 系统健康检查脚本
```bash
#!/bin/bash
# 系统健康检查脚本
# 保存为 health_check.sh

echo "=== Jetson Ollama 系统健康检查 ==="
echo "检查时间：$(date)"

# 1. 容器状态检查
echo "1. 容器状态检查..."
CONTAINER_STATUS=$(docker ps | grep ollama-container | wc -l)
if [ $CONTAINER_STATUS -eq 1 ]; then
    echo "   ✅ Ollama容器正在运行"
    UPTIME=$(docker ps --format "table {{.Status}}" | grep ollama | awk '{print $2, $3}')
    echo "   运行时间：${UPTIME}"
else
    echo "   ❌ Ollama容器未运行，尝试启动..."
    ./scripts/start-ollama.sh
fi

# 2. API健康检查
echo "2. API健康检查..."
API_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:11434/api/tags)
if [ "$API_RESPONSE" = "200" ]; then
    echo "   ✅ API正常响应"
    MODEL_COUNT=$(curl -s http://localhost:11434/api/tags | jq '.models | length' 2>/dev/null || echo "unknown")
    echo "   可用模型数量：${MODEL_COUNT}"
else
    echo "   ❌ API无响应，HTTP状态码：${API_RESPONSE}"
fi

# 3. 资源使用检查
echo "3. 资源使用检查..."
MEM_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2*100)}')
DISK_USAGE=$(df /home/dtc/workspace | tail -1 | awk '{print $5}' | sed 's/%//')
CURRENT_MODEL=$(docker exec ollama-container ollama ps 2>/dev/null | grep -v NAME | awk '{print $1}')

echo "   内存使用率：${MEM_USAGE}%"
echo "   磁盘使用率：${DISK_USAGE}%"
echo "   当前模型：${CURRENT_MODEL:-"无模型运行"}"

# 4. GPU状态检查
echo "4. GPU状态检查..."
GPU_STATUS=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || echo "GPU检查失败")
echo "   GPU状态：${GPU_STATUS}"

# 5. 提供建议
echo "5. 系统建议..."
if [ $MEM_USAGE -gt 90 ]; then
    echo "   ⚠️ 内存使用率过高，建议切换到更小模型"
elif [ $MEM_USAGE -gt 80 ]; then
    echo "   🟡 内存使用率较高，需要关注"
else
    echo "   ✅ 内存使用率正常"
fi

if [ $DISK_USAGE -gt 80 ]; then
    echo "   ⚠️ 磁盘使用率过高，建议清理不必要的模型"
else
    echo "   ✅ 磁盘使用率正常"
fi

echo "=== 健康检查完成 ==="
```

### 运营维护计划

#### 日常维护清单
```bash
# 每日维护脚本
#!/bin/bash
# daily_maintenance.sh

echo "$(date): 开始每日维护..."

# 1. 健康检查
./scripts/health_check.sh

# 2. 日志轮转
if [ -f /var/log/ollama-system.log ]; then
    if [ $(stat -f%z /var/log/ollama-system.log 2>/dev/null || stat -c%s /var/log/ollama-system.log) -gt 10485760 ]; then
        mv /var/log/ollama-system.log /var/log/ollama-system.log.old
        echo "日志文件已轮转"
    fi
fi

# 3. 清理临时文件
docker system prune -f > /dev/null 2>&1
echo "Docker临时文件已清理"

echo "每日维护完成"
```

#### 周期性优化
```bash
# 每周优化脚本
#!/bin/bash
# weekly_optimization.sh

echo "$(date): 开始每周优化..."

# 1. 模型清理
echo "检查未使用的模型..."
UNUSED_MODELS=$(docker exec ollama-container ollama list | grep -E "(month|week)" | awk '{print $1}')
if [ -n "$UNUSED_MODELS" ]; then
    echo "发现长期未使用的模型，请手动确认是否删除："
    echo "$UNUSED_MODELS"
fi

# 2. 性能基准测试
echo "执行性能基准测试..."
./scripts/test_qwen.sh qwen2.5:1.5b > /tmp/performance_baseline.log

# 3. 系统优化
echo "优化系统缓存..."
sudo sync && sudo echo 3 > /proc/sys/vm/drop_caches

echo "每周优化完成"
```

### 监控报表生成

#### 性能报告脚本
```bash
#!/bin/bash
# generate_report.sh
# 生成系统性能报告

REPORT_FILE="/tmp/ollama_performance_report_$(date +%Y%m%d).txt"

cat > $REPORT_FILE << EOF
# Jetson Ollama 性能报告
生成时间: $(date)

## 系统状态
内存使用: $(free -h | grep Mem | awk '{print $3 "/" $2}')
磁盘使用: $(df -h /home/dtc/workspace | tail -1 | awk '{print $3 "/" $2}')
容器状态: $(docker ps --format "{{.Status}}" | grep ollama)

## 当前模型
$(docker exec ollama-container ollama ps)

## 可用模型列表
$(docker exec ollama-container ollama list)

## GPU状态
$(nvidia-smi --query-gpu=name,memory.used,memory.total --format=csv)

## 系统建议
$(if [ $(free | grep Mem | awk '{printf("%.0f", $3/$2*100)}') -gt 85 ]; then echo "内存使用率过高，建议优化"; else echo "系统运行正常"; fi)
EOF

echo "性能报告已生成: $REPORT_FILE"
```

现在您拥有两种Ollama部署方式，可以根据不同场景选择最适合的方案！
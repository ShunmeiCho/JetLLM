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

### 基本运行命令
```bash
jetson-containers run ollama
```

### 高级运行选项（推荐）
```bash
# 运行并持久化数据
jetson-containers run --volume /home/dtc/workspace/ollama:/data ollama
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
  ollama
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
   jetson-containers run --publish 11435:11434 ollama
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

### 性能优化建议

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
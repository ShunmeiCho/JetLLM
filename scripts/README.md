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
4. **监控系统：** `./scripts/monitor.sh 10`

### 权限设置
确保所有脚本具有执行权限：
```bash
chmod +x scripts/*.sh
```

### 环境要求
- Docker已安装并有执行权限
- jetson-containers工具链已配置
- Ollama容器镜像已构建
- 系统支持CUDA和GPU加速

## 故障排除

### 常见问题
1. **权限不足：** 运行`sudo usermod -aG docker $USER`并重新登录
2. **容器未找到：** 检查`autotag ollama`输出的镜像标签
3. **GPU不可用：** 验证`nvidia-smi`命令是否正常
4. **API连接失败：** 确认ollama容器正在运行且端口11434可访问

### 日志查看
```bash
# Docker容器日志
docker logs <container_name>

# 系统服务日志（如果使用直接安装）
journalctl -u ollama -f
```

## 更新记录
- 2024-12-19: 初始版本创建
- 脚本集合统一管理，支持完整的Qwen部署工作流 
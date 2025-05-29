# Jetson Qwen Model Deployment

本项目在NVIDIA Jetson Orin Nano上部署Qwen大语言模型，使用Ollama和jetson-containers技术栈。

## 快速开始

### 1. 启动Ollama服务
```bash
./scripts/start-ollama.sh
```

### 2. 快速测试
```bash  
./scripts/quick-test.sh
```

### 3. 性能监控
```bash
./scripts/monitor.sh
```

### 4. 模型测试
```bash
./scripts/test_qwen.sh qwen2.5:1.5b
```

## 脚本说明

所有脚本文件都位于`scripts/`目录中，详见[scripts/README.md](scripts/README.md)。

## 文档

- [部署日志](jetson-qwen-deployment-log.md) - 详细的部署过程记录
- [操作指南](jetson-containers-ollama-guide.md) - Ollama容器使用指南
- [环境信息](jetson_environment_info.md) - Jetson环境详细信息 
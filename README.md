# JetLLM 🚀

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Jetson](https://img.shields.io/badge/NVIDIA-Jetson-76B900.svg)](https://developer.nvidia.com/embedded/jetson)
[![Ollama](https://img.shields.io/badge/Ollama-Latest-blue.svg)](https://ollama.ai/)
[![Python](https://img.shields.io/badge/Python-3.8%2B-blue.svg)](https://www.python.org/)

> **Edge AI Made Simple - NVIDIA Jetson 边缘AI设备上的大语言模型部署完整解决方案**

JetLLM 是一个专为NVIDIA Jetson系列设备优化的大语言模型部署工具包，提供从环境配置到模型运行的完整解决方案。基于Jetson-Containers生态系统，支持多种LLM模型的高效部署和运行。

## ✨ 核心特性

### 🎯 **专业边缘AI部署**
- 针对ARM64架构和Jetson硬件的深度优化
- 支持统一内存架构(UMA)的智能内存管理
- GPU加速推理，充分利用Jetson AI算力

### 🛠️ **完整工具链**
- **自动化脚本**：一键启动、监控、测试脚本
- **智能监控**：实时系统资源和模型性能监控
- **版本管理**：支持多版本模型并存和智能切换

### 📚 **丰富文档资源**
- 详细部署指南和故障排除方案
- 学术级别的技术深度分析
- 最佳实践和性能优化建议

### 🔧 **多模型支持**
- **Qwen系列**：Qwen2.5、Qwen3最新版本
- **DeepSeek-R1**：专业推理能力
- **Llama系列**：Code-Llama、Chat模型
- **轻量化模型**：SmolLM2等边缘优化模型

## 🚀 快速开始

### 系统要求

- **硬件**：NVIDIA Jetson Orin Nano/AGX Orin/Xavier系列
- **系统**：Ubuntu 20.04/22.04 LTS with JetPack 5.0+ (推荐 JetPack 6.0)
- **内存**：建议8GB以上
- **存储**：可用空间20GB以上
- **网络**：稳定的互联网连接（用于下载容器和模型）

### 🔧 环境准备

#### 1. 系统基础依赖安装

```bash
# 更新系统包
sudo apt update && sudo apt upgrade -y

# 安装基础工具
sudo apt install -y \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    python3-pip \
    ca-certificates \
    gnupg \
    lsb-release
```

#### 2. Docker环境配置

```bash
# 安装Docker（如果未安装）
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 将当前用户加入docker组
sudo usermod -aG docker $USER

# 重新登录或执行以下命令生效
newgrp docker

# 验证Docker安装
docker --version
```

#### 3. NVIDIA Container Toolkit安装

```bash
# 添加NVIDIA GPG密钥
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

# 安装nvidia-container-toolkit
sudo apt update
sudo apt install -y nvidia-container-toolkit

# 重启Docker服务
sudo systemctl restart docker

# 验证GPU容器支持
docker run --rm --gpus all nvidia/cuda:11.4-base-ubuntu20.04 nvidia-smi
```

#### 4. Jetson-Containers环境设置

```bash
# 克隆jetson-containers仓库
git clone https://github.com/dusty-nv/jetson-containers.git
cd jetson-containers

# 安装jetson-containers依赖
sudo apt update
pip3 install -r requirements.txt

# 添加jetson-containers到PATH（推荐）
echo 'export PATH=$PATH:'$(pwd) >> ~/.bashrc
source ~/.bashrc

# 验证安装
jetson-containers --help
```

#### 5. 系统性能优化（可选但推荐）

```bash
# 设置Jetson为最大性能模式
sudo nvpmodel -m 0
sudo jetson_clocks

# 增加swap空间（对于内存较小的设备）
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 🚀 项目部署

#### 方式一：一键自动部署（推荐新手）

```bash
# 1. 克隆本项目
git clone https://github.com/your-username/JetLLM.git
cd JetLLM

# 2. 确保在jetson-containers目录或已加入PATH
# 如果jetson-containers未加入PATH，需要先切换到其目录
# cd /path/to/jetson-containers

# 3. 启动Ollama服务（自动构建和运行）
./scripts/start-ollama.sh

# 4. 运行模型测试
./scripts/test_qwen.sh qwen2.5:1.5b

# 5. 启动系统监控
./scripts/monitor.sh
```

#### 方式二：手动逐步部署（推荐有经验用户）

```bash
# 1. 构建Ollama容器（在jetson-containers目录下）
jetson-containers build ollama

# 2. 运行Ollama容器
jetson-containers run $(autotag ollama)

# 或者指定特定版本和配置
jetson-containers run \
  --name ollama-container \
  --volume /home/$USER/ollama-data:/data \
  --publish 11434:11434 \
  --env OLLAMA_HOST=0.0.0.0 \
  $(autotag ollama)

# 3. 下载并运行Qwen模型
docker exec ollama-container ollama pull qwen2.5:1.5b
docker exec ollama-container ollama run qwen2.5:1.5b

# 4. 测试API访问
curl http://localhost:11434/api/tags
```

### ⚡ 快速验证

完成部署后，运行以下命令验证系统是否正常工作：

```bash
# 检查容器运行状态
docker ps | grep ollama

# 验证GPU访问
docker exec ollama-container nvidia-smi

# 测试模型响应
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen2.5:1.5b",
    "prompt": "你好，请介绍一下你自己",
    "stream": false
  }'

# 运行完整测试套件
./scripts/quick-test.sh
```

### 🛠️ 常见部署问题解决

#### 问题1：jetson-containers命令找不到
```bash
# 解决方案：确保正确设置PATH或使用绝对路径
cd /path/to/jetson-containers
./jetson-containers.py --help

# 或者创建软链接
sudo ln -s /path/to/jetson-containers/jetson-containers.py /usr/local/bin/jetson-containers
```

#### 问题2：Docker权限问题
```bash
# 解决方案：确保用户在docker组中
sudo usermod -aG docker $USER
newgrp docker
# 或者重新登录系统
```

#### 问题3：GPU不可用
```bash
# 检查NVIDIA驱动
nvidia-smi

# 检查NVIDIA Container Toolkit
docker run --rm --gpus all nvidia/cuda:11.4-base-ubuntu20.04 nvidia-smi

# 重新安装nvidia-container-toolkit
sudo apt remove nvidia-container-toolkit
sudo apt install nvidia-container-toolkit
sudo systemctl restart docker
```

#### 问题4：内存不足
```bash
# 检查内存使用
free -h

# 增加swap空间
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 使用更小的模型
docker exec ollama-container ollama pull qwen2.5:1.5b  # 而不是更大的模型
```

## 📖 详细文档

### 核心文档

| 文档 | 描述 | 适用场景 |
|------|------|----------|
| [**Ollama完整部署指南**](jetson-containers-ollama-guide.md) | 从零到生产的完整部署教程 | 🔰 新手入门 |
| [**技术深度解析**](jetson-containers_comprehensive_analysis.md) | 学术级别的技术架构分析 | 🎓 深度学习 |
| [**环境信息文档**](jetson_environment_info.md) | 系统环境配置详情 | 🔧 环境配置 |
| [**部署日志记录**](jetson-qwen-deployment-log.md) | 实际部署过程记录 | 📋 故障排除 |

### 脚本工具

| 脚本 | 功能 | 使用方法 |
|------|------|----------|
| `start-ollama.sh` | 启动Ollama服务 | `./scripts/start-ollama.sh` |
| `monitor.sh` | 系统监控 | `./scripts/monitor.sh [interval]` |
| `test_qwen.sh` | 模型测试 | `./scripts/test_qwen.sh <model>` |
| `quick-test.sh` | 快速验证 | `./scripts/quick-test.sh` |

## 🏗️ 项目结构

```
JetLLM/
├── 📄 README.md                                    # 项目说明文档
├── 📄 LICENSE                                      # MIT许可证
├── 📚 文档资源/
│   ├── jetson-containers-ollama-guide.md           # Ollama部署完整指南
│   ├── jetson-containers_comprehensive_analysis.md # 技术深度解析
│   ├── jetson_environment_info.md                  # 环境配置信息
│   └── jetson-qwen-deployment-log.md              # 部署过程日志
└── 🔧 scripts/                                    # 自动化脚本
    ├── README.md                                   # 脚本使用说明
    ├── start-ollama.sh                            # Ollama启动脚本
    ├── monitor.sh                                 # 系统监控脚本
    ├── test_qwen.sh                               # 模型测试脚本
    └── quick-test.sh                              # 快速验证脚本
```

## 🎯 支持的模型矩阵

### 推荐配置（按内存使用排序）

| 模型 | 内存占用 | 推理速度 | 适用场景 | 推荐指数 |
|------|----------|----------|----------|----------|
| `qwen2.5:1.5b` | ~1.0GB | 很快 | 日常对话、快速响应 | ⭐⭐⭐⭐⭐ |
| `qwen3:1.7b` | ~1.2GB | 很快 | 多语言、平衡性能 | ⭐⭐⭐⭐⭐ |
| `deepseek-r1:1.5b` | ~1.1GB | 快 | 数学推理、代码生成 | ⭐⭐⭐⭐ |
| `qwen3:4b` | ~2.4GB | 快 | 复杂任务、高质量 | ⭐⭐⭐⭐ |
| `deepseek-r1:7b` | ~4.7GB | 中等 | 专业推理、学术研究 | ⭐⭐⭐⭐⭐ |

### 模型选择策略

```bash
# 资源受限环境（< 2GB可用内存）
docker exec ollama-container ollama pull qwen2.5:1.5b

# 平衡性能环境（2-4GB可用内存）
docker exec ollama-container ollama pull qwen3:1.7b

# 高性能环境（> 4GB可用内存）
docker exec ollama-container ollama pull deepseek-r1:7b
```

## 📊 性能基准

### Jetson Orin Nano 性能表现

| 指标 | qwen2.5:1.5b | qwen3:1.7b | deepseek-r1:7b |
|------|--------------|------------|----------------|
| **推理速度** | 15.2 tokens/s | 13.8 tokens/s | 8.5 tokens/s |
| **延迟** | 450ms | 520ms | 780ms |
| **内存使用率** | 30% | 40% | 85% |
| **GPU利用率** | 65% | 72% | 92% |
| **功耗** | 8.5W | 10.2W | 15.8W |

## 🛠️ 高级配置

### 性能优化

```bash
# 启用最大性能模式
sudo nvpmodel -m 0
sudo jetson_clocks

# 内存优化配置
export OLLAMA_GPU_LAYERS=999
export OLLAMA_FLASH_ATTENTION=1
export OLLAMA_MAX_LOADED_MODELS=1
```

### 多模型管理

```bash
# 智能模型切换
./scripts/test_qwen.sh qwen2.5:1.5b    # 轻量级测试
./scripts/test_qwen.sh qwen3:1.7b      # 平衡性能测试  
./scripts/test_qwen.sh deepseek-r1:7b  # 高性能测试
```

## 🔍 故障排除

### 常见问题

**Q: 容器启动失败？**
```bash
# 检查容器状态
docker ps -a
# 查看日志
docker logs ollama-container
# 重新启动
./scripts/start-ollama.sh
```

**Q: 内存不足？**
```bash
# 切换到轻量模型
docker exec ollama-container ollama run qwen2.5:1.5b
# 清理系统缓存
sudo sync && sudo echo 3 > /proc/sys/vm/drop_caches
```

**Q: GPU不可用？**
```bash
# 检查GPU状态
nvidia-smi
# 验证CUDA环境
docker exec ollama-container nvidia-smi
```

更多故障排除方案请参考：[完整故障排除指南](jetson-containers-ollama-guide.md#故障排除)

## 🤝 贡献指南

我们欢迎社区贡献！您可以通过以下方式参与：

### 贡献类型
- 🐛 **Bug报告**：发现问题请提交Issue
- 💡 **功能建议**：新功能想法和改进建议
- 📖 **文档完善**：改进文档内容和示例
- 🔧 **代码贡献**：修复Bug或添加新功能

### 贡献流程
1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📈 项目发展

### 已完成功能 ✅
- Jetson-Containers + Ollama 完整集成
- 多版本模型支持和智能切换
- 自动化部署和监控脚本
- 详细技术文档和使用指南

### 开发中功能 🚧
- Web界面管理工具
- 模型性能自动优化
- 集群部署支持
- API服务封装

### 未来计划 🎯
- 支持更多LLM框架（vLLM、MLC-LLM等）
- 视觉语言模型(VLM)集成
- 边缘联邦学习支持
- 产业级部署解决方案

## 📞 支持与联系

### 获取帮助
- 📖 **文档**：查阅项目文档获取详细信息
- 🐛 **Issues**：[GitHub Issues](https://github.com/ShunmeiCho/JetLLM/issues) 报告问题
- 💬 **讨论**：[GitHub Discussions](https://github.com/ShunmeiCho/JetLLM/discussions) 社区讨论

### 相关资源
- [NVIDIA Jetson 软件文档](https://docs.nvidia.com/jetson/)
- [Jetson-Containers官方仓库](https://github.com/dusty-nv/jetson-containers)
- [Ollama官方文档](https://ollama.com/)

## 📄 许可证

本项目基于 [MIT License](LICENSE) 开源协议。

---

## 🙏 致谢

感谢以下项目和社区的支持：
- [Jetson-Containers](https://github.com/dusty-nv/jetson-containers) - 核心容器化框架
- [Ollama](https://ollama.com/) - 本地LLM运行时
- [NVIDIA Jetson](https://docs.nvidia.com/jetson/) - 边缘AI硬件平台
- 开源社区的所有贡献者

---

<div align="center">

**如果JetLLM对您有帮助，请给我们一个 ⭐️**

Made with ❤️ for the Edge AI Community

</div>

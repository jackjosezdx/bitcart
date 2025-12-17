FROM python:3.11-slim

WORKDIR /app

# 安装所有必要的构建依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    libsecp256k1-dev \
    libffi-dev \
    libssl-dev \
    pkg-config \
    automake \
    libtool \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 升级 pip 和安装 UV
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir uv

# 设置环境变量，跳过某些编译步骤
ENV COINCURVE_IGNORE_SYSTEM_LIB=
ENV SETUPTOOLS_USE_DISTUTILS=stdlib

# 复制依赖文件
COPY pyproject.toml uv.lock ./

# 使用 uv 安装依赖，增加超时时间
RUN uv sync --frozen --no-cache

# 复制项目文件
COPY . .

# 暴露端口
EXPOSE 8000

# 健康检查（可选但推荐）
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# 启动命令
CMD ["uv", "run", "gunicorn", "-c", "gunicorn.conf.py", "main:app"]

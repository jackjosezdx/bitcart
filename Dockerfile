FROM python:3.11-slim

WORKDIR /app

# 只装必要运行库（不是构建库）
RUN apt-get update && apt-get install -y \
    libffi-dev \
    libssl-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 升级 pip + 安装 uv
RUN pip install --no-cache-dir --upgrade pip setuptools wheel \
    && pip install --no-cache-dir uv

# 关键：强制只使用 binary wheel
ENV PIP_ONLY_BINARY=:all:
ENV UV_PIP_ONLY_BINARY=:all:

# 复制依赖文件
COPY pyproject.toml uv.lock ./

# 安装依赖（此时 coincurve 必走 wheel）
RUN uv sync --frozen --no-cache

# 复制代码
COPY . .

EXPOSE 8000

CMD ["uv", "run", "gunicorn", "-c", "gunicorn.conf.py", "main:app"]

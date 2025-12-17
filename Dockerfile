FROM python:3.11

WORKDIR /app

# 安装关键依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    libsecp256k1-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 安装 UV
RUN pip install uv

# 复制并安装依赖
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen

# 复制项目
COPY . .

# 启动
EXPOSE 8000
CMD ["uv", "run", "gunicorn", "-c", "gunicorn.conf.py", "main:app"]

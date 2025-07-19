# FROM python:3.12-slim

# # uv 바이너리 복사 (최신 버전 사용, 필요시 버전 고정 가능)
# # COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/


# # 작업 디렉토리 생성 및 이동
# WORKDIR /app

# # 프로젝트 파일 복사
# COPY requirements.txt ./
# # 의존성 설치 (락파일 기준)
# RUN pip install --no-cache-dir -r requirements.txt

# # 소스 코드 복사
# COPY . .

# EXPOSE 80

# # FastAPI 앱 실행 (uvicorn)
# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"] 

FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

# Install the project into `/app`
WORKDIR /app

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy from the cache instead of linking since it's a mounted volume
ENV UV_LINK_MODE=copy

# Install the project's dependencies using the lockfile and settings
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project --no-dev

# Then, add the rest of the project source code and install it
# Installing separately from its dependencies allows optimal layer caching
COPY . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-dev

EXPOSE 8000

# FastAPI 앱 실행 (uvicorn)
CMD ["uv", "run", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"] 


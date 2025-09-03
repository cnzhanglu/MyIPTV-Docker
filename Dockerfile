# 多架构构建基础，使用Ubuntu作为基础镜像（含glibc）
ARG TARGETARCH
ARG VERSION

# 构建阶段：下载对应架构的二进制文件
FROM ubuntu:22.04 AS builder

ARG TARGETARCH
ARG VERSION

# 安装必要工具
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

# 根据架构下载对应的二进制文件
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        wget -O myiptv https://github.com/localvar/myiptv/releases/download/v${VERSION}/myiptv-v${VERSION}-linux.amd64; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        wget -O myiptv https://github.com/localvar/myiptv/releases/download/v${VERSION}/myiptv-v${VERSION}-linux.arm64; \
    else \
        echo "Unsupported architecture: $TARGETARCH" && exit 1; \
    fi && \
    chmod +x myiptv

# 最终镜像：使用Ubuntu最小化版本以减小体积
FROM ubuntu:22.04-minimal

ARG VERSION

LABEL maintainer="Your Name"
LABEL version="${VERSION}"
LABEL description="MyIPTV - Convert IPTV UDP multicast streams to HTTP"

# 安装必要的运行时依赖（含glibc）
RUN apt-get update && apt-get install -y libc6 && rm -rf /var/lib/apt/lists/*

# 复制二进制文件
COPY --from=builder /myiptv /usr/local/bin/myiptv

# 确保执行权限
RUN chmod +x /usr/local/bin/myiptv

# 创建配置文件目录
RUN mkdir -p /etc/myiptv && chmod 777 /etc/myiptv

# 暴露默认端口
EXPOSE 7709

# 验证二进制文件依赖
RUN ldd /usr/local/bin/myiptv || true

# 启动命令
CMD ["/usr/local/bin/myiptv"]

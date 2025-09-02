# 多架构构建基础
ARG TARGETARCH
ARG VERSION

# 构建阶段：下载对应架构的二进制文件
FROM alpine:latest AS builder

ARG TARGETARCH
ARG VERSION

# 安装必要工具
RUN apk add --no-cache wget

# 根据架构下载对应的二进制文件
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        wget -O myiptv https://github.com/localvar/myiptv/releases/download/v${VERSION}/myiptv-v${VERSION}-linux.amd64; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        wget -O myiptv https://github.com/localvar/myiptv/releases/download/v${VERSION}/myiptv-v${VERSION}-linux.arm64; \
    else \
        echo "Unsupported architecture: $TARGETARCH" && exit 1; \
    fi && \
    chmod +x myiptv

# 最终镜像
FROM alpine:latest

ARG VERSION

LABEL maintainer="Your Name"
LABEL version="${VERSION}"
LABEL description="MyIPTV - Convert IPTV UDP multicast streams to HTTP"

# 复制二进制文件
COPY --from=builder /myiptv /usr/local/bin/myiptv

# 创建配置文件目录
RUN mkdir -p /etc/myiptv && chmod 777 /etc/myiptv

# 暴露默认端口
EXPOSE 7709

# 启动命令
CMD ["myiptv"]

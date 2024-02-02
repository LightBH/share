# Blockscout区块链浏览器搭建

>   官网：https://docs.blockscout.com/
>
>   仓库地址：https://github.com/blockscout/blockscout

## 使用Docker部署

>   官方文档：[Docker Integration - Blockscout](https://docs.blockscout.com/for-developers/information-and-settings/docker-integration-local-use-only) 
>
>   github：https://github.com/blockscout/blockscout/tree/master/docker-compose

-   先决条件
    -   docker版本 v20.10+
    -   Docker-compose版本 2.x.x+
    -   运行以太坊 JSON RPC 客户端

-   下载代码中的`docker-compost` 目录。https://github.com/blockscout/blockscout/tree/master/docker-compose



在主机1中安装部署Blockscout区块链浏览器。

**注意：所有配置都假设以太坊 JSON RPC 以 `http://localhost:8545` 运行。** 

```shell
cd ./docker-compose
mv docker-compose.yml docker-compose.yml-bak
mv docker-compose-no-build-geth.yml docker-compose.yml

# 启动
docker-compose up --build

# 停止
docker-compose down
```

启动后即可在浏览器输入地址 `http://192.168.110.130/`，来访问区块链浏览器


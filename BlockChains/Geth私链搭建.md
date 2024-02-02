Go-ethereum（又名Geth）是以太坊的官方Go语言实现的客户端。它是一个完整的以太坊节点，可连接到各种以太坊网络，也可以用来搭建私有以太坊网络。

官方文档：[Welcome to go-ethereum | go-ethereum](https://geth.ethereum.org/docs) 



# 一、Linux-安装包 安装Geth

官网下载安装包，此处在Linux环境安装，选用 可执行的二进制文件工具包

-   安装包地址：https://geth.ethereum.org/downloads

```shell
# Geth & Tools 1.11.6（637010ce534b7fa13f838cda68ebbb04）
# 下载可执行的二进制文件工具包
https://gethstore.blob.core.windows.net/builds/geth-alltools-linux-amd64-1.11.6-ea9e62ca.tar.gz

# 解压缩下载的压缩包
tar xf geth-alltools-linux-amd64-1.11.6-ea9e62ca.tar.gz

# 配置环境变量
I_H_DIR='/data/geth'
mkdir -p ${I_H_DIR}
mv geth-alltools-linux-amd64-1.11.6-ea9e62ca ${I_H_DIR}
cd ${I_H_DIR}
ln -snf geth-alltools-linux-amd64-1.11.6-ea9e62ca geth-alltools
export PATH=${I_H_DIR}/geth-alltools:$PATH
echo 'export PATH='${I_H_DIR}'/geth-alltools:$PATH' >> ~/.bashrc

# 安装完成，检查安装效果
geth --help
```



# 二、搭建 使用PoW共识的 私链

Geth的PoW算法为[Ethash](https://ethereum.org/en/developers/docs/consensus-mechanisms/pow/mining-algorithms/ethash)。Ethash是一个系统，允许任何愿意将资源用于挖矿的人公开参与。

搭建规划：

| 节点  | IP              | 用途                                                         | 安装程序                                                 |
| ----- | --------------- | ------------------------------------------------------------ | -------------------------------------------------------- |
| 主机1 | 192.168.110.130 | Blockscout区块链浏览器；Geth归档节点 (浏览器须要归档节点）   | Geth、Docker、<br />Docker-compose（用于安装Blockscout） |
| 主机2 | 192.168.110.131 | Geth默认的Snap类型全节点，开放所有api权限用于开发人员连接使用； | Geth                                                     |

>   Tips：
>
>   -   Geth单节点亦可作为区块链来连接使用；此处两个节点是为了学习和练习节点搭建与多节点之间的连接。



## 2.1 主机1节点搭建

搭建目标：

-   作为归档节点 供 区块链浏览器 连接；
-   连接主机2上的节点；

### (0) 工作目录

```shell
mkdir -p /data/geth/geth-ethash/data
cd /data/geth/geth-ethash
```



### (1) 创建 账户

每个区块链节点都需要一个 账户

```shell
geth account new --datadir ./data
# 会提示创建密码
```

-   `--datadir`：每个 以太坊节点 单独的数据目录。


> 创建账户会打印密钥，记录此密钥，用于在创建 创世块文件时，指定该初始用户。
>
> ```
> Public address of the key:   0xB547f78DE534aAa2f2F21243e92CC82495E7c4F3
> ```

将密码存入文件，在后续启动节点时使用，用于解锁该账户。

```shell
echo '123' > ./data/password.txt
```



### (2) 创建 创世块文件

手动创建  `genesis.json`  创世块文件：

```json
cat > genesis.json << EOF
{
  "config": {
    "chainId": 1731313,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "berlinBlock": 0,
    "ethash": {}
  },
  "difficulty": "1",
  "gasLimit": "8000000",
  "alloc": {
    "B547f78DE534aAa2f2F21243e92CC82495E7c4F3": { "balance": "1000000000000000000" }
  }
}
EOF
```

可直接使用上面的示例作为创世块文件。此处账户密钥使用步骤(1)中创建的，并分配1个以太币

创世块文件的部分内容，我们简单了解一下：

- `chainId`：链的ID，也就是网络ID（networkid），每个链的ID不应相同。
- `difficulty`：挖矿难度。
- `gasLimit`：初始块气体限制。
- `alloc`：以太币的初始分配。



### (3) 初始化 Geth

```shell
geth init --datadir ./data genesis.json
```



### (4) 启动 Geth节点

节点运行方式：

1.   后台运行。使用 `nohup ... &` 将节点运行放入后台。
2.   不直接开启挖矿。即不加选项 `--mine`。需要挖矿时，通过命令来开启挖矿就可以，不需要直接开始挖矿。
3.   归档节点。使用选项`--syncmode full --gcmode archive`。

**命令行输入启动Geth节点**：

```shell
nohup geth --datadir ./data --networkid 1731313 --http --http.addr 0.0.0.0 --http.vhosts "*" --http.api "eth,net,web3,debug,txpool" --rpc.enabledeprecatedpersonal --http.corsdomain "*" --netrestrict 192.168.0.0/16 --miner.threads 1 --allow-insecure-unlock --miner.etherbase=0xB547f78DE534aAa2f2F21243e92CC82495E7c4F3 --unlock B547f78DE534aAa2f2F21243e92CC82495E7c4F3 --password data/password.txt --syncmode full --gcmode archive 2> 1.log &
# --port 30303 --authrpc.port 8551 --http.port 8545
```

这个命令的启动参数比较长，我们也需要针对参数进行介绍：

- `--networkid`：配置成与配置文件config内的chainId相同值，代表加入哪个网络，私链就自己随意编号即可。
- `--http`：开启远程调用服务。
- `--http.addr`：远程调用服务监听的地址。
- `--http.vhosts`：主机访问限制。
- `--http.api`：远程服务提供的远程调用函数集。
- `--rpc.enabledeprecatedpersonal`：api中的personal已被禁用，若要开启personal，需使用该参数。
- `--http.corsdomain`：指定可以接收请求来源的域名列表
- `--netrestrict`：IP网络白名单。
- `--miner.threads`：设置挖矿的线程数量。
- `--miner.etherbase`：指定节点挖矿的用户。
- `--unlock`：解锁用户。
- `--password`：指定解锁用户的密码。

>   节点启动后，会启动的端口：
>
>   -   `30303`(TCP\UDP)：Network listening port（--port value）
>   -   `8545`：HTTP-RPC server listening port（--http.port value）
>   -   `8551`：Listening port for authenticated APIs（--authrpc.port value）

至此就完成了首个节点的搭建。



### (5) 连接与测试

```shell
# Javascript 控制台通过 IPC 连接到本机 Geth 节点。进入控制台
geth attach data/geth.ipc
```

```shell
# 查看peer节点数量
> net.peerCount
# 查看网络节点情况
> admin.peers

# 查询账户信息
> eth.accounts
["0xb547f78de534aaa2f2f21243e92cc82495e7c4f3"]

# 查看账户余额
> acc0=eth.accounts[0]
"0xb547f78de534aaa2f2f21243e92cc82495e7c4f3"
> eth.getBalance(acc0)
1000000000000000000

############# 测试 添加用户 ###########
> personal.newAccount("123")
"0x057619c110890b9ab13a70a4fe90fd4c442e62eb"
> eth.accounts
["0xb547f78de534aaa2f2f21243e92cc82495e7c4f3", "0x057619c110890b9ab13a70a4fe90fd4c442e62eb"]
> acc2=eth.accounts[1]
"0x057619c110890b9ab13a70a4fe90fd4c442e62eb"

> eth.getBalance(acc0)
> eth.getBalance(acc2)

# acc0向acc2转1个以太币
> eth.sendTransaction({from:acc0,to:acc2,value:web3.toWei(1)})

# 挖一个矿
> miner.start(1);admin.sleepBlocks(1);miner.stop()

# 再次查看账户余额
> eth.getBalance(acc0)
> eth.getBalance(acc2)
```



## 2.2 主机2节点搭建

### (1) 初始化

在搭建多节点时需要注意的是，创世块文件须相同，网络ID须一致。

与 `2.1`步骤 中首个节点搭建类似（完成 0~3 步骤的操作），仅创建的用户信息不同。

```shell
#（0）创建工作目录
mkdir -p /data/geth/geth-ethash/data
cd /data/geth/geth-ethash
# (1) 创建 账户
geth account new --datadir ./data
# 输入密码：123
'''
Public address of the key:   0xbc4aA009599A1A95ac45Ce0E9971a701519735b2
'''
echo '123' > ./data/password.txt
# (2) 创建 创世块文件。与节点1使用的区块文件一致。
# (3) 初始化 Geth 数据库
geth init --datadir ./data genesis.json 
```



### (2) 启动节点

注意：

-   网络ID要一致 `1731313` 

-   用户信息 使用初始化中的用户 `0xbc4aA009599A1A95ac45Ce0E9971a701519735b2` 

```shell
nohup geth --datadir ./data --networkid 1731313 --nat extip:192.168.110.131 --http --http.addr 0.0.0.0 --http.vhosts "*" --http.corsdomain "*" --http.api "eth,net,web3,debug,les,txpool" --rpc.enabledeprecatedpersonal --netrestrict 192.168.0.0/16 --miner.threads 1 --allow-insecure-unlock --miner.etherbase=0xbc4aA009599A1A95ac45Ce0E9971a701519735b2 --unlock bc4aA009599A1A95ac45Ce0E9971a701519735b2 --password data/password.txt 2> 1.log &
# --port 30303 --authrpc.port 8551 --http.port 8545
```



### (3) 连接该节点

在节点1上 手动添加该节点信息，让其作为静态节点连接

**1）在主机2上查看本节点信息** 

```shell
# Javascript 控制台通过 IPC 连接到本机 Geth 节点，进入控制台
geth attach data/geth.ipc

# 查看节点信息。
admin.nodeInfo
# 记录enode信息
'''
enode://655ec0c9744d7895b68f88a55bc330707a085904a90ea0235307aeb09993ac16d10f3d82450e3f044cd4a8e7d16e2b37dd5054fab63e7b5162f7a3489fd9eba4@192.168.110.131:30303
'''
```

**2）在主机1的首个节点中 添加本节点** 

```shell
# 进入首个节点的控制台后，执行命令：
admin.addPeer("enode://655ec0c9744d7895b68f88a55bc330707a085904a90ea0235307aeb09993ac16d10f3d82450e3f044cd4a8e7d16e2b37dd5054fab63e7b5162f7a3489fd9eba4@192.168.110.131:30303")
# 注意：此encode信息为 本节点 查询到的节点信息，ip地址注意修改为 本节点的 局域网或映射后的公网地址。
```

3）检查

```shell
# 查看peer节点数量
net.peerCount
# 查看网络节点情况
admin.peers
```

>   查看网络节点情况
>
>
>   ```shell
>   > admin.peers
>   [{
>       caps: ["eth/66", "eth/67", "eth/68", "snap/1"],
>       enode: "enode://655ec0c9744d7895b68f88a55bc330707a085904a90ea0235307aeb09993ac16d10f3d82450e3f044cd4a8e7d16e2b37dd5054fab63e7b5162f7a3489fd9eba4@192.168.110.131:30303",
>       id: "6af8a3ea576f8e18a095cfc221c4c154a4147fe7ed5868faee2ca636b4afe8c5",
>       name: "Geth/v1.11.6-stable-ea9e62ca/linux-amd64/go1.20.3",
>       network: {
>         inbound: false,
>         localAddress: "192.168.110.130:47328",
>         remoteAddress: "192.168.110.131:30303",
>         static: false,
>         trusted: false
>       },
>       protocols: {
>         eth: {
>           version: 68
>         },
>         snap: {
>           version: 1
>         }
>       }
>   }]
>   ```
>
>   从当前结果来看，已经可以看到网络加入成功，在network内容中，可以看到两个节点ip



### (4) 测试

在主机2执行

```shell
# Javascript 控制台通过 IPC 连接到本机 Geth 节点。进入控制台
geth attach data/geth.ipc
```

```shell
# 查看peer节点数量
> net.peerCount
# 查看网络节点情况
> admin.peers

# 查询账户信息
> eth.accounts
["0xbc4aa009599a1a95ac45ce0e9971a701519735b2"]

> acc0='b547f78de534aaa2f2f21243e92cc82495e7c4f3'
> acc2='07c6c17bd957b1ffc8741e6354545009c43c82f7'
> acc1='bc4aa009599a1a95ac45ce0e9971a701519735b2'

> eth.getBalance(acc0)
> eth.getBalance(acc1)
> eth.getBalance(acc2)
```

经过测试，主机2 geth客户端可以获取主机1上账户的余额。





# 搭建完成后 连接区块链节点



## 服务器本地 Javascript 控制台连接

在区块链节点本机，通过geth命令连接节点，进入控制台

```shell
geth attach data/geth.ipc
```



## 私链连接信息

```shell
http.port 远程服务的端口：192.168.110.130:8545、192.168.110.131:8545
networkid 网络ID：1731313
```




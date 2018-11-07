# 项目目录解析

## 前言
> 对项目目录进行解析。

## 目录结构


```lua
app                  项目根目录
    - data              本地数据文件夹
        - string         字符串目录
            + en            英文目录
            + zh            中文目录
    + include             配置常量枚举目录
        
    - net                网络目录
        + FakeServer       假服务器目录
        + pbc              Protobuf 相关
    - player             玩家目录

    - scenes            场景集合
        - layers        弹窗
            + common      公共弹窗
            + hall        大厅弹窗
            + ...
        + login         登录场景
        + hall          大厅场景
        + test          测试场景
    + user              用户目录

    + storage            持久化

cocos           cocos引擎根目录

framework            框架根目录
    - base              基础目录
    - event             事件目录，逻辑消息，显示消息，网络消息
    - graphics          处理引擎控件节点的目录
    - sys               跟原生交互的目录
    - utils             工具类
```

从这个目录结构可以看出，根目录下只有三个文件夹， app， cocos，framework。
* app 对应的是我们项目，关于项目的功能都包含在里面
* cocos 是引擎提供的底层文件
* framework 是定制的框架



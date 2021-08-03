## Kubeflow 使用教程
- [kubeflow安装](/README.md)
- [kubeflow各组件介绍](/docs/introduction.md)

## 安装步骤
>这里默认已安装k8s集群

>由于 kubeflow 实验组件较多，最好准备机器的最低配置能够大于*CPU8核,内存32G*以上。

**1.拉取本项目**
```shell
git clone https://github.com/yangchenwen/kubeflow-manifests.git
```

**2.安装StorageClass和local-path-provisioner**
```shell
cd kubeflow-manifests
kubectl apply -f local-path/local-path-storage.yaml
```

**3.安装kubeflow组件**
```shell
python install.py
```

等待镜像拉取，由于涉及的镜像比较多，要20~30分钟左右，可以通过命令查看是否就绪：

**4.查看结果**
```shell
kubectl get pod -A
```
如果所有pod 都running了表示安装完了。

*注：除了kubeflow命名空间，该一键安装工具也会安装istio,knative,因此也要保证这两个命名空间下的服务全部running*

全部pod running后，可以访问本地的30000端口（istio-ingressgateway设置了nodeport为30000端口），就可以看到登录界面了：
![](/example/dex登录界面.png)

输入账号密码即可登录，这里的账号密码可以通过`patch/auth.yaml`进行更改。
默认的用户名是`admin@example.com`，密码是`password`

登录后进入kubeflow界面：
![](/example/kubeflow-dashboardcenter.png)


## 踩坑记录

**1、登录后显示No Namespaces**
>解决：
```shell
kubectl delete -f patch/auth.yaml
kubectl apply -f patch/auth.yaml
```

**2、 查看pipeline相关页面报错：Unknown database 'mlpipeline'**
>解决：
```shell
kubectl apply -f manifest1.3/017-pipeline-env-platform-agnostic-multi-user.yaml
```

**3、执行```kubectl apply -f patch/auth.yaml```时报错： error: unable to recognize "patch/auth.yaml": no matches for kind "Profile" in version "kubeflow.org/v1beta1"**
>解决：
```shell
kubectl apply -f manifest1.3/024-profiles-overlays-kubeflow.yaml
kubectl delete -f patch/auth.yaml
kubectl apply -f patch/auth.yaml
```

**4、 pipeline运行出错**
>解决：
```shell
kubectl delete -f  manifest1.3/017-pipeline-env-platform-agnostic-multi-user.yaml # 多操作几次，确保相关的资源都删干净
kubectl apply -f  manifest1.3/017-pipeline-env-platform-agnostic-multi-user.yaml
kubectl apply -f patch/pipeline-env-platform-agnostic-multi-user.yaml
kubectl apply -f patch/workflow-controller.yaml
```

**5、katib运行时Pod NotReady**
>解决：https://github.com/kubeflow/katib/issues/1577

在训练样例的yaml文件的```.trialSpec.spec.template.metadata.annotations```节点下增加```sidecar.istio.io/inject: "false"```
参考```example/kitab-random-example.yaml```

**6、安装的Kale无法正常工作**
>解决：https://github.com/kubeflow/pipelines/issues/4440
```shell
kubectl apply -f kale/kale-patch.yaml
```

**7、pod ```admission-webhook-deployment-xxx``` 报错：MountVolume.SetUp failed for volume "webhook-cert" : secret "webhook-certs" not found**
>解决：
```shell
kubectl delete -f manifest1.3/021-admission-webhook-overlays-cert-manager.yaml
kubectl apply -f manifest1.3/021-admission-webhook-overlays-cert-manager.yaml
```

**8、pod ```katib-controller-xxx``` 报错MountVolume.SetUp failed for volume "cert" : secret "katib-webhook-cert" not found**
>解决：
```shell
kubectl apply -f manifest1.3/019-katib-installs-katib-with-kubeflow-cert-manager.yaml
#查看katib-webhook-cert是否创建成功
kubectl get secret katib-webhook-cert -n kubeflow
#重启pod
kubectl delete pod katib-controller-xxx -n kubeflow
```

**9、 pod ```kfserving-controller-manager-xxx```报错：MountVolume.SetUp failed for volume "cert" : secret "kfserving-webhook-server-cert" not found**
>解决：
```shell
kubectl apply -f manifest1.3/018-kfserving-overlays-kubeflow.yaml
#查看kfserving-webhook-server-cert是否创建成功
kubectl get secret -A|grep kfserving-webhook-server-cert
#重启pod
kubectl delete pod  kfserving-controller-manager-xxx -n kubeflow
```
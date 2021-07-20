#!/bin/python
#coding:utf-8
import os
import subprocess

import patch


def install(path):
    for root,path,files in os.walk(path):
        files = sorted(files)  # install yaml by order
        for f in files:
            installfile = root + "/" + f
            cmd = "kubectl apply -f {installfile}".format(installfile=installfile)
            print(cmd)
            p = subprocess.Popen(cmd,shell=True,stdout=subprocess.PIPE)
            out = p.stdout.read()
            print(out)
            p.wait()


if __name__ == '__main__':
    # 安装文件
    path = "./manifest1.3"
    install(path)

    # 安装patch
    patchPath = "./patch"
    patch.patchInstall(patchPath)
#!/bin/python
#coding:utf-8
import os
import subprocess
import sys
import time

'''
因为一些patch安装涉及到的一些修改需要重启pod，所以先删除再安装
'''
def patchInstall(path):
    print("start to patch...")
    for root,path,files in os.walk(path):
        for f in files:
            installfile = root + "/" + f
            cmd_delete = "kubectl delete -f {installfile}".format(installfile=installfile)
            print(cmd_delete)
            p = subprocess.Popen(cmd_delete,shell=True,stdout=subprocess.PIPE)
            out = p.stdout.read()
            print(out)
            p.wait()
            cmd_apply = "kubectl apply -f {installfile}".format(installfile=installfile)
            print(cmd_apply)
            p = subprocess.Popen(cmd_apply,shell=True,stdout=subprocess.PIPE)
            out = p.stdout.read()
            print(out)
            p.wait()
            time.sleep(10)


if __name__ == '__main__':
    # 安装patch
    patchPath = "./patch"
    patchInstall(patchPath)
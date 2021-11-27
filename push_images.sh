#!/bin/bash

# 获取内网镜像仓库地址
read -p "${C}内网镜像仓库地址:${Q}" nexus_addr
if [ -z "${nexus_addr}" ];then
  exit 0
fi
if [[ ${nexus_addr} =~ /$ ]];
  then echo
  else nexus_addr="${nexus_addr}/"
fi

#push镜像
echo "${C}start: 开始push镜像到harbor...${Q}"
for push_image in $(docker images | sed '1d' | awk '{print $1":"$2}')
do
  echo -e "${Y}    开始推送$push_image...${Q}"
  image_name_tag=$(echo $push_image | awk -F/ '{print $NF}')
  docker tag $push_image "$nexus_addr$image_name_tag"
  docker push "$nexus_addr$image_name_tag"
  echo "镜像：$nexus_addr$image_name_tag 推送完成..."
done

echo -e "${C}end: 全部镜像推送完成\n\n${Q}"
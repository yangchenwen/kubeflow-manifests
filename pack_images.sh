#!/bin/bash
G=`tput setaf 2`
C=`tput setaf 6`
Y=`tput setaf 3`
Q=`tput sgr0`


# 创建文件夹
mkdir images

# save镜像
IMAGES_LIST=($(docker images | sed '1d' | awk '{print $1}'))
IMAGES_NM_LIST=($(docker images | sed  '1d' | awk '{print $1"-"$2}'| awk -F/ '{print $NF}'))
IMAGES_NUM=${#IMAGES_LIST[*]}
echo "镜像列表....."
docker images
# docker images | sed '1d' | awk '{print $1}'
for((i=0;i<$IMAGES_NUM;i++))
do
  echo "正在save ${IMAGES_LIST[$i]} image..."
  docker save "${IMAGES_LIST[$i]}" -o ./images/"${IMAGES_NM_LIST[$i]}".tar.gz
done
ls images
echo -e "${C}end: 保存完成\n\n${Q}"

# 打包镜像
#tag_date=$(date "+%Y%m%d%H%M")
echo "${C}start: 打包镜像：images.tar.gz${Q}"
tar -czvf images.tar.gz images
echo -e "${C}end: 打包完成\n\n${Q}"
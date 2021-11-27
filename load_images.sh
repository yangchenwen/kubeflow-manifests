#!/bin/bash
G=`tput setaf 2`
C=`tput setaf 6`
Y=`tput setaf 3`
Q=`tput sgr0`

tar -xzf images.tar.gz
cd images
# tag
echo "${C}start: 加载镜像${Q}"
for image_name in $(ls ./)
do
  echo -e "${Y}    开始load $image_name...${Q}"
  docker load < ${image_name}
done
echo -e "${C}end: 加载完成...\n\n${Q}"
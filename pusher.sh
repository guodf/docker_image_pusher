while IFS= read -r line || [ -n "$line" ]; do
    # 忽略空行与注释
    platform=$(echo "$line" | awk '{print $1}')
    src=$(echo "$line" | awk '{print $2}')
    dst=$(echo "$line" | awk '{print $3}')
    platform=$(echo "$line" | awk -F'--platform[ =]' '{if (NF>1) print $2}' | awk '{print $1}')
    # 如果存在架构信息 将架构信息拼到镜像名称前面
    if [ -z "$platform" ]; then
        platform_prefix=""
    else
        platform_prefix="-${platform//\//_}"
    fi

    dst="$ALIYUN_REGISTRY/$ALIYUN_NAME_SPACE/$dst${platform_prefix}"
    echo "docker pull --platform=$platform $src"
    docker pull $src
    echo "docker tag $src $dst"
    docker tag $src $dst
    echo $ALIYUN_REGISTRY_PASSWORD |docker login -u $ALIYUN_REGISTRY_USER --password-stdin $ALIYUN_REGISTRY
    echo "docker push $dst"
    docker push $dst
    docker logout $ALIYUN_REGISTRY
    docker rmi $src
    docker rmi $dst
done < images.txt
DOCKER_IMAGE_NAME=$1
DOCKER_IMAGE_VERSION=$2

# If script run to error, exist -1;
function _do() 
{
        "$@" || { echo "exec failed: ""$@"; exit -1; }
}

build_image(){  
    _do cd ${DOCKER_IMAGE_NAME}"/"${DOCKER_IMAGE_VERSION}
    _do docker build -t "${DOCKER_IMAGE_NAME}" .
    _do cd $TRAVIS_BUILD_DIR    
    testBuildImage=$(docker images | grep "${DOCKER_IMAGE_NAME}")
    if [ -z "${testBuildImage}" ]; then 
        echo "FAILED - Build fail!!!"
        exit 1
    else
        echo "${testBuildImage}" | tee -a result.log
        echo "PASSED - Build Successfully!!!." | tee -a result.log
    fi
    _do cd ..
    _do cd ..
}

build_image

DOCKER_IMAGE_NAME=$1
DOCKER_IMAGE_VERSION=$2

# If script run to error, exist -1;
function _do() 
{
        "$@" || { echo "exec failed: ""$@"; exit -1; }
}

setTag_push_rm(){
    echo "TAG: ${TAG}"
    _do docker tag "${DOCKER_IMAGE_NAME}" "${DOCKER_ACCOUNT}"/"${DOCKER_IMAGE_NAME}":"${TAG}"
    testBuildImage=$(docker images | grep "$TAG")
    if [ -z "${testBuildImage}" ]; then 
        echo "FAILED - Set TAG Failed!!!"
        exit 1
    else
        echo "${testBuildImage}" | tee -a result.log
        echo "PASSED - Set TAG Successfully!." | tee -a result.log
    fi
    _do docker push "${DOCKER_ACCOUNT}"/"${DOCKER_IMAGE_NAME}":"${TAG}"
    echo "PASSED - Pushed  ${DOCKER_ACCOUNT}/${DOCKER_IMAGE_NAME}:${TAG} Successfully!." | tee -a result.log
    echo "INFORMATION: Before rmi - docker images"
    _do docker images
    echo "INFORMATION - RM ""${DOCKER_ACCOUNT}"/"${DOCKER_IMAGE_NAME}":"${TAG}"
    _do docker rmi "${DOCKER_ACCOUNT}"/"${DOCKER_IMAGE_NAME}":"${TAG}"
    echo "INFORMATION - After rmi - docker images"
    _do docker images
}

echo "Stage1 - Set Tag and Push" | tee -a result.log
echo "Build Number: ${TRAVIS_BUILD_NUMBER}"
echo "TRAVIS_EVENT_TYPE: ${TRAVIS_EVENT_TYPE}"
echo "TRAVIS_COMMIT_MESSAGE: ${TRAVIS_COMMIT_MESSAGE}"

isSignOff="false"
SignOff="#sign-off"        
signOff=$(echo "${TRAVIS_COMMIT_MESSAGE}" | grep "${SignOff}")
if [ -n "${signOff}" ]; then #contains "#Sign-off"
    isSignOff="true"
fi
if [ $DOCKER_ACCOUNT == $PROD_DOCKER_ACCOUNT ]; then #It's master branch
    echo "INFORMATION - This time, push to PROD docker hub....."
    isSignOff="true"
    _do echo "${DOCKER_PASSWORD}" | _do docker login -u="${DOCKER_USERNAME}" --password-stdin
else
    echo "INFORMATION - This time push to TEST docker hub......"
    _do echo "${DOCKER_PASSWORD}" | _do docker login "${DOCKER_ACCOUNT}" -u="${DOCKER_USERNAME}" --password-stdin
fi

if [ $isSignOff == "true" ]; then
    echo "INFORMATION - This time, set tag as "${DOCKER_IMAGE_VERSION}" and push....."    
    TAG=${DOCKER_IMAGE_VERSION}       
else
    echo "INFORMATION - This time, set tag as "${DOCKER_IMAGE_VERSION}"-"${TRAVIS_BUILD_NUMBER}" and push....."    
    TAG=${DOCKER_IMAGE_VERSION}"-"${TRAVIS_BUILD_NUMBER}        
fi
echo "INFORMATION - Set TAG as ""${TAG}"" and push......" 
setTag_push_rm

echo "========================================"
echo "Stage2 - PULL and Verify"
echo "INFORMATION - Start to Pull ""${DOCKER_ACCOUNT}"/"${DOCKER_IMAGE_NAME}":"${TAG}"
echo "INFORMATION - Before Pull - docker images"
_do docker images
_do docker run -d -p 80:80 --name testdocker $DOCKER_ACCOUNT/${DOCKER_IMAGE_NAME}:"$TAG"
echo "INFORMATION: After Pull - docker images"
_do docker images
testBuildImage=$(docker images | grep "${TAG}")
    if [ -z "$testBuildImage" ]; then 
        echo "FAILED - Docker pull and run Failed!!!"
        docker images
        exit 1
    else
        echo "$testBuildImage"
        echo "$testBuildImage" >> result.log
        echo "PASSED - Docker image pull and run Successfully!. You can manually verify it!" | tee -a result.log
    fi
_do docker stop testdocker
_do docker rm testdocker
_do docker rmi ${DOCKER_ACCOUNT}"/"${DOCKER_IMAGE_NAME}":"${TAG}

# Deal With latest version
if [ $isSignOff == "true" ]; then #Is it "#sign-off" or "master_brnach"?
    _do cd ${DOCKER_IMAGE_NAME}
    if test -e latest.txt; then
        LATEST_VERSION=$(cat latest.txt)
        _do cd ..
        echo "LATEST_VERSION:"$LATEST_VERSION
        if [ $DOCKER_IMAGE_VERSION == $LATEST_VERSION ]; then             
            echo "INFORMATION - This time, also need to push as latest version......" | tee -a result.log    
            TAG="latest"
            echo "INFORMATION - Set TAG as ""${TAG}"" and push......" 
            setTag_push_rm        
        fi
    else
        _do cd ..
    fi    
fi

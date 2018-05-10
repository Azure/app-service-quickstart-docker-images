DOCKER_IMAGE_NAME=$1
DOCKER_IMAGE_VERSION=$2

# If script run to error, exist -1;
function _do() 
{
        "$@" || { echo "exec failed: ""$@"; exit -1; }
}

test_Dockerfile(){
    _do docker inspect ${DOCKER_IMAGE_NAME} > inspect.json
    echo "INFORMATION: Details of "${DOCKER_IMAGE_NAME}":"
    cat inspect.json

    # Check SSH Ports
    # Only 2 ports allowed where one is always 2222
    testPORTS=$(jq .[].Config.ExposedPorts inspect.json | grep -o ":" | wc -w)
    if [ ${testPORTS} -gt 2 ]; then
        echo "${testPORTS}" 
        echo "FAILED - Too many ports are exposed!!!"
        exit 1
    fi

    testSSH=$(jq .[].Config.ExposedPorts inspect.json | grep 2222)
    if [ -z "${testSSH}" ]; then 
        echo "FAILED - PORT 2222 isn't opened, SSH isn't working!!!"
        exit 1
    else
        echo "${testSSH}"
        echo "PASSED - PROT 2222 is opened."
    fi 

    # Check Volume
    testVOLUME=$(jq .[].Config.Volumes inspect.json | grep null)
    if [ -z "${testVOLUME}" ]; then 
        testVOLUME=$(jq .[].Config.Volumes inspect.json)
        echo "${testVOLUME}"
        echo "FAILED - These VOLUME lines should not be existed!!!"
        exit 1
    else
        echo "PASSED - Great, there is no VOLUME lines."            
    fi

    # Check User
    testUSER=$(jq .[].Config.User inspect.json)
    if test "${testUSER}" != '""' ; then        
        echo "${testUSER}"
        echo "FAILED - These USER lines should not be existed!!!"
        exit 1
    else
        echo "PASSED - Great, there is no USER lines."            
    fi
}

echo "Docker: "${DOCKER_IMAGE_NAME}"/"${DOCKER_IMAGE_VERSION} | tee -a result.log
test_Dockerfile
echo "PASSED - Passed this stage." | tee -a result.log





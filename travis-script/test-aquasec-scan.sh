DOCKER_IMAGE_NAME=$1

# If script run to error, exist -1;
function _do() 
{
        "$@" || { echo "exec failed: ""$@"; exit -1; }
}

echo "========================================" |  tee -a result.log
echo "INFORMATION - AquaSec Scanner-cli......" | tee -a result.log

if [ $DOCKER_ACCOUNT == $PROD_DOCKER_ACCOUNT ]; then #It's master branch
    echo "This is Master Branch, SKIP this process......" | tee -a result.log
    echo "========================================" | tee -a result.log
    exit 0
fi

echo "DOCKER_IMAGE_NAME: ${DOCKER_IMAGE_NAME}"

AQUASEC_CONTAINRE="${DOCKER_ACCOUNT}"/scanner-cli:3.0

docker run -v /var/run/docker.sock:/var/run/docker.sock ${AQUASEC_CONTAINRE} scan \
    -H ${AQUASEC_SITE} -U ${AQUASEC_USER} -P ${AQUASEC_PASSWORD} \
    --local ${DOCKER_IMAGE_NAME} \
    --register --registry local_scanner \
    > scan_log.json
echo "========================================"
#cat scan_log.json

testResult=$(jq '.image_assurance_results | .disallowed' scan_log.json)
#echo "testResult? "${testResult}
if [ ! -z "$testResult" ]; then    
    echo "FAILED - High vulnerablilites are found!!!" | tee -a result.log
    echo $(jq '.image_assurance_results' scan_log.json) | tee -a result.log
else
    echo "PASSED - No high vulnerability is found !" | tee -a result.log
fi

echo "INFO - Get scan result......"
curl -u ${AQUASEC_USER}:${AQUASEC_PASSWORD}  \
       ${AQUASEC_SITE}/api/v1/scanner/registry/local_scanner/image/${DOCKER_IMAGE_NAME}:latest/scan_result > scan_result.json
jq . scan_result.json | tee -a result.log
echo ""

exit 0



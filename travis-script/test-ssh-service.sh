# Check SSH is opened

echo "INFORMATION - Blow service are running..."
docker top testdocker
testSSHEnable=$(docker top testdocker | grep sshd)
try_ssh_count=1

while [ $try_ssh_count -le 10 ]
do 
    if [ -z "${testSSHEnable}" ]; then 
        echo "INFORMATION - Haven't found SSH Service this time, Wait 10s, try again..."
        sleep 10s
        let try_ssh_count+=1
        echo "INFORMATION - Blow service are running..."
        docker top testdocker
        testSSHEnable=$(docker top testdocker | grep sshd)        
    else
        echo "${testSSHEnable}"
        echo "PASSED - SSH Service is running..." | tee -a result.log
        break
    fi
done

if [ -z "${testSSHEnable}" ]; then
    echo "FAILED - Tried 10 times, still hasn't found SSH service!!!"
    exit -1
fi



echo "Show ENV Paramters:"

# TRAVIS_ALLOW_FAILURE: 
# set to true if the job is allowed to fail.
# set to false if the job is not allowed to fail.
echo "TRAVIS_ALLOW_FAILURE: $TRAVIS_ALLOW_FAILURE"
# TRAVIS_BRANCH: 
# for push builds, or builds not triggered by a pull request, this is the name of the branch.
# for builds triggered by a pull request this is the name of the branch targeted by the pull request.
# for builds triggered by a tag, this is the same as the name of the tag (TRAVIS_TAG). 
echo "TRAVIS_BRANCH: $TRAVIS_BRANCH"
# TRAVIS_BUILD_DIR: The absolute path to the directory where the repository being built has been copied on the worker.
echo "TRAVIS_BUILD_DIR: $TRAVIS_BUILD_DIR"
# TRAVIS_BUILD_ID: The id of the current build that Travis CI uses internally.
echo "TRAVIS_BUILD_ID: $TRAVIS_BUILD_ID"
# TRAVIS_BUILD_NUMBER: The number of the current build (for example, “4”).
echo "TRAVIS_BUILD_NUMBER: $TRAVIS_BUILD_NUMBER"
# TRAVIS_COMMIT: The commit that the current build is testing.
echo "TRAVIS_COMMIT: $TRAVIS_COMMIT"
# TRAVIS_COMMIT_MESSAGE: The commit subject and body, unwrapped.
echo "TRAVIS_COMMIT_MESSAGE: $TRAVIS_COMMIT_MESSAGE"
# TRAVIS_COMMIT_RANGE: The range of commits that were included in the push or pull request. (Note that this is empty for 
# builds triggered by the initial commit of a new branch.)
echo "TRAVIS_COMMIT_RANGE: $TRAVIS_COMMIT_RANGE"
# TRAVIS_EVENT_TYPE: Indicates how the build was triggered. One of push, pull_request, api, cron.
echo "TRAVIS_EVENT_TYPE: $TRAVIS_EVENT_TYPE"
# TRAVIS_JOB_ID: The id of the current job that Travis CI uses internally.
echo "TRAVIS_JOB_ID: $TRAVIS_JOB_ID"
# TRAVIS_JOB_NUMBER: The number of the current job (for example, “4.1”).
echo "TRAVIS_JOB_NUMBER: $TRAVIS_JOB_NUMBER"
# TRAVIS_OS_NAME: On multi-OS builds, this value indicates the platform the job is running on. Values are linux and osx currently, 
# to be extended in the future.
echo "TRAVIS_OS_NAME: $TRAVIS_OS_NAME"
# TRAVIS_PULL_REQUEST: The pull request number if the current job is a pull request, “false” if it’s not a pull request.
echo "TRAVIS_PULL_REQUEST: $TRAVIS_PULL_REQUEST"
# TRAVIS_PULL_REQUEST_BRANCH: 
# if the current job is a pull request, the name of the branch from which the PR originated.
# if the current job is a push build, this variable is empty ("").
echo "TRAVIS_PULL_REQUEST_BRANCH: $TRAVIS_PULL_REQUEST_BRANCH"
# TRAVIS_PULL_REQUEST_SHA: 
# if the current job is a pull request, the commit SHA of the HEAD commit of the PR.
# if the current job is a push build, this variable is empty ("").
echo "TRAVIS_PULL_REQUEST_SHA: $TRAVIS_PULL_REQUEST_SHA"
# TRAVIS_PULL_REQUEST_SLUG: 
# if the current job is a pull request, the slug (in the form owner_name/repo_name) of the repository from which the PR originated.
# if the current job is a push build, this variable is empty ("").
echo "TRAVIS_PULL_REQUEST_SLUG: $TRAVIS_PULL_REQUEST_SLUG"
# TRAVIS_REPO_SLUG: The slug (in form: owner_name/repo_name) of the repository currently being built.
echo "TRAVIS_REPO_SLUG: $TRAVIS_REPO_SLUG"
# TRAVIS_SECURE_ENV_VARS: 
# set to true if there are any encrypted environment variables.
# set to false if no encrypted environment variables are available.
echo "TRAVIS_SECURE_ENV_VARS: $TRAVIS_SECURE_ENV_VARS"
# TRAVIS_SUDO: true or false based on whether sudo is enabled.
echo "TRAVIS_SUDO: $TRAVIS_SUDO"
# TRAVIS_TEST_RESULT: is set to 0 if the build is successful and 1 if the build is broken.
echo "TRAVIS_TEST_RESULT: $TRAVIS_TEST_RESULT"
# TRAVIS_TAG: If the current build is for a git tag, this variable is set to the tag’s name.
echo "TRAVIS_TAG: $TRAVIS_TAG"

docker_count=0

show_docker_list(){
    echo ""
    echo ""
    echo "========================================" | tee -a result.log  
     echo "INFORMATION - This time, we need to verify below dockers:" | tee -a result.log
    echo " "
    echo " "
    docker_count=1
    while test $[docker_count] -le $[dockers]
    do       
        echo ${docker_image_name["${docker_count}"]}"/"${docker_image_version["${docker_count}"]}
        echo ${docker_image_name["${docker_count}"]}"/"${docker_image_version["${docker_count}"]} >> result.log       
        let docker_count+=1
    done
}

merge_to_docker_list(){
    echo "========================================"
    echo "INFORMATION - START TO MERGE"
    if test $[docker_count] -eq 0;then
	    echo "This is first group..."		
        #This is first Group, just add.
        temp_docker_count=0
        while test $[temp_docker_count] -lt $[temp_dockers]
        do
            let temp_docker_count+=1
            let docker_count+=1                
            docker_image_name[$docker_count]=${temp_docker_image_name[${temp_docker_count}]}
            docker_image_version[$docker_count]=${temp_docker_image_version[${temp_docker_count}]}
        done
		dockers=${#docker_image_name[@]}
    else
	    echo "Already have some dockers exist in the list..."
		echo "Already have docker count: "$docker_count
        touch merge_docker_list.txt
        docker_count=1        
        while test $[docker_count] -le $[dockers]
        do       
            echo ${docker_image_name["${docker_count}"]}"/"${docker_image_version["${docker_count}"]} >> merge_docker_list.txt       
            let docker_count+=1
        done   
        temp_docker_count=1
        while test $[temp_docker_count] -le $[temp_dockers]
        do       
            echo ${temp_docker_image_name["${temp_docker_count}"]}"/"${temp_docker_image_version["${temp_docker_count}"]} >> merge_docker_list.txt       
            let temp_docker_count+=1
        done
        #echo "merge_docker_list:"
        #cat merge_docker_list.txt
        cat merge_docker_list.txt | sort -u > sort_unique_list.txt
		rm merge_docker_list.txt
        echo "INFORMATION - sort_unique_docker_list:"
        cat sort_unique_list.txt
		#put sort_unique_list.txt to docker_list
		line_count_sort_list=1
		lines_sort_list=$(wc -l sort_unique_list.txt)
		lines_sort_list=${lines_sort_list%%' '*}
		dockers=$lines_sort_list		
		while test $[line_count_sort_list] -le $[lines_sort_list] 
		do
		    #echo "Deal with "$line_count_sort_list" line:"
            current_line=$(sed -n "${line_count_sort_list}p" sort_unique_list.txt)
			#echo "Current line: "${current_line}
			docker_image_name[$line_count_sort_list]=${current_line%%/*}
            docker_image_version[$line_count_sort_list]=${current_line##*/}
		    let line_count_sort_list+=1			
		done
        rm sort_unique_list.txt		
    fi
	echo "INFORMATION - MERGED!"
	echo "========================================"
    
}

get_files_from_commit(){
    echo "start to get commit files..."
    curl https://api.github.com/repos/"${TRAVIS_REPO_SLUG}"/commits/"$commit_sha" > commit_files.json
	jq '.files | .[] | .filename' commit_files.json > commit_files.txt
	sed -i 's/\"//g' commit_files.txt
	echo "Below files are changed:" | tee -a result.log
    cat commit_files.txt
    cat commit_files.txt >> result.log
    
    last_docker_image_name="nothing"
    last_docker_image_version="nothing"
    line_count=1
    lines=$(wc -l commit_files.txt)
    lines=${lines%%' '*}
    echo "Total lines: "${lines}
    temp_docker_count=0
    while [ $line_count -le $lines ] 
    do
	    #echo "Deal with "$line_count" line:"
        current_line=$(sed -n "${line_count}p" commit_files.txt)
        #echo "Current line: "${current_line}
        # The normal line should be DOCKER_IMAGE_NAME/DOCKER_IMAGE_VERSION/filename
        # The count of '/' should be >= 2
        slash_count=$(echo ${current_line} | grep -o '/' | wc -l)		
        if [ $slash_count -lt 2 ]; then
            echo "INFORMATION - This file doesn't related with any Docker."        
        else			
            current_docker_image_name=${current_line%%/*}
            current_docker_image_version=${current_line#*/}
            current_docker_image_version=${current_docker_image_version%%/*}			
            if [[ "$current_docker_image_name" != "$last_docker_image_name" || "$current_docker_image_version" != "$last_docker_image_version" ]]; then
                let temp_docker_count+=1
                temp_docker_image_name[$temp_docker_count]=$current_docker_image_name
				temp_docker_image_version[$temp_docker_count]=$current_docker_image_version
				last_docker_image_name=$current_docker_image_name
                last_docker_image_version=$current_docker_image_version                 
           fi 
        fi
	    let line_count+=1
    done
    temp_dockers=$temp_docker_count
#	rm commit_files.txt
}

#Test ENV: 
#TRAVIS_REPO_SLUG=leonzhang77/docker-group
#TRAVIS_COMMIT=d6cf2b5859abd88dde0ef5694dd2d9cbbbffd938
#TRAVIS_PULL_REQUEST=false
#TRAVIS_EVENT_TYPE=pull_request
#
# main thread start from here!!!!
echo "========================================"
touch result.log
# Get Changed files list / dockers list
if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
    echo "INFORMATION - This is a PUSH/MERGE, Contains below Commit:" | tee -a result.log
    echo $TRAVIS_COMMIT
    echo $TRAVIS_COMMIT >> result.log    
    commit_sha=$TRAVIS_COMMIT    
    get_files_from_commit
	merge_to_docker_list    
else
    curl https://api.github.com/repos/"${TRAVIS_REPO_SLUG}"/pulls/"${TRAVIS_PULL_REQUEST}"/commits > TEMP.txt
    jq '.[] | .sha' TEMP.txt > PR_SHAs.txt
    sed -i 's/\"//g' PR_SHAs.txt	
    rm TEMP.txt
    echo "INFORMATION - This is a PR, Contains below Commits:" | tee -a result.log
    cat PR_SHAs.txt
    cat PR_SHAs.txt >> result.log
    line_count_sha=1
    lines_sha=$(wc -l PR_SHAs.txt)
    lines_sha=${lines_sha%%' '*}
    while [ $line_count_sha -le $lines_sha ] 
    do
        echo "Deal with line:"$line_count_sha
        current_line=$(sed -n "${line_count_sha}p" PR_SHAs.txt)
        #echo "Current line: "${current_line}        
        commit_sha=${current_line##* }
		echo "Current SHA: "$commit_sha
        get_files_from_commit
        merge_to_docker_list
		let line_count_sha+=1
    done
fi

echo "dockers: "${dockers}
if test $[dockers] -eq 0; then
    echo "INFORMATION - This time, doesn't change any files related with docker, no need to verify." | tee -a result.log
    echo "========================================"
    echo "===============Result.log:=============="
    echo "========================================"
    cat result.log
    echo "Everything is OK, return 0"
    exit 0
fi

show_docker_list
echo "========================================" | tee -a result.log
# Get folders from buildin repo
if [ ! -e buildin_folders.txt ]; then
    curl https://api.github.com/repos/azure/app-service-builtin-images/contents | jq '.[] | .path' > buildin_folders.txt
fi
# Default account is TEST, if it's master branch, set PROD account.
if [ "$TRAVIS_BRANCH" == "master" ];then
    echo "========================================" | tee -a result.log
    echo "INFORMATION - Merge to master branch, using PROD......" | tee -a result.log
    DOCKER_USERNAME=$PROD_DOCKER_USERNAME
    DOCKER_ACCOUNT=$PROD_DOCKER_ACCOUNT
    DOCKER_PASSWORD=$PROD_DOCKER_PASSWORD    
fi
# Verify Docker files 1 by 1.
docker_count=1
while [ $docker_count -le $dockers ]
do
    docker_folder=${docker_image_name["${docker_count}"]}"/"${docker_image_version["${docker_count}"]}
    echo "========================================" | tee -a result.log
    echo "PATH: "$docker_folder	| tee -a result.log
    #Is this commit remove this Image/Version? If yes, we can skip this step.
    if test ! -d $docker_folder; then
        echo "INFORMATION: This commit Remove "${docker_image_name["${docker_count}"]}"/"${docker_image_version["${docker_count}"]}" !" | tee -a result.log
        echo "INFORMATION: SKIP this stage" | tee -a result.log
    else
        blank_count=0
        blank_count=$(echo ${docker_folder} | grep -o ' ' | wc -l)    
        if [ $blank_count -gt 0 ]; then
            echo "ERROR - blank char should not be include in folder name!"
            echo "ERROR - PATH: "${docker_image_name["${docker_count}"]}"/"${docker_image_version["${docker_count}"]}
            exit -1
        fi
        #verify_image_name
        #The image name should not be exist in buildin repo        
        resultExist=$(cat buildin_folders.txt | grep '"'${docker_image_name["${docker_count}"]}'"')
        if [ -z $resultExist ];then
            echo "PASS - There is no duplicate image name exist in buildin repo!!!"
        else
            echo "Build in repo folders:"
            cat buildin_folders.txt
            echo "ERROR - There is one duplicate image name exist in buildin repo: "$resultExist
            exit -1
        fi
        echo ""
        echo ""
        echo "INFORMATION - Start to Build......"${docker_image_name["${docker_count}"]}":"${docker_image_version["${docker_count}"]} | tee -a result.log
        echo "========================================" | tee -a result.log
        ./travis-script/test-build.sh ${docker_image_name["${docker_count}"]} ${docker_image_version["${docker_count}"]}
        test_result=$?		
		if ((test_result!=0)); then
		    echo "ERROR - Build failed, Please double check......"            
		    exit -1
		fi
        docker images
        # It's PR for build-test branch, verify docker files and run image locally.
        if [ "$TRAVIS_EVENT_TYPE" == "pull_request" ]; then
            echo "========================================" | tee -a result.log
            echo "INFORMATION - Start to Verify Docker files:" | tee -a result.log
            ./travis-script/test-dockerfile.sh ${docker_image_name["${docker_count}"]} ${docker_image_version["${docker_count}"]}
		    test_result=$?		
		    if [ $test_result -ne 0 ]; then
			    echo "ERROR - Verify failed, Please double check......"
			    exit -1
		    fi
            echo "========================================" | tee -a result.log
            echo "INFORMATION - Start to run Docker Image:" | tee -a result.log            
            docker run -d -p 80:80 --name testdocker ${docker_image_name["${docker_count}"]}
            test_result=$?		
		    if ((test_result!=0)); then
			    echo "ERROR - This image can't be run Normally failed, Please double check......"            
			    exit -1
		    fi
            # Verify SSH service is opened.
            ./travis-script/test-ssh-service.sh            
            docker stop testdocker            
            docker rm testdocker
        # It's Merge, push/pull/run.
        else
            echo "========================================" | tee -a result.log
            echo "INFORMATION - Start to PUSH/PULL/RUN:" | tee -a result.log
            ./travis-script/test-push-pull-run.sh ${docker_image_name["${docker_count}"]} ${docker_image_version["${docker_count}"]}
            test_result=$?		
		    if ((test_result!=0)); then
			    echo "ERROR - PUSH/PULL/RUN failed, Please double check......"            
			    exit -1
		    fi
            ./travis-script/test-aquasec-scan.sh ${docker_image_name["${docker_count}"]}
            test_result=$?
            if ((test_result!=0)); then
			    echo "ERROR - AquaSec Scanning failed, Please double check......"            
			    exit -1
		    fi
        fi        
    fi
    let docker_count+=1
done

# Everything is OK, return 0
echo "========================================"
echo "===============Result.log:=============="
echo "========================================"
cat result.log
echo "Everything is OK, return 0"
exit 0

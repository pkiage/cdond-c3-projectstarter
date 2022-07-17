# Bucket Name = $1
# bucket should have udapeople-  prefix
# in workflowID input what is after the prefix 
# e.g. if initial bucket is udapeople-tutafaulu 
# then $1 should be tutafaulu
# because udapeople- prefix already sorted in .circleci/files/cloudfront.yml file
cd .circleci/files
aws cloudformation deploy \
         --template-file cloudfront.yml \
         --stack-name cloudfrontStackInitial\
         --parameter-overrides WorkflowID=$1
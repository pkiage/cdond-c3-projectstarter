# Bucket Name = $1

cd .circleci/files
aws cloudformation deploy \
         --template-file cloudfront.yml \
         --stack-name CloudFormationStack\
         --parameter-overrides WorkflowID=$1
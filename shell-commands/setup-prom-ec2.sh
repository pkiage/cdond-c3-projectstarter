# CC6-L5-C6-Set Up Prometheus
aws cloudformation create-stack \
    --stack-name prometheusStack  \
    --template-body file://setup-prom-ec2.yml
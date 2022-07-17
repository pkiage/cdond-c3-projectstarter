# Endpoints to test:
# CloudFront domain name

if ping -c 5 $1 | grep ", 5 received,"
then
    echo "\nPASS: Domain is reachable with 0% package loss\n"
else
    echo "\nFAIL: Please investigate starting with below\n"
    ping -c 5 $1
fi

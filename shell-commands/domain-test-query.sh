# Endpoints to test:
# Database instance (TYPEORM_HOST)

if dig $1 | grep "status: NOERROR"
then
    echo "\nPASS(NOERROR): DNS response received\n"
elif dig $1 | grep "status: NXDOMAIN"
then
    echo "\nFAIL(NXDOMAIN): Non-Existent Domain\n"
else
    echo "\nFAIL: start investigating failure reason below\n"
    dig $1
    echo "\nNSLOOKUP\n"
    nslookup -debug $1
fi

# Endpoints to test:
# Database instance (TYPEORM_HOST)

# telnet endpoint port
# port: 5432

if sleep 3 | telnet $1 5432 | grep "Connected to"
then
    # echo "^]" # escape character (close connection)
    echo "\nPASS: Can connect to TYPEORM_HOST on port 5432\n"

else
    echo "\nFAIL: check endpoint name and configuration (inbound rules etc.)\n"
    telnet $1 5432
fi

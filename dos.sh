# #!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <number_of_requests>"
    exit 1
fi

COUNT=$1

requests=(
'GET /fake HTTP/1.1\nHost: www.example.com\nUser-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\nAccept-Language: en-US,en;q=0.5\nAccept-Encoding: gzip, deflate, br\nConnection: keep-alive\nUpgrade-Insecure-Requests: 1'

'GET /path HTTP/1.1\nHost: www.example.com\nUser-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\nAccept-Language: en-US,en;q=0.5\nAccept-Encoding: gzip, deflate, br\nConnection: keep-alive\nUpgrade-Insecure-Requests: 1'

'POST /echo HTTP/1.1\nHost: www.example.com\nUser-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)\nContent-Type: application/x-www-form-urlencoded\nContent-Length: 13\nConnection: keep-alive\nname=test&age=30'

'HEAD /path HTTP/1.1\nHost: www.example.com\nUser-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)\nConnection: keep-alive'

'OPTIONS /echo HTTP/1.1\nHost: www.example.com\nUser-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)\nConnection: keep-alive'
)

for ((i=1; i<=COUNT; i++)); do
    RANDOM_REQUEST="${requests[$RANDOM % ${#requests[@]}]}"

    printf "$RANDOM_REQUEST" | socat - TCP:127.0.0.1:5678
    printf "\n"
done

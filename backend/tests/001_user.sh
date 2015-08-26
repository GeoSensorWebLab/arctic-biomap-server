#!/bin/sh

HH="Content-Type: application/json"
URL="http://127.0.0.1:8080/biomap/users"

cat > /tmp/input.json << _EOF_
{
}
_EOF_
curl -s -H "$HH" -X GET --data @/tmp/input.json "$URL" | jq .



cat > /tmp/input.json << _EOF_
{
	"email": "*"
}
_EOF_
curl -s -H "$HH" -X GET --data @/tmp/input.json "$URL"  | jq .

cat > /tmp/input.json << _EOF_
{
	"email": "leepro@gmail.com"
}
_EOF_
curl -s -H "$HH" -X GET --data @/tmp/input.json "$URL" | jq .



cat > /tmp/input.json << _EOF_
{
	"email": "leepro@gmail.com",
	"passwd": "secret",
	"name": "DongWoo",
	"address": "Canada",
	"occupation": "worker",
	"year_hunting": 99
}
_EOF_

set USER_ID=$(curl -s -H "$HH" -X POST --data @/tmp/input.json "$URL" | jq ".user_id")
echo "Created USER_ID = $USER_ID"

curl -s -H "$HH" http://127.0.0.1:8080/biomap/users?email=* | jq .


cat > /tmp/input.json << _EOF_
{
	"user_id": "$USER_ID",
	"email": "xxx@gmail.com",
	"passwd": "secret",
	"name": "DongWoo",
	"address": "Canada",
	"occupation": "worker",
	"year_hunting": 99
}
_EOF_
curl -s -H "$HH" -X PUT --data @/tmp/input.json "$URL" | jq .


curl -s -H "$HH" http://127.0.0.1:8080/biomap/users?email=* | jq .


cat > /tmp/input.json << _EOF_
{
	"user_id": "$USER_ID"
}
_EOF_
# curl -s -H "$HH" -X DELETE --data @/tmp/input.json "$URL" | jq .


curl -s -H "$HH" http://127.0.0.1:8080/biomap/users?email=* | jq .


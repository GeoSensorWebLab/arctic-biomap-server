#!/bin/sh
set -e

HH="Content-Type: application/json"
URL="http://127.0.0.1:8081/biomap/users"

tmpfile=$(mktemp -t test)

function t {
	echo ""
	echo -e "\033[0;32mTEST: $@\033[0m"
}

# Begin Tests

t "Create User"
cat > $tmpfile << _EOF_
{
	"email": "leepro@gmail.com",
	"passwd": "secret",
	"name": "DongWoo",
	"address": "Canada",
	"occupation": "worker",
	"year_hunting": 99
}
_EOF_
echo $(curl -s -H "$HH" -X POST --data @$tmpfile "$URL")

t "Create User with Long Attributes and UTF-8 Characters"
cat > $tmpfile << _EOF_
{
	"email": "160aa3fdf19f79ddb9520ca533efd53d38041577546674499de3e53cdaaa61b04b64d31431948b17c83f33f3f8d5ffbd9ba94231e1cacf0bcd351c888fb6d9243385a6338d2f557b7b4ec2a04a17d858047b651ed62f382110dca71a359ef65ca81c6acd46adfced3d58db898acacb8585abdde5f13a7a5ab7@example.com",
	"passwd": "dd9f4794fde6675b55e049be17349e98fb6d7345f0cb22ee85f1549bc5d5d6f0b4579ed38a1737337b91760f840fedd24b9e161fe98ce5bc18f5164446c360bbbf5fcd1f60127a8948805e4a6a50487d63feb0b3381f45d349e97013f40eff71c15d4ec7a1554f2ac4a5132aa88fdce88d7f5e7aa35f595f45b3e65d15548d",
	"name": "В чащах юга жил-был цитрус? Да, но фальшивый экземпляр! ёъ.",
	"address": "ᐃᖃᓗᐃᑦ ᓄᓇᕗᑦ ᑲᓇᑕ",
	"occupation": "Full-time Hunter",
	"year_hunting": 0
}
_EOF_
echo $(curl -s -H "$HH" -X POST --data @$tmpfile "$URL")


URL="http://127.0.0.1:8081/biomap/login"

t "Login User, Bad Password"
cat > $tmpfile << _EOF_
{
	"email": "leepro@gmail.com",
	"passwd": "nosecret"
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")


t "Login Unknown User"
cat > $tmpfile << _EOF_
{
	"email": "ssss@gmail.com",
	"passwd": "nosecret"
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")


t "Login Known User"
cat > $tmpfile << _EOF_
{
	"email": "leepro@gmail.com",
	"passwd": "secret"
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")

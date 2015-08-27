#!/bin/sh
set -e

HH="Content-Type: application/json"
BASE="http://127.0.0.1:8081/biomap"
ENDPOINT="/sightings"
URL="${BASE}${ENDPOINT}"

tmpfile=$(mktemp -t test)

function t {
	echo ""
	echo -e "\033[0;32mTEST: $@\033[0m"
}

# Create User for Tests
cat > $tmpfile << _EOF_
{
	"email": "$RANDOM@example.com",
	"passwd": "secret",
	"name": "DongWoo",
	"address": "Canada",
	"occupation": "worker",
	"year_hunting": 99
}
_EOF_

output=$(curl -s -H "$HH" -X POST --data @$tmpfile "$BASE/users")
echo $output > $tmpfile
USER_ID=$(jq .user_id $tmpfile)

# Begin Tests

t "Get All Sightings (Should Fail with Invalid Parameters)"
cat > $tmpfile << _EOF_
{
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")

t "Get All Sightings (Should Be Empty)"
cat > $tmpfile << _EOF_
{
	"user_id": "*",
	"sighting_id": "*"
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")

t "Get All Sightings for a User (Should Be Empty)"
cat > $tmpfile << _EOF_
{
	"user_id": $USER_ID,
	"sighting_id": "*"
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")

t "Create Sighting"
cat > $tmpfile << _EOF_
{
	"user_id": $USER_ID,
	"animal_name": "caribou",
	"no_of_adults": 2,
	"no_of_calves": 1,
	"unusual_observations": "N/A",
	"lat": 100.0,
	"lon": 200.0,
	"visible_signs": ["A", "B", "C"],
	"photos": null
}
_EOF_
output=$(curl -s -H "$HH" -X POST --data @$tmpfile "$URL")
echo $output | tee $tmpfile
SIGHTING_ID=$(jq .sighting_id $tmpfile)
echo "Created SIGHTING_ID = $SIGHTING_ID"

t "Get Sighting by User ID and Sighting ID (single)"
cat > $tmpfile << _EOF_
{
	"user_id": $USER_ID,
	"sighting_id": $SIGHTING_ID
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")

t "Update Sighting"
cat > $tmpfile << _EOF_
{
	"sighting_id": $SIGHTING_ID,
	"user_id": $USER_ID,
	"animal_name": "caribou",
	"no_of_adults": 1,
	"no_of_calves": 1,
	"unusual_observations": "N/A",
	"lat": 10.0,
	"lon": 20.0,
	"vsigns": ["A", "B", "C", "D"]
}
_EOF_
echo $(curl -s -H "$HH" -X PUT --data @$tmpfile "$URL")

t "Get Updated Sighting"
cat > $tmpfile << _EOF_
{
	"user_id": $USER_ID,
	"sighting_id": "$SIGHTING_ID"
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")

t "Delete Sighting"
cat > $tmpfile << _EOF_
{
	"sighting_id": "$SIGHTING_ID"
}
_EOF_
echo $(curl -s -H "$HH" -X DELETE --data @$tmpfile "$URL")

t "Get Deleted Sighting"
cat > $tmpfile << _EOF_
{
	"user_id": "$USER_ID",
	"sighting_id": "$SIGHTING_ID"
}
_EOF_
echo $(curl -s -H "$HH" -X GET --data @$tmpfile "$URL")

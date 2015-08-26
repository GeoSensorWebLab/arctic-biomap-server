#!/bin/sh

HH="Content-Type: application/json"
URL="http://127.0.0.1:8080/biomap/images"
USER_ID="$1"
SIGHTING_ID="$2"

cat > /tmp/input.json << _EOF_
{
}
_EOF_
curl -s -H "$HH" -X GET --data @/tmp/input.json "$URL" | jq .



cat > /tmp/input.json << _EOF_
{
	"sighting_id": "$SIGHTING_ID",
	"image_id": "*"
}
_EOF_
curl -s -H "$HH" -X GET --data @/tmp/input.json "$URL"  | jq .



cat > /tmp/input.json << _EOF_
{
	"user_id": "$USER_ID",
	"sighting_id": "$SIGHTING_ID"
}
_EOF_

#IMAGE_ID=$(curl -s -H "$HH" -X POST --data @/tmp/input.json -F "image_file=@./image.png" "$URL")
#echo "Created IMAGE_ID = $IMAGE_ID"


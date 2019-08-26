#! /bin/bash

DIR=$(dirname "$BASH_SOURCE")/..

"$DIR/dbassistant" add "$DIR/tempFile_DBAssistantFromReaper.json"

exit 0
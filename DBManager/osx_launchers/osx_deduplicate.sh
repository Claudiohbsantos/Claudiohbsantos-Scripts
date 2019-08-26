#! /bin/bash

DIR=$(dirname "$BASH_SOURCE")/..

"$DIR/dbassistant" deduplicate "$DIR/tempFile_DBAssistantFromReaper.json"

exit 0
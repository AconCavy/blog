#!/bin/sh

SCRIPT_PATH=$(cd $(dirname $0); pwd)
ROOT_PATH=$(dirname $SCRIPT_PATH)

dotnet run --project $ROOT_PATH/src/Blog -- preview

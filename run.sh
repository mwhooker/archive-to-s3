!#/bin/bash
set -e
cd $HOME

if [ ! -n "$WERCKER_S3ARCHIVE_SOURCE" ]; then
    fail 'Please the source file to upload.'
    exit 1
fi

if [ ! -n "$WERCKER_S3ARCHIVE_KEY_ID" ]
then
    fail 'missing or empty option key_id, please check wercker.yml'
fi

if [ ! -n "$WERCKER_S3ARCHIVE_KEY_SECRET" ]
then
    fail 'missing or empty option key_secret, please check wercker.yml'
fi

if [ ! -n "$WERCKER_S3ARCHIVE_BUCKET_URL" ]
then
    fail 'missing or empty option bucket_url, please check wercker.yml'
fi

if [ ! -n "$WERCKER_S3ARCHIVE_OPTS" ]
then
    export WERCKER_S3ARCHIVE_OPTS="--acl-public"
fi

if ! type s3cmd &> /dev/null ;
then
    info 's3cmd not found, start installing it'
    wget -O- -q http://s3tools.org/repo/deb-all/stable/s3tools.key | sudo apt-key add -
    sudo wget -O/etc/apt/sources.list.d/s3tools.list http://s3tools.org/repo/deb-all/stable/s3tools.list
    sudo apt-get update && sudo apt-get install s3cmd
    success 's3cmd installed succesfully'
else
    info 'skip s3cmd install, command already available'
    debug "type s3cmd: $(type s3cmd)"
fi

if [ -e '.s3cfg' ]
then
    warn '.s3cfg file already exists in home directory and will be overwritten'
fi

echo '[default]' > '.s3cfg'
echo "access_key=$WERCKER_S3ARCHIVE_KEY_ID" >> .s3cfg
echo "secret_key=$WERCKER_S3ARCHIVE_KEY_SECRET" >> .s3cfg
debug "generated .s3cfg for key $WERCKER_S3ARCHIVE_KEY_ID"


source="$WERCKER_ROOT/$WERCKER_S3ARCHIVE_SOURCE"
if [ ! -f "$source" ]; then
    fail 'Source must be a file.'
    exit 1
fi
project_dest="$WERCKER_S3ARCHIVE_BUCKET_URL/$WERCKER_GIT_REPOSITORY/$WERCKER_GIT_BRANCH/"
archive="$source $project_dest/$WERCKER_GIT_REPOSITORY.$WERCKER_GIT_COMMIT.tgz"
temp_head=$(mktemp)
echo $WERCKER_GIT_COMMIT.tgz > $temp_head
archive_head="$temp_head $project_dest/HEAD"

info 'starting s3 upload'
#TODO assert that source is tarball or tar it up otherwise

set +e

for dest in $archive $archive_head; do
    PUT="s3cmd put $WERCKER_S3ARCHIVE_OPTS $WERCKER_S3ARCHIVE_DELETE_REMOVED --verbose $dest"
    debug "$SYNC"
    sync_output=$($SYNC)

    if [[ $? -ne 0 ]];then
        warn $sync_output
        fail 's3cmd failed';
    else
        echo "upload succeeded"
    fi
done
success 'finished s3 upload';
set -e

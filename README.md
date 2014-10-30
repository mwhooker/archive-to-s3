# Archive to S3

Uploads a project to S3 with the following key structure:


bucket:
    s3://wercker-{environment}/

A file whose content is the "short-rev" of a git commit
    /{project}/{branch}/HEAD

The project file for a given commit on a given branch.
Branch is redundant with commit, but we lay it out like this to make it easier
on us humans.
    /{project}/{branch}/{project}.{short-rev}.tgz


## Parameters

* `key-id` (required) The Amazon Access key that will be used for authorization.
* `key-secret` (required) The Amazon Access secret that will be used for authorization.
* `bucket-url` (required) The url of the bucket to sync to, like: `s3://wercker.com`
* `source` (required) The file from the build step to archive.
* `opts` (optional, default: `--acl-public`) Arbitrary options provided to s3cmd. See `s3cmd --help` for more.

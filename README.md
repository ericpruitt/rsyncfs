rsyncfs
=======

A FUSE filesystem that lets you mount rsync servers. This project was forked
from [zaddach/fuse-rsync](https://github.com/zaddach/fuse-rsync) and has been
overhauled to address a number of issues and make it less painful to use. Most
notably, I/O performance has been improved by making downloads asynchronous and
adding extensive caching:

- Concurrent operations on the same file only result in one request to the
  server.
- Copying files from the remote server is done in the background, so doing
  something like `head -n10 /mnt/rsync-server/some-large-file.txt` does not
  require the entire file to be downloaded before data can be read.
- An entire host can be mounted; module names are optional and, when omitted,
  running `ls ...` on the mountpoint will show the available modules as
  directories.
- Symbolic links are supported.
- User, group and other-user permissions are now preserved.
- File names that have escaped characters are now handled correctly.
- Commas in file sizes are now supported.
- Timestamps should now always round-trip correctly.
- The rsync server is now specified as a URL although the "rsync://" prefix can
  be omitted.

Usage
-----

**Synopsis:** `rsyncfs [OPTION]... RSYNC_SERVER MOUNTPOINT`

### Options ###

- **-h, --help:** Show the documentation and exit.
- **-o opt,[opt...]:** Mount options.
- **-t TTL_SEC:** Number of seconds file metadata is cached in memory.
- **-c COUNT:** Maximum number of file metadata entries cached in memory.
- **-p FILE:** Path of the file containing the rsync server password.
- **-e COMMAND:** Path or name of the rsync executable.
- **-v:** Increase logging verbosity.
- **-q:** Decrease logging verbosity.

In addition to these options, the FUSE library also accepts a number of its own
values. Refer to the output of "--help" for the full option list.

### Examples ###

Mount an unauthenticated rsync server:

    rsyncfs rsync://gutenberg.pglaf.org/ /mnt/project-gutenberg

Mount a server that requires a password:

    RSYNC_PASSWORD=hunter2 rsyncfs ericpruitt@storage45.local/backups/ ~/mounts/backups
    rsyncfs -p ~/secrets/nas-password ericpruitt@storage45.local/backups/ ~/mounts/backups

The password can also be specified in the URL, but this is not recommended
since specifying passwords on the command line may make them visible to other
users and/or processes on the same system:

    rsyncfs ericpruitt:hunter2@nas.local/backups/ ~/mounts/backups

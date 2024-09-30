#!/bin/bash

# by: justin

# NOTE needs to be run with sudo due to mount
# anacrontab entry:
# @daily 10  justinhs.backup /mnt/Files/Programs/LIN/rsync-backup.sh

# references:
# https://www.cyberciti.biz/faq/bash-get-exit-code-of-command/
# https://docs.fedoraproject.org/en-US/fedora/latest/system-administrators-guide/monitoring-and-automation/Automating_System_Tasks/#s2-configuring-anacron-jobs
# https://linuxconfig.org/how-to-create-incremental-backups-using-rsync-on-linux
# https://linuxconfig.org/rsync-exclude-directory
# https://phoenixnap.com/kb/remove-directory-linux
# https://download.samba.org/pub/rsync/rsync.1
# https://rsync.samba.org/examples.html
# https://stackabuse.com/how-to-save-command-output-as-variable-in-bash/
# https://unix.stackexchange.com/questions/136976/get-the-latest-directory-not-the-latest-file
# https://stackoverflow.com/questions/14491020/how-to-sort-the-results-of-find-including-nested-directories-alphabetically-in
# https://stackoverflow.com/questions/12457457/count-number-of-lines-in-terminal-output
# https://stackoverflow.com/questions/18668556/how-can-i-compare-numbers-in-bash#18668580
# https://www.shellcheck.net/
# https://www.shellcheck.net/wiki/SC2012
# https://www.shellcheck.net/wiki/SC2155
# https://www.shellcheck.net/wiki/SC2181

# how can the rsync documentation have so many words while explaining so little?
# it really pisses me off...

# █░█ █▀ █▀▀ █▀█   █▀▀ █▀█ █▄░█ █▀▀ █ █▀▀
# █▄█ ▄█ ██▄ █▀▄   █▄▄ █▄█ █░▀█ █▀░ █ █▄█

# directory to backup
SRCDIR=""

# directory to back up to
DESTDIR=""

# device to backup to and where to mount it
BDEV=""
BDIR=""

# excludes file, should just be a plaintext list of dirs and files to not save
# lives in the same dir as the script
EXCLUDES=""

# number of backups to keep
BACKUPS="28"

################################################################################

# param = exit code
echo_usage() {

    echo -e "Usage: $(basename \$0) [options] <srcdir> <destdir>

    Options:
      -d \t the drive to mount before performing the backup
      -p \t the directory to mount the drive at. has no effect if -d is not set
      -e \t the path to the excludes file. this should be a plaintext list of dirs and files that won't be backed up
      -k \t the number of backups to keep, use 0 to keep all (default: 28)
      -h \t prints this message

    Arguments:
      srcdir \t the directory to backup
      destdir \t the directory where all backups should be kept"

    exit "$1"

}

# no args, returns 1 if mount failed
mount_drive() {

    if [[ -n "$BDEV" ]]; then

        # Make sure the mount point exists
        if ! mkdir -p "$BDIR"; then
            echo "ERROR: Unable to create drive mount point"
            return 1
        fi

        # Mount the drive and print if there's a mount error
        # why tf isn't actually getting the exit code mentioned anywhere
        if ! mount "$BDEV" "$BDIR"; then
            echo "ERROR: Drive mount failed with error code $MOUNTED"
            return 1
        else
            return 0
        fi

    fi

    # if we don't have to mount anything, return 0 to pass
    return 0

}

clean_old() {

    if [[ "$BACKUPS" -gt 0 ]]; then

        # Delete old backups
        while [ "$(find "$DESTDIR"/* -maxdepth 0 -type d | wc -l)" -gt "${BACKUPS}" ] ; do
            # -r = recursive, deletes all children
            rm -r "$(find "$DESTDIR"/* -maxdepth 0 -type d | sort -d -f | head -n 1)"
        done

    fi

}

do_backup() {

    if mount_drive; then

        # time (quoted to bypass SC2155)
        readonly "TIMESTAMP=$(date +'%Y-%m-%d_%H.%M.%S')"

        # where this backup will end up
        readonly DESTPATH="$DESTDIR/$TIMESTAMP"

        # where the last backup was. hard links unmodified files to this one
        # this was giving me such a hard time because i used to be searching for the last backup BEFORE MOUNTING THE FUCKING DRIVE
        readonly "DESTFULL=$(find "$DESTDIR"/* -maxdepth 0 -type d | sort -d -f | tail -n 1)"

        # Make sure the backup directory exists
        if ! mkdir -p "$DESTDIR"; then
            echo "ERROR: Unable to create backup target directory!"
            return 1
        fi

        # -v = verbose
        # -i = itemize changes
        # -n = Dry Run
        # -a = archive mode, preserves most important file attributes
        # --delete = remove files from backup that were deleted
        # --delete-excluded = delete excluded files previously included in the backup
        # --exclude-from = don't backup the steam games
        # --link-dest = if a file doesn't need to be updated, link to the full backup
        rsync -via --delete --delete-excluded --exclude-from="$EXCLUDES" --link-dest "$DESTFULL" "$SRCDIR/" "$DESTPATH"

        EXIT_RSYNC="$?"

        clean_old

        # Unmount the drive, if mounted
        if [[ -n "$BDEV" ]]; then
            # -l = lazy
            umount -l "$BDEV"
        fi

        exit "$EXIT_RSYNC"

    fi

    # if the mount fails and we can't perform the backup, return failed error code
    exit 1

}

# Determine argument flags
# https://linuxconfig.org/bash-script-flags-usage-with-arguments-examples
while getopts "dpekh?:-:" OPTION; do
    case "$OPTION" in
        d) BDEV="$OPTARG" ;;
        p) BDIR="$OPTARG" ;;
        e) EXCLUDES="$OPTARG" ;;
        k) BACKUPS="$OPTARG" ;;
        h) echo_usage 0 ;;
        ?) echo_usage 1 ;;
    esac
done
shift "$((OPTIND -1))"

if [ "$#" -gt 1 ]; then
    SRCDIR="$1"
    DESTDIR="$2"
else
    echo_usage 1
fi

do_backup

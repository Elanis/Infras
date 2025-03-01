#!/bin/bash
#set -x #echo on

# Make the script stop if any error happen:
set -e

function postgres-backup() {
        if [ "$1" != "" ]; then
                if [ -d "/opt/backups/postgres/$1" ]; then
                        simpleFileName="$( date '+%Y-%m-%d_%H-%M-%S' ).dump"
                        fileName="/opt/backups/postgres/$1/$simpleFileName"
                        echo "Backing-up $folder to $fileName"

                        if [ "$1" = "galactae" ]; then
                                /usr/local/bin/kubectl exec -n galactae galactae-main-database-1 -- pg_dump -U postgres -F c galactae-main > "/opt/backups/postgres/$1/galactae-main-$simpleFileName"
                                /usr/local/bin/kubectl exec -n galactae galactae-00-database-1 -- pg_dump -U postgres -F c galactae-00 > "/opt/backups/postgres/$1/galactae-00-$simpleFileName"
                                /usr/local/bin/kubectl exec -n galactae galactae-01-database-1 -- pg_dump -U postgres -F c galactae-01 > "/opt/backups/postgres/$1/galactae-01-$simpleFileName"
                        else
                                podName=$(/usr/local/bin/kubectl get pods -n "$1" | grep "^$1-database-" | awk '{print $1}')
                                echo "Found pod: $podName"
                                /usr/local/bin/kubectl exec -n "$1" "$podName" -- pg_dump -U postgres -F c $folder > "$fileName"
                        fi
                fi
        else
                echo "Full Postgres backup initiated ..."

                for i in "/opt/backups/postgres/"*; do
                        folder="$(basename $i)"
                        postgres-backup "$folder"
                done

                echo "Backup finished !"

                echo "Removing old backups ..."
                find "/opt/backups/postgres/" -type f -mtime +3 -exec rm {} \;

                echo "Attributing owners/groups ..."
                chown -R backup:backup /opt/backups/
                chmod -R 770 /opt/backups/
        fi
}

postgres-backup;

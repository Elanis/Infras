#!/bin/bash
#set -x #echo on

# Make the script stop if any error happen:
set -e

function postgres-backup() {
        podName="$(/usr/local/bin/kubectl get pods -n dysnomia-apps | grep '^postgres-' | awk '{print $1}')"

        if [ "$1" != "" ]; then
                if [ -d "/opt/backups/postgres/$1" ]; then
                        simpleFileName="$( date '+%Y-%m-%d_%H-%M-%S' ).dump"
                        fileName="/opt/backups/postgres/$1/$simpleFileName"
                        echo "Backing-up $folder to $fileName"

                        /usr/local/bin/kubectl exec -n dysnomia-apps "$podName" -- pg_dump -U postgres -F c $folder > "$fileName"
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

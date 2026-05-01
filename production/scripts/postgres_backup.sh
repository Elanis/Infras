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
                                podName=$(/usr/local/bin/kubectl get pods -n galactae | grep "^galactae-main-database-" | head -n 1 | awk '{print $1}')
                                /usr/local/bin/kubectl exec -n galactae "$podName" -- pg_dump -U postgres -F c galactae-main > "/opt/backups/postgres/$1/galactae-main-$simpleFileName"

                                podName=$(/usr/local/bin/kubectl get pods -n galactae | grep "^galactae-00-database-" | head -n 1 | awk '{print $1}')
                                /usr/local/bin/kubectl exec -n galactae "$podName" -- pg_dump -U postgres -F c galactae-00 > "/opt/backups/postgres/$1/galactae-00-$simpleFileName"
                                
                                podName=$(/usr/local/bin/kubectl get pods -n galactae | grep "^galactae-01-database-" | head -n 1 | awk '{print $1}')
                                /usr/local/bin/kubectl exec -n galactae "$podName" -- pg_dump -U postgres -F c galactae-01 > "/opt/backups/postgres/$1/galactae-01-$simpleFileName"
                        elif [ "$1" = "authentik" ]; then
                                podName=$(/usr/local/bin/kubectl get pods -n "authentik-app" | grep "database" | head -n 1 | awk '{print $1}')
                                echo "Found pod: $podName"
                                /usr/local/bin/kubectl exec -n "authentik-app" "$podName" -- pg_dump -U postgres -F c $folder > "$fileName"
                        else 
                                podName=$(/usr/local/bin/kubectl get pods -n "$1" | grep "database" | head -n 1 | awk '{print $1}') 
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

#!/bin/bash
# Uncomment set command below for code debuging bash
# set -x

# BIG-IQ must be configured for basic auth, in the console run `set-basic-auth on`
bigiq="10.1.1.4"
bigiq_user="root"
bigiq_password="purple123"

echo -e "\nWaiting 5min to give time to the BIG-IQ CM to start up."
sleep 300

sshpass -p $bigiq_password ssh-copy-id -o StrictHostKeyChecking=no $bigiq_user@$bigiq
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 $bigiq_user@$bigiq cat /var/prompt/ps1 > /tmp/state 2>/dev/null
state=$(cat /tmp/state)

while [[ $state = "Active" ]]
do
    echo -e "\nTIME:: $(date +"%H:%M")"
    sshpass -p $bigiq_password ssh-copy-id -o StrictHostKeyChecking=no $bigiq_user@$bigiq
    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 $bigiq_user@$bigiq cat /var/prompt/ps1 > /tmp/state 2>/dev/null
    state=$(cat /tmp/state)
    if [[ -z $state ]]; then
        state="n/a"
    fi
    if [[ $state == "Active" ]]; then
        echo -e "\n\nBIG-IQ Application is $state on $bigiq ... sleep for 1 min 30 sec ..."
        secs=90
        while [ $secs -gt 0 ]; do
            echo -ne "$secs\033[0K\r"
            sleep 1
            : $((secs--))
        done
        ssh $bigiq_user@$bigiq bigstart restart restjavad
        echo -e "\nbigstart restart restjavad completed."
        exit 0;
    else
        echo -e "\n\nBIG-IQ Application is $state on $bigiq"
    fi
    sleep 15
done

echo -e "\nTIME:: $(date +"%H:%M")"
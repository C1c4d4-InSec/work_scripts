#!/bin/bash

dqutil_out="dqutil_out_$(date "+%Y%m%d-%H%M%S")"
owlhome=$(grep "BASE_PATH" $(find / -iname "owl-env.sh" 2>/dev/null) | cut -d "\"" -f2)

dq_restart() {

    echo "" | tee -a $dqutil_out
    echo " Restarting DQ" | tee -a $dqutil_out
    echo "------------------------------------------------------------------" | tee -a $dqutil_out
    echo "| Restarting core services. This will take a moment." | tee -a $dqutil_out
    $owlhome/owl/bin/owlmanage.sh restart >> $dqutil_out 2>&1
    echo "|> Done." | tee -a $dqutil_out
    echo "| Starting Agent" | tee -a $dqutil_out
    $owlhome/owl/bin/owlmanage.sh start=owlagent >> $dqutil_out 2>&1
    echo "|> Done." | tee -a $dqutil_out
    echo "------------------------------------------------------------------" | tee -a $dqutil_out

}

dq_persistence() {

    echo "" | tee -a $dqutil_out
    echo "  DQ Persistence" | tee -a $dqutil_out
    echo "------------------------------------------------------------------" | tee -a $dqutil_out

    # Check to see if there is already a persistence cron job in crontab. Add the job if not.
    if [ -z "$(sudo crontab -l 2>/dev/null | grep "@reboot sh $owlhome/startup.sh")" ]; then
        echo "| Adding cron job for startup script."  | tee -a $dqutil_out
        sudo su<<EOM
            echo "@reboot sh $owlhome/startup.sh") | crontab -
EOM
        echo "|> Done"  | tee -a $dqutil_out
    else
        echo "| Cron job already exists."  | tee -a $dqutil_out
    fi

    # Create the startup script that cron will execute.
    echo "| Creating/Updating $owlhome/startup.sh"  | tee -a $dqutil_out
    echo "#!/bin/bash" > $owlhome/startup.sh
    echo "sudo $owlhome/owl/bin/owlmanage.sh start" >> $owlhome/startup.sh
    echo "sudo $owlhome/owl/bin/owlmanage.sh start=owlagent" >> $owlhome/startup.sh
    echo "sudo $owlhome/owl/spark/sbin/start-master.sh" >> $owlhome/startup.sh
    echo "sudo $owlhome/owl/spark/sbin/start-slave.sh spark://$HOSTNAME:7077" >> $owlhome/startup.sh

    echo "| Removing write permissions for startup.sh" | tee -a $dqutil_out
    chmod +x-w startup.sh

    echo "------------------------------------------------------------------" | tee -a $dqutil_out

}

dq_tls() {

    # Documentation used to set up certificate and keystore:
    # - Create self-signed certificate
    #   https://www.sslshopper.com/article-how-to-create-a-self-signed-certificate-using-java-keytool.html
    # - Set up a keystore
    #   https://www.sslshopper.com/article-most-common-java-keytool-keystore-commands.html
    # - TLS enable on DQ server
    #   https://dq-docs.collibra.com/security/configuration/ssl-setup-https

    # Find the old hash value. Doesn't matter if there wasn't a keystore set up prior, there is a value in 
    #   owl-env.sh. Need to find it for SED to work and replace with new value.
    oldKeystoreHash=$(cat $owlhome/owl/config/owl-env.sh | grep "#export SERVER_SSL_KEY_PASS" | cut -d '=' -f2-)
    newKeystorePass=""
    

    echo "" | tee -a $dqutil_out
    echo "  Enable HTTPS" | tee -a $dqutil_out
    echo "------------------------------------------------------------------" | tee -a $dqutil_out

    # Ask for initial and repeat of the new password and then compare to ensure password is input 
    #   correctly. If they match, that is the new password. -s argument does not echo the password
    #   in the terminal.
    while true;
    do
        echo "| Enter new keystore password: " | tee -a $dqutil_out
        read -s kspass1
        echo "| Re-enter new keystore password:"  | tee -a $dqutil_out
        read -s kspass2

        if [ $kspass1 == $kspass2 ]; then
            newKeystorePass="$kspass1"
            echo "|> Password accepted."  | tee -a $dqutil_out
            break
        else
            echo "|x Passwords don't match. Please retry." | tee -a $dqutil_out
        fi
    done

    # Create the new password hash per the DQ documentation.
    newKeystoreHash=$($owlhome/owl/bin/owlmanage.sh encrypt=$newKeystorePass)
    cd $owlhome
    echo "| Removing old DQ keystore (if applicable)" | tee -a $dqutil_out
    rm -f dqkeystore.jks
    echo "|> Done" | tee -a $dqutil_out
    echo "| Creating new DQ keystore." | tee -a $dqutil_out
    # Create the new keystore.
    echo | sudo keytool -genkey -keyalg RSA -alias selfsigned -dname "CN=DQ,OU=SE,O=Collibra,L=NY,S=NY,C=US" -keystore dqkeystore.jks -storepass $newKeystorePass -validity 360 -keysize 2048 >> $dqutil_out 2>&1
    echo "|> Done" | tee -a $dqutil_out

    echo "| Backing up original owl-env.sh file to owl-env.bak" | tee -a $dqutil_out
    cp $owlhome/owl/config/owl-env.sh $owlhome/owl/config/owl-env.bak

    echo "| Making required changes to owl-env.sh" | tee -a $dqutil_out
    sed -i 's|#export SERVER_HTTP_ENABLED=false|export SERVER_HTTP_ENABLED=false|' $owlhome/owl/config/owl-env.sh
    sed -i 's|#export SERVER_HTTPS_ENABLED=true|export SERVER_HTTPS_ENABLED=true|' $owlhome/owl/config/owl-env.sh
    sed -i 's|#export SERVER_SSL_KEY_TYPE=PKCS12|export SERVER_SSL_KEY_TYPE=JKS|' $owlhome/owl/config/owl-env.sh
    sed -i 's|#export SERVER_SSL_KEY_STORE='$owlhome'/owl/keystoredsktp.p12|export SERVER_SSL_KEY_STORE='$owlhome'/dqkeystore.jks|' $owlhome/owl/config/owl-env.sh
    sed -i 's|#export SERVER_SSL_KEY_PASS='$oldKeystoreHash'|export SERVER_SSL_KEY_PASS='$newKeystoreHash'|' $owlhome/owl/config/owl-env.sh
    sed -i 's|export SERVER_SSL_KEY_PASS='$oldKeystoreHash'|export SERVER_SSL_KEY_PASS='$newKeystoreHash'|' $owlhome/owl/config/owl-env.sh
    sed -i 's|#export SERVER_SSL_KEY_ALIAS=owl|export SERVER_SSL_KEY_ALIAS=selfsigned|' $owlhome/owl/config/owl-env.sh

    sslEqualsTrueString=$(cat $owlhome/owl/config/owl-env.sh | grep "export SERVER_REQUIRE_SSL=true")
    if [[ -z "$sslEqualsTrueString" ]]; then
        echo "export SERVER_REQUIRE_SSL=true" >> $owlhome/owl/config/owl-env.sh
    fi

    echo "| Getting public IP address. Canceling if no response in 5 seconds." | tee -a $dqutil_out
    pubIPAddress=$(curl -s -m 5 ifconfig.co)
    echo "| Please access your DQ instance at:" | tee -a $dqutil_out
    echo "|     https://$pubIPAddress:9000" | tee -a $dqutil_out
    echo "------------------------------------------------------------------" | tee -a $dqutil_out

}

dq_postgresPassChange(){

    # Change the Postgres password. Does not have to be default pass for it to work.

    # Get the current hash from owl-env.sh for SED to work.
    oldPostgresHash=$(cat $owlhome/owl/config/owl-env.sh | grep "export SPRING_DATASOURCE_PASSWORD" | cut -d "=" -f2-)
    # Establish variable for new password outside of while statement.
    newPostgresPass=""

    echo "" | tee -a $dqutil_out
    echo "  Postgres Default Password Change" | tee -a $dqutil_out
    echo "------------------------------------------------------------------" | tee -a $dqutil_out

    # Ask for initial and repeat of the new password and then compare to ensure password is input 
    #   correctly. If they match, that is the new password. -s argument does not echo the password
    #   in the terminal.
    while true;
    do
        echo "| Enter new password: " | tee -a $dqutil_out
        read -s pgpass1
        echo "| Re-enter new password:"  | tee -a $dqutil_out
        read -s pgpass2

        if [ $pgpass1 == $pgpass2 ]; then
            newPostgresPass="$pgpass1"
            echo "|> Password accepted."  | tee -a $dqutil_out
            break
        else
            echo "|x Passwords don't match. Please retry." | tee -a $dqutil_out
        fi
    done

    # Command one-liner to change PSQL password with minimal interactivity and steps..
    echo "| Changing postgres password." | tee -a $dqutil_out
    sudo -u postgres psql -c "ALTER USER postgres PASSWORD '$newPostgresPass';" >> $dqutil_out 2>&1
    echo "|> Done" | tee -a $dqutil_out

    # Hash the new password per the DQ documentation. Change all occurrences for DQ with SED.
    #   Occurrence locations: owl-env.sh, owl.properties
    echo "| Hashing new postgres password" | tee -a $dqutil_out
    echo "| Updating owl-env.sh and owl.properties files." | tee -a $dqutil_out
    newPostgresHash=$($owlhome/owl/bin/owlmanage.sh encrypt=$newPostgresPass) 
    sed -i 's|export SPRING_DATASOURCE_PASSWORD='$oldPostgresHash'|export SPRING_DATASOURCE_PASSWORD='$newPostgresHash'|' $owlhome/owl/config/owl-env.sh
    sed -i 's|spring.datasource.password='$oldPostgresHash'|spring.datasource.password='$newPostgresHash'|' $owlhome/owl/config/owl.properties
    sed -i 's|spring.agent.datasource.password='$oldPostgresHash'|spring.agent.datasource.password='$newPostgresHash'|' $owlhome/owl/config/owl.properties
    echo "|> Done" | tee -a $dqutil_out

    # Echo Restart the postgres server for changes to take effect.
    echo "| Restarting postgres server."  | tee -a $dqutil_out
    $owlhome/owl/bin/owlmanage.sh restart=postgres >> $dqutil_out 2>&1
    echo "|> Done" | tee -a $dqutil_out

    echo "------------------------------------------------------------------" | tee -a $dqutil_out

}

dq_troubleshoot(){

    postgres=$(if [[ $(ps -aef | grep postgres | wc -l) > 1 ]]; then echo "Up, PID=$(ps -aef | grep postgres | awk '{print $2}' | head -n1)"; else echo "Down"; fi;)
    web=$(if [[ $(ps -aef | grep owl-web | wc -l) > 1 ]]; then echo "Up, PID=$(ps -aef | grep owl-web | awk '{print $2}' | head -n1)"; else echo "Down"; fi;)
    agent=$(if [[ $(ps -aef | grep owl-agent | wc -l) > 1 ]]; then echo "Up, PID=$(ps -aef | grep owl-agent | awk '{print $2}' | head -n1)"; else echo "Down"; fi;)
    spark=$(if [[ $(ps -aef | grep spark | wc -l) > 1 ]]; then echo "Up, PID=$(ps -aef | grep spark | awk '{print $2}' | head -n1)"; else echo "Down"; fi;)

    echo " Service  |  Status, PID" | tee -a $dqutil_out
    echo "------------------------------------------------------------------" | tee -a $dqutil_out
    echo "Postgres  | $postgres" | tee -a $dqutil_out
    echo "Owl-Web   | $web" | tee -a $dqutil_out
    echo "Agent     | $agent" | tee -a $dqutil_out
    echo "Spark     | $spark" | tee -a $dqutil_out
    echo "------------------------------------------------------------------" | tee -a $dqutil_out
}

getHelp() {
    echo ""
    echo " Usage: sudo ./dqutils <args>"
    echo "------------------------------------------------------------------"
    echo "| (no arguments)  | This help message."
    echo "| -a, --all       | Add persistence, change psql password, enable TLS."
    echo "| -t, --tls       | Enable TLS for encryption. (HTTPS)"
    echo "| -p, --post      | Change the postgres password."
    echo "| -c, --cron      | DQ Persistence; start DQ automatically after reboot."
    echo "| -r, --restart   | Restart DQ."
    echo "| --troubleshoot  | Run common troubleshooting; logs to text file for analysis."
    echo "------------------------------------------------------------------"
    echo ""
}

doAll(){
    dq_persistence
    dq_tls
    dq_postgresPassChange
    dq_restart
}

doTLSOnly(){
    dq_tls
    dq_restart
}

doPostgresOnly(){
    dq_postgresPassChange
    dq_restart
}

restartDQ(){
    dq_restart
}

doPersistenceOnly(){
    dq_persistence
}

case "$1" in
    "-a"|"--all")
        doAll;;
    "-t"|"--tls")
        doTLSOnly;;
    "-p"|"--post")
        doPostgresOnly;;
    "-c"|"--cron")
        doPersistenceOnly;;
    "-r"|"--restart")
        restartDQ;;
    "--troubleshoot")
        dq_troubleshoot;;
    #"test")
    #    testing;;
    *)
        getHelp;;
esac
#!/bin/bash

#make dir of this script the current directory
THIS="$( readlink -f "${BASH_SOURCE[0]}" )"
THISDIR="$(dirname "$THIS")"
cd $THISDIR

#source .env and export all vars in .env
set -a
source .env

if [ "$DOMAIN" == "" ] ; then
  echo ERROR: edit .env  and set DOMAIN
  exit 1
fi

EMAIL="admin@$DOMAIN"
echo using email: $EMAIL

#substitute $DOMAIN and $EMAIL
FILE=traefik/conf/traefik.toml
if [ -f $FILE ] ; then
  echo $FILE already exists - skipped
else
  cat $FILE.dist | envsubst > $FILE
  echo $FILE created
fi

FILE=traefik/vol/acme.json
if [ -f $FILE ] ; then
  echo $FILE already exists - skipped
else
  mkdir -p $(dirname $FILE)
  touch $FILE
  chmod 600 $FILE
  echo $FILE created
fi

#setup mailserver
docker-compose down
docker stop mail-setup
docker rm mail-setup
docker run \
    -p 25:25 \
    -p 80:80 \
    -p 143:143 \
    -p 443:443 \
    -p 465:465 \
    -p 587:587 \
    -p 993:993 \
    -v /etc/localtime:/etc/localtime:ro \
    -v $(pwd)/mail/vol/data:/data \
    -h mail.$DOMAIN \
    --name "mail-setup" \
    -d -t ziezo/poste.io

cat << EOF
============================================================================

Now follow these steps to setup the mailserver:

1) Open the mail server in your browser https://mail.$DOMAIN
   - Be patient, it might take a minute or so to get things started
   - Ignore certificate errors
   - If you get HTTP Strict Transport Security error, then try a different
     subdomain such as https://mail2.$DOMAIN or by IP address
                                                          
2) On the install page enter:
   - Mailserver hostname: mail.$DOMAIN
   - Email: $EMAIL 
   - Relay IPs: 172.16.0.0/12 (allows other containers to send mail)
   - click Submit

3) Now the mailserver admin page should open, go to 'System Setup', scroll
   down and click 'Issue free Letsencrypt certificate'

4) On the Letsencrypt page: check 'enabled' and click 'Save changes'

5) Wait a while and now https://mail.$DOMAIN should work with valid cert


   ... All done? Then press enter to start server ...

EOF
read
cat << EOF
============================================================================
   Starting server ...
============================================================================
EOF

#stop mail-setup
docker stop mail-setup
docker rm mail-setup

#start server
docker-compose up -d

#done
cat << EOF
============================================================================
Setup completed!
============================================================================
website:    https://www.$DOMAIN 
            https://$DOMAIN 
            http://www.$DOMAIN 
            http://$DOMAIN

phpmyadmin: https://pma.$DOMAIN
            username: root  password: $DBPW

nextcloud:  https://cloud.$DOMAIN 
            use 'mysql' not 'localhost' as database server

traefik:    https://traefik.$DOMAIN
            default username: test  password: test

webmail:    https://mail.$DOMAIN

============================================================================
EOF


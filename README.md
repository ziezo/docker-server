## docker-server

**Quick setup docker server**

- webserver: apache, php, letsencrypt  
- mailserver: imap, smtp, roundcube webmail  
- mysql  
- phpmysqladmin  
- nextclound  
- traefik  

Currently php5.6 and mysql5.7 are used in order to support older software...

### Prerequisites

- Setup DNS so that your server is reachable under yourdomain.com and *.yourdomain.com  
- Install docker and docker-compose  

### Setup

- edit `.env` and set your domainname  
- `./setup.sh` and follow the instructions

### Directories

`conf` configuration  
`vol`  data volumes  
`log`  log files  
`bin`  scripts  

### Scripts

`./setup.sh` Setup the server  
`bin/dup` Start server (`docker-compose up -d`)  
`bin/ddown` Stop server (`docker-compose down`)
`bin/dbash container` Start bash shell in container  
`bin/dlog container` Show log output of container  
`bin/dtop` Show status of running containers  
`bin/clean.sh` Deletes vol/, log/ and conf/traefik/traefik.toml, removes all docker containers and images   
`bin/try.sh` For testing: makes copy to ../try, removes all docker containers and images, and runs setup.sh from ../try  

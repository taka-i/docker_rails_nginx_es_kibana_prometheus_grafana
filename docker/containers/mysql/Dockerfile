FROM mysql:5.7

COPY my.cnf /etc/mysql/conf.d
COPY 01_grant_user.sql /docker-entrypoint-initdb.d
COPY 02_schema.sql /docker-entrypoint-initdb.d

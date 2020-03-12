FROM ubuntu:18.04

# instalacion y configuracion de las dependencias
RUN apt-get update && apt-get install -y openssl net-tools git sudo vim curl wget nginx
RUN apt-get update && apt-get install -y software-properties-common
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends php7.2-fpm php7.2-cli php7.2-gd php7.2-curl php7.2-mbstring php7.2-soap php7.2-xmlrpc php7.2-zip

# instalacion php sql server driver
RUN add-apt-repository ppa:ondrej/php -y
RUN apt-get update && apt-get install php7.2-dev php7.2-xml -y --allow-unauthenticated
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update && ACCEPT_EULA=Y apt-get install msodbcsql17 -y && apt-get install unixodbc-dev -y
RUN pecl install sqlsrv && pecl install pdo_sqlsrv 
RUN printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/7.2/mods-available/sqlsrv.ini 
RUN printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/7.2/mods-available/pdo_sqlsrv.ini 
RUN phpenmod -v 7.2 sqlsrv pdo_sqlsrv 
RUN apt-get remove --purge php7.2-dev software-properties-common -y

# configuracion del entorno
WORKDIR /var/www/html
VOLUME ["/var/www/html"]
COPY code-server /usr/bin/code-server
COPY default /etc/nginx/sites-available
COPY start_env /etc
RUN chmod +x /etc/start_env
EXPOSE 80
EXPOSE 8443

# ejecucion de comando de arranque
CMD ["/etc/start_env"]

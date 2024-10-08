FROM oraclelinux:9

# Install necessary packages
RUN yum install -y oracle-epel-release-el9 oracle-instantclient-release-23ai-el9 \
    && yum-config-manager --enable ol9_developer_EPEL \
    && yum install -y \
        php php-cli php-json php-mbstring php-curl \
        gcc gcc-c++ make cmake autoconf libaio \
        curl unzip \
        libcurl-devel \
        vim \
    && yum clean all

ENV LD_LIBRARY_PATH=/usr/lib/oracle/23/client64/lib
ENV ORACLE_HOME=/usr/lib/oracle/23/client64/lib
ENV PHP_DTRACE=yes
# Install PHP 8.3 (from Remi repository)
RUN yum -y install https://rpms.remirepo.net/enterprise/remi-release-9.rpm \
    && yum -y module enable php:remi-8.3 \
    && yum -y install php php-devel php-pear php-pdo php-xml php-mbstring php-bcmath php-oci8 php-curl
RUN dnf install -y oracle-instantclient-devel
# Install Swoole v5.1
#php --ri swoole
# RUN pecl install swoole-5.1.0
RUN echo 'export ORACLE_HOME=usr/lib/oracle/23/client64/lib' >> ~/.bashrc
RUN echo 'export LD_LIBRARY_PATH=usr/lib/oracle/23/client64/lib' >> ~/.bashrc
RUN source ~/.bashrc
RUN pecl channel-update pecl.php.net
#instantclient,/usr/lib/oracle/23/client64/lib
RUN yum install -y systemtap-sdt-devel
RUN dnf install -y brotli-devel
#echo 'instantclient,/opt/oracle/instantclient_12_2' | pecl install oci8-1.4.10
RUN echo --with-php-config=/usr/bin/php-config --enable-sockets=no --enable-openssl=yes --enable-mysqlnd=no --enable-swoole-curl=yes --enable-cares=no --enable-brotli=yes --enable-swoole-pgsql=no --with-swoole-odbc=no --with-swoole-oracle=instantclient,/usr/lib/oracle/23/client64/lib --enable-swoole-sqlite=no | pecl install swoole
COPY resources/swoole.ini /etc/php.d/swoole.ini
# RUN echo 'instantclient,/usr/lib/oracle/21/client64/lib' | pecl install oci8
# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set up application directory
WORKDIR /opt/applications

# Install Hyperf via Composer
# RUN composer create-project hyperf/hyperf-skeleton .

# Expose PHP-FPM and HTTP ports (PHP-FPM default is 9000)
EXPOSE 9501 443

# Set the entrypoint for the container
# CMD ["php", "/opt/applications/bin/hyperf.php", "start"]
#!/bin/bash -x
exec > /var/log/startup-script.log 2>&1

# Update system
apt update
apt upgrade -y

# Install dependencies
apt install -y gnupg2 ca-certificates lsb-release apt-transport-https software-properties-common curl unzip git

# Add PHP repository (Sury, latest PHP packages)
curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/sury.gpg
echo "deb https://packages.sury.org/php $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

apt update
apt upgrade -y

# Install PHP + extensions + Nginx + Composer
apt install -y nginx php8.3-cli php8.3-fpm php8.3-mbstring php8.3-mysql php8.3-xml php8.3-curl php8.3-sqlite3

# Configure Nginx for Laravel
cat > /etc/nginx/sites-available/laravel <<'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/laravel/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Install Composer globally
export HOME=/root
export COMPOSER_HOME=/root/.config/composer
export COMPOSER_ALLOW_SUPERUSER=1
mkdir -p /usr/src
curl -sS https://getcomposer.org/installer -o /usr/src/composer-setup.php
php /usr/src/composer-setup.php --install-dir=/usr/local/bin --filename=composer
chmod 755 /usr/local/bin/composer

# Verify Composer installation
/usr/local/bin/composer --version

# Deploy Laravel
mkdir -p /var/www
/usr/local/bin/composer create-project --prefer-dist --no-interaction laravel/laravel /var/www/laravel

# Set permissions
chown -R www-data:www-data /var/www/laravel
chmod -R 755 /var/www/laravel

# Restart services
systemctl enable nginx php8.3-fpm
systemctl restart nginx php8.3-fpm

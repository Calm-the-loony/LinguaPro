#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DOMAIN="${1:-d24.clv-digital.tech}"
EMAIL="${2:-admin@clv-digital.tech}"
DOCKER_PORT="${DOCKER_PORT:-8081}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Настройка домена $DOMAIN на хосте${NC}"
echo -e "${GREEN}========================================${NC}"

# 1. Создаём nginx конфиг для нашего домена на хосте
echo -e "\n${YELLOW}Создаём nginx конфиг для домена...${NC}"

sudo tee /etc/nginx/sites-available/$DOMAIN.conf > /dev/null << EOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    location / {
        proxy_pass http://127.0.0.1:$DOCKER_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

echo -e "${GREEN}Конфиг создан${NC}"

# 2. Создаём папку для certbot
sudo mkdir -p /var/www/certbot

# 3. Включаем сайт
echo -e "\n${YELLOW}Включаем сайт...${NC}"
sudo ln -sf /etc/nginx/sites-available/$DOMAIN.conf /etc/nginx/sites-enabled/
sudo nginx -t && echo -e "${GREEN}Конфиг валиден${NC}"

# 4. Временно используем HTTP-only конфиг для получения сертификата
echo -e "\n${YELLOW}Временно отключаем SSL блок для получения сертификата...${NC}"

sudo tee /etc/nginx/sites-available/$DOMAIN.conf > /dev/null << EOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN;

    # Временный self-signed сертификат для запуска nginx
    ssl_certificate /etc/nginx/self-signed.crt;
    ssl_certificate_key /etc/nginx/self-signed.key;

    location / {
        proxy_pass http://127.0.0.1:$DOCKER_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Создаём self-signed сертификат для временного использования
sudo openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout /etc/nginx/self-signed.key \
    -out /etc/nginx/self-signed.crt \
    -days 1 \
    -subj "/CN=$DOMAIN" 2>/dev/null

sudo nginx -t && sudo systemctl reload nginx
echo -e "${GREEN}Nginx перезагружен с временным сертификатом${NC}"

# 5. Получаем Let's Encrypt сертификат
echo -e "\n${YELLOW}Получаем Let's Encrypt сертификат...${NC}"

# Устанавливаем certbot если нет
if ! command -v certbot &> /dev/null; then
    sudo apt-get update -qq
    sudo apt-get install -y -qq certbot python3-certbot-nginx
fi

sudo certbot --nginx \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    -d $DOMAIN

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  SSL сертификат получен!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Сайт доступен по адресу: https://$DOMAIN"
echo "Админка: https://$DOMAIN/admin"
echo ""
echo "Для обновления сертификата:"
echo "  sudo certbot renew"

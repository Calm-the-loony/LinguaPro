#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DOMAIN="${1:-d24.clv-digital.tech}"
EMAIL="${CERTBOT_EMAIL:-admin@clv-digital.tech}"
ACTION="${2:-renew}"

if [ "$ACTION" = "init" ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Получение SSL сертификата для $DOMAIN${NC}"
    echo -e "${GREEN}========================================${NC}"

    # Создаем папки для сертификатов
    mkdir -p ssl/conf ssl/www

    # Временно запускаем nginx в режиме только HTTP для получения сертификата
    echo -e "\n${YELLOW}Запускаем nginx для валидации домена...${NC}"

    # Останавливаем основной compose если запущен
    docker compose down 2>/dev/null || true

    # Запускаем только nginx на 80 порту для получения сертификата
    docker run -d --rm --name temp-nginx \
        -p 80:80 \
        -v $(pwd)/ssl/www:/var/www/certbot \
        nginx:alpine sh -c "
            mkdir -p /var/www/certbot && 
            cat > /etc/nginx/conf.d/default.conf << 'EOF'
server {
    listen 80;
    server_name $DOMAIN;
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    location / {
        return 200 'OK';
    }
}
EOF
            nginx -g 'daemon off;'
        "

    sleep 2

    # Получаем сертификат через Certbot
    echo -e "\n${YELLOW}Получаем сертификат через Certbot...${NC}"
    docker run --rm \
        -v $(pwd)/ssl/conf:/etc/letsencrypt \
        -v $(pwd)/ssl/www:/var/www/certbot \
        certbot/certbot certonly --webroot \
        --webroot-path=/var/www/certbot \
        --email $EMAIL \
        --agree-tos \
        --no-eff-email \
        -d $DOMAIN

    # Останавливаем временный nginx
    docker stop temp-nginx

    # Запускаем основной compose
    echo -e "\n${YELLOW}Запускаем проект с SSL...${NC}"
    docker compose up -d

    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}  SSL сертификат получен!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo "Сайт: https://$DOMAIN (если 443 стандартный) или https://$DOMAIN:${HTTPS_PORT:-8443}"

elif [ "$ACTION" = "renew" ]; then
    echo -e "${YELLOW}Обновляем SSL сертификаты...${NC}"

    docker run --rm \
        -v $(pwd)/ssl/conf:/etc/letsencrypt \
        -v $(pwd)/ssl/www:/var/www/certbot \
        certbot/certbot renew --quiet

    # Перезагружаем nginx, чтобы применить новые сертификаты
    docker compose exec nginx nginx -s reload 2>/dev/null || \
        docker compose restart nginx

    echo -e "${GREEN}Сертификаты обновлены!${NC}"

else
    echo "Использование:"
    echo "  ./deploy/renew-ssl.sh init          # Получить новый сертификат"
    echo "  ./deploy/renew-ssl.sh <domain> init # Для другого домена"
    echo "  ./deploy/renew-ssl.sh renew         # Обновить существующие"
fi

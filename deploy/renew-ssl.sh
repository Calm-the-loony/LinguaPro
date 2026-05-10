#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DOMAIN="${1:-d24.clv-digital.tech}"

echo -e "${YELLOW}Обновление SSL сертификата для $DOMAIN...${NC}"

if ! command -v certbot &> /dev/null; then
    echo -e "${RED}certbot не установлен. Выполните сначала:${NC}"
    echo "  ./deploy/setup-domain.sh $DOMAIN"
    exit 1
fi

sudo certbot renew --nginx

echo -e "${GREEN}Сертификаты обновлены!${NC}"
echo ""
echo "Проверка: https://$DOMAIN"

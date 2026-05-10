#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DOMAIN="${1:-d24.clv-digital.tech}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Начало настройки сервера LinguaPro${NC}"
echo -e "${GREEN}  Домен: $DOMAIN${NC}"
echo -e "${GREEN}========================================${NC}"

# 1. Установка Docker
if ! command -v docker &> /dev/null; then
    echo -e "\n${YELLOW}Устанавливаем Docker...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    echo -e "${GREEN}Docker установлен${NC}"
else
    echo -e "${GREEN}Docker уже установлен: $(docker --version)${NC}"
fi

# 2. Установка Docker Compose plugin
if ! docker compose version &> /dev/null; then
    echo -e "\n${YELLOW}Устанавливаем Docker Compose plugin...${NC}"
    apt-get update -qq && apt-get install -y -qq docker-compose-plugin 2>/dev/null || {
        mkdir -p /usr/local/lib/docker/cli-plugins
        curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/lib/docker/cli-plugins/docker-compose
        chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
    }
    echo -e "${GREEN}Docker Compose установлен${NC}"
else
    echo -e "${GREEN}Docker Compose уже установлен: $(docker compose version)${NC}"
fi

# 3. Настройка .env
echo -e "\n${YELLOW}Настраиваем .env файл...${NC}"
if [ ! -f .env ]; then
    cat > .env << EOF
DOMAIN=$DOMAIN
DB_PASSWORD=lingua_secret
NODE_ENV=production
EOF
    echo -e "${GREEN}.env файл создан${NC}"
else
    echo -e "${YELLOW}.env файл уже существует, пропускаем${NC}"
fi

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  Настройка сервера завершена!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\nДалее выполните:"
echo -e "  1. Отредактируйте ${YELLOW}.env${NC} (при необходимости)"
echo -e "  2. Деплой: ${YELLOW}./deploy/deploy.sh${NC}"
echo -e "  3. Настройка домена и SSL: ${YELLOW}./deploy/setup-domain.sh $DOMAIN${NC}"

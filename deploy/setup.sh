#!/bin/bash
set -e

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DOMAIN="${1:-d24.clv-digital.tech}"
HTTP_PORT="${2:-8080}"
HTTPS_PORT="${3:-8443}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Начало настройки сервера LinguaPro${NC}"
echo -e "${GREEN}  Домен: $DOMAIN${NC}"
echo -e "${GREEN}  HTTP порт: $HTTP_PORT${NC}"
echo -e "${GREEN}  HTTPS порт: $HTTPS_PORT${NC}"
echo -e "${GREEN}========================================${NC}"

# 1. Проверка свободных портов
check_port() {
    local port=$1
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        echo -e "${RED}Порт $port занят!${NC}"
        return 1
    fi
    echo -e "${GREEN}Порт $port свободен${NC}"
    return 0
}

echo -e "\n${YELLOW}Проверяем порты...${NC}"
check_port $HTTP_PORT || exit 1
check_port $HTTPS_PORT || exit 1

# 2. Установка Docker
if ! command -v docker &> /dev/null; then
    echo -e "\n${YELLOW}Устанавливаем Docker...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    echo -e "${GREEN}Docker установлен${NC}"
else
    echo -e "${GREEN}Docker уже установлен: $(docker --version)${NC}"
fi

# 3. Установка Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "\n${YELLOW}Устанавливаем Docker Compose...${NC}"
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}Docker Compose установлен${NC}"
else
    echo -e "${GREEN}Docker Compose уже установлен${NC}"
fi

# 4. Создание папок для SSL
echo -e "\n${YELLOW}Создаем папки для SSL сертификатов...${NC}"
mkdir -p ssl/conf ssl/www

# 5. Настройка .env
echo -e "\n${YELLOW}Настраиваем .env файл...${NC}"
if [ ! -f .env ]; then
    cat > .env << EOF
DOMAIN=$DOMAIN
HTTP_PORT=$HTTP_PORT
HTTPS_PORT=$HTTPS_PORT
NODE_ENV=production
PORT=5000
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=tutor_website
DB_PORT=3307
EOF
    echo -e "${GREEN}.env файл создан${NC}"
else
    echo -e "${YELLOW}.env файл уже существует, пропускаем${NC}"
fi

# 6. Открытие портов в фаерволе
echo -e "\n${YELLOW}Настраиваем фаервол...${NC}"
if command -v ufw &> /dev/null; then
    ufw allow $HTTP_PORT/tcp
    ufw allow $HTTPS_PORT/tcp
    echo -e "${GREEN}Порты $HTTP_PORT и $HTTPS_PORT открыты${NC}"
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=$HTTP_PORT/tcp
    firewall-cmd --permanent --add-port=$HTTPS_PORT/tcp
    firewall-cmd --reload
    echo -e "${GREEN}Порты $HTTP_PORT и $HTTPS_PORT открыты${NC}"
else
    echo -e "${YELLOW}Не удалось найти ufw или firewalld. Откройте порты вручную.${NC}"
fi

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  Настройка сервера завершена!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\nДалее выполните:"
echo -e "  1. Отредактируйте ${YELLOW}.env${NC} файл (укажите данные БД)"
echo -e "  2. Запустите ${YELLOW}./deploy/deploy.sh${NC} для первого деплоя"
echo -e "  3. Запустите ${YELLOW}./deploy/renew-ssl.sh init${NC} для получения SSL сертификата"

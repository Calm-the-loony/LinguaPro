#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Деплой LinguaPro${NC}"
echo -e "${GREEN}========================================${NC}"

# Проверяем наличие .env
if [ ! -f .env ]; then
    echo -e "${RED}.env файл не найден!${NC}"
    echo "Скопируйте .env.example в .env и настройте"
    exit 1
fi

# Загружаем переменные
export $(grep -v '^#' .env | xargs)

# Проверяем, свободны ли порты
check_port() {
    local port=$1
    if ss -tuln 2>/dev/null | grep -q ":$port "; then
        echo -e "${YELLOW}Порт $port уже используется. Проверьте настройки.${NC}"
        return 0
    fi
}

check_port $HTTP_PORT
check_port $HTTPS_PORT

# Импорт БД, если есть дамп и флаг DB_INIT=true
if [ "${DB_INIT}" = "true" ] && [ -f tutor_website.sql ]; then
    echo -e "\n${YELLOW}Импортируем базу данных...${NC}"
    bash deploy/init-db.sh "$DOMAIN" || echo -e "${YELLOW}Импорт БД пропущен${NC}"
fi

# Получаем последнюю версию с GitHub
echo -e "\n${YELLOW}Обновляем код из репозитория...${NC}"
if [ -d .git ]; then
    git pull origin main
else
    echo -e "${RED}Не Git репозиторий. Клонируйте проект через git clone${NC}"
    exit 1
fi

# Собираем и запускаем контейнеры
echo -e "\n${YELLOW}Собираем и запускаем Docker контейнеры...${NC}"
docker compose build --no-cache server nginx
docker compose up -d

# Проверяем статус
echo -e "\n${YELLOW}Проверяем статус контейнеров...${NC}"
sleep 5
docker compose ps

# Проверяем, что сервер отвечает
echo -e "\n${YELLOW}Проверяем API...${NC}"
if curl -sf "http://localhost:$HTTP_PORT/" > /dev/null 2>&1; then
    echo -e "${GREEN}Сайт отвечает!${NC}"
else
    echo -e "${YELLOW}Сайт пока недоступен. Возможно, нужен SSL сертификат.${NC}"
    echo "Запустите: ./deploy/renew-ssl.sh init"
fi

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  Деплой завершен!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Сайт: http://$DOMAIN:$HTTP_PORT"
echo "Админка: http://$DOMAIN:$HTTP_PORT/admin"
echo ""
echo "Для получения SSL сертификата выполните:"
echo "  ./deploy/renew-ssl.sh init"
echo ""
echo "Для просмотра логов:"
echo "  docker compose logs -f"

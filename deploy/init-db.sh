#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Инициализация базы данных LinguaPro${NC}"
echo -e "${GREEN}========================================${NC}"

# Загружаем .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

DB_PASSWORD="${DB_PASSWORD:-lingua_secret}"
DB_NAME="${DB_NAME:-tutor_website}"

echo -e "\nБД '$DB_NAME' импортируется автоматически при первом запуске MySQL."
echo ""

# Запускаем MySQL, если ещё не запущен
if ! docker ps --format '{{.Names}}' 2>/dev/null | grep -q "linguapro.*mysql"; then
    echo -e "${YELLOW}Запускаем MySQL контейнер...${NC}"
    docker compose up -d mysql
fi

echo -e "\n${YELLOW}Ожидаем готовности MySQL...${NC}"
for i in $(seq 1 30); do
    STATUS=$(docker inspect --format='{{.State.Health.Status}}' $(docker compose ps -q mysql 2>/dev/null) 2>/dev/null)
    if [ "$STATUS" = "healthy" ]; then
        echo -e "${GREEN}MySQL готов!${NC}"
        break
    fi
    sleep 2
done

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  База данных готова к работе!${NC}"
echo -e "${GREEN}========================================${NC}"

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

# Если MySQL уже запущен через docker-compose
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "lingua.*mysql\|LinguaPro.*mysql"; then
    echo -e "${GREEN}MySQL контейнер уже запущен. Дамп импортируется автоматически.${NC}"
    echo ""
    echo -e "Проверьте статус: ${YELLOW}docker-compose ps mysql${NC}"
    echo -e "Логи MySQL:    ${YELLOW}docker-compose logs mysql${NC}"
    exit 0
fi

# Если MySQL контейнер не запущен, запускаем только mysql сервис
echo -e "\n${YELLOW}Запускаем MySQL контейнер и импортируем дамп...${NC}"
docker-compose up -d mysql

echo -e "\n${YELLOW}Ожидаем готовности MySQL...${NC}"
sleep 5

# Ждём healthcheck
for i in $(seq 1 30); do
    STATUS=$(docker inspect --format='{{.State.Health.Status}}' $(docker-compose ps -q mysql 2>/dev/null) 2>/dev/null)
    if [ "$STATUS" = "healthy" ]; then
        echo -e "${GREEN}MySQL готов!${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# Проверяем таблицы
echo -e "\n${YELLOW}Проверяем импортированные таблицы...${NC}"
docker-compose exec -T mysql mysql -uroot -p"${DB_PASSWORD:-lingua_secret}" "${DB_NAME:-tutor_website}" -e "SHOW TABLES" 2>/dev/null || {
    echo -e "\n${YELLOW}Таблицы пока не импортированы. Проверьте логи:${NC}"
    echo "  docker-compose logs mysql"
    echo ""
    echo "Если дамп не импортировался, выполните вручную:"
    echo "  docker-compose exec -T mysql mysql -uroot -p${DB_PASSWORD:-lingua_secret} ${DB_NAME:-tutor_website} < tutor_website.sql"
}

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  База данных готова к работе!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Запустите деплой: ${YELLOW}./deploy/deploy.sh${NC}"

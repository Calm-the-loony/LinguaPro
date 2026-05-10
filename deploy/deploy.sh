#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Деплой LinguaPro${NC}"
echo -e "${GREEN}========================================${NC}"

if [ ! -f .env ]; then
    echo -e "${RED}.env файл не найден!${NC}"
    echo "Скопируйте .env.example в .env и настройте"
    exit 1
fi

export $(grep -v '^#' .env | xargs)

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

# Проверяем, что наш Docker nginx отвечает
echo -e "\n${YELLOW}Проверяем Docker nginx...${NC}"
if curl -sf http://127.0.0.1:8081/ > /dev/null 2>&1; then
    echo -e "${GREEN}Docker nginx отвечает на 127.0.0.1:8081${NC}"
else
    echo -e "${RED}Docker nginx не отвечает. Смотрите логи: docker compose logs nginx${NC}"
fi

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  Деплой завершен!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Docker nginx: http://127.0.0.1:8081"
echo ""
echo "Для настройки домена через host nginx выполните:"
echo "  ./deploy/setup-domain.sh d24.clv-digital.tech"
echo ""
echo "Для просмотра логов:"
echo "  docker compose logs -f"

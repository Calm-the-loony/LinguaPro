#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DOMAIN="${1:-d24.clv-digital.tech}"

# Загружаем .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo -e "${RED}.env файл не найден!${NC}"
    exit 1
fi

DB_HOST="${DB_HOST:-localhost}"
DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-}"
DB_NAME="${DB_NAME:-tutor_website}"
DB_PORT="${DB_PORT:-3307}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Инициализация базы данных LinguaPro${NC}"
echo -e "${GREEN}========================================${NC}"
echo "Хост: $DB_HOST:$DB_PORT"
echo "БД:   $DB_NAME"
echo "Пользователь: $DB_USER"

# Проверяем доступность MySQL
if ! command -v mysql &> /dev/null; then
    echo -e "${YELLOW}MySQL CLI не найден. Устанавливаем mysql-client...${NC}"
    apt-get update -qq && apt-get install -y -qq default-mysql-client
fi

echo -e "\n${YELLOW}Проверяем подключение к MySQL...${NC}"

MYSQL_OPTS="-h $DB_HOST -P $DB_PORT -u $DB_USER"
if [ -n "$DB_PASSWORD" ]; then
    MYSQL_OPTS="$MYSQL_OPTS -p$DB_PASSWORD"
fi

# Проверка подключения
if ! mysql $MYSQL_OPTS -e "SELECT 1" > /dev/null 2>&1; then
    echo -e "${RED}Не удалось подключиться к MySQL!${NC}"
    echo "Проверьте параметры подключения в .env"
    exit 1
fi
echo -e "${GREEN}Подключение установлено${NC}"

# Создаём БД, если не существует
echo -e "\n${YELLOW}Создаём базу данных $DB_NAME (если не существует)...${NC}"
mysql $MYSQL_OPTS -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
echo -e "${GREEN}База данных готова${NC}"

# Импортируем дамп
if [ -f tutor_website.sql ]; then
    echo -e "\n${YELLOW}Импортируем данные из tutor_website.sql...${NC}"
    mysql $MYSQL_OPTS $DB_NAME < tutor_website.sql
    echo -e "${GREEN}Дамп успешно импортирован!${NC}"
else
    echo -e "${RED}Файл tutor_website.sql не найден!${NC}"
    exit 1
fi

# Проверяем таблицы
echo -e "\n${YELLOW}Проверяем импортированные таблицы...${NC}"
TABLES=$(mysql $MYSQL_OPTS $DB_NAME -e "SHOW TABLES" -B -s 2>/dev/null)
echo "$TABLES" | while read table; do
    COUNT=$(mysql $MYSQL_OPTS $DB_NAME -e "SELECT COUNT(*) as cnt FROM \`$table\`" -B -s 2>/dev/null)
    echo -e "  ${GREEN}✓${NC} $table ($COUNT записей)"
done

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  База данных готова к работе!${NC}"
echo -e "${GREEN}========================================${NC}"

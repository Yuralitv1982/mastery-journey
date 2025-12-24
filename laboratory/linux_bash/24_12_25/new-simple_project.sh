#!/bin/zsh

# 1. Настройка путей и времени
BASE_DIR="/mnt/disc_d/develop"
TIMESTAMP=$(date +%H_%M)

# Логика: если аргумента нет, имя 'env', если есть - берем его. В конце добавляем -HH_MM
NAME_PART=${1:-env}
PROJECT_NAME="${NAME_PART}-${TIMESTAMP}"
TARGET_PATH="$BASE_DIR/$PROJECT_NAME"

# 2. Проверка доступности диска
if [ ! -d "$BASE_DIR" ]; then
    echo "ОШИБКА: Диск /mnt/disc_d не примонтирован или папка develop отсутствует."
    exit 1
fi

# 3. Создание проекта
mkdir -p "$TARGET_PATH" && cd "$TARGET_PATH" || exit

# 4. Генерация "Золотого стандарта" (Версия 3.1)
cat <<EOF > index.html
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="style.css">
    <title>$PROJECT_NAME</title>
</head>
<body>
    <script src="script.js"></script>
</body>
</html>
EOF

cat <<EOF > style.css
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
EOF

echo "console.log('Project $PROJECT_NAME initialized');" > script.js

# 5. Запуск Geany и Сервера
geany index.html style.css script.js &
live-server --port=8080 --no-browser &

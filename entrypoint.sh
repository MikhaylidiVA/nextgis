#!/bin/bash
set -e

echo "🎨 Applying custom design theme..."

# Путь к статике NextGIS внутри контейнера
STATIC_DIR="/usr/lib/python3/dist-packages/nextgisweb/static/nextgisweb"
ASSETS_DIR="$STATIC_DIR/assets"

# 1. Копируем кастомный CSS
if [ -f "/app/customization/css/custom-theme.css" ]; then
    cp /app/customization/css/custom-theme.css "$STATIC_DIR/css/custom-theme.css"
    echo "✅ Custom CSS applied."
else
    echo "⚠️ custom-theme.css not found!"
fi

# 2. Копируем логотип (заменяем стандартный, если нужно, или добавляем новый)
if [ -f "/app/customization/assets/logo.svg" ]; then
    # Создаем резервную копию оригинала, если её нет
    if [ ! -f "$ASSETS_DIR/logo.svg.bak" ]; then
        cp "$ASSETS_DIR/logo.svg" "$ASSETS_DIR/logo.svg.bak" 2>/dev/null || true
    fi
    cp /app/customization/assets/logo.svg "$ASSETS_DIR/logo.svg"
    echo "✅ Custom Logo applied."
fi

# 3. Внедряем ссылку на CSS в основной шаблон (если нужно)
# Ищем index.html или base.html и добавляем link на наш css, если его там еще нет
BASE_TEMPLATE="$STATIC_DIR/index.html"
if [ -f "$BASE_TEMPLATE" ]; then
    if ! grep -q "custom-theme.css" "$BASE_TEMPLATE"; then
        sed -i 's|</head>|<link rel="stylesheet" href="css/custom-theme.css"></head>|' "$BASE_TEMPLATE"
        echo "✅ CSS linked in HTML."
    fi
fi

echo "🚀 Starting NextGIS Web..."
# Запускаем оригиначный процесс (gunicorn или uwsgi, в зависимости от образа)
# Для официального образа nextgis/nextgis_web обычно используется gunicorn
exec gunicorn nextgisweb:application --bind 0.0.0.0:8080 --workers 4 --threads 2

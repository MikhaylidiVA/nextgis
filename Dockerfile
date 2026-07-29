# Базовый образ: Ubuntu 22.04 (совместима с требованиями NextGIS)
FROM ubuntu:22.04

# Переменные окружения для сборки
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Аргументы для версии NextGIS (можно менять при сборке)
ARG NEXTGIS_VERSION=4.3

# 1. Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    gnupg2 \
    curl \
    python3-pip \
    python3-dev \
    python3-virtualenv \
    libxml2-dev \
    libxslt1-dev \
    libgeos-dev \
    libproj-dev \
    libgdal-dev \
    gdal-bin \
    postgresql-client \
    locales \
    && rm -rf /var/lib/apt/lists/*

# 2. Добавление репозитория NextGIS
RUN wget -O - https://mirror.nextgis.com/debian/public.key | gpg --dearmor -o /usr/share/keyrings/nextgis-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/nextgis-archive-keyring.gpg] https://mirror.nextgis.com/debian stable main" > /etc/apt/sources.list.d/nextgis.list

# 3. Установка NextGIS Web
RUN apt-get update && \
    apt-get install -y nextgisweb=${NEXTGIS_VERSION}.* nextgisweb-extension-sentinel nextgisweb-extension-qgis-server && \
    rm -rf /var/lib/apt/lists/*

# 4. Подготовка директорий
RUN mkdir -p /etc/nextgisweb && \
    mkdir -p /var/www/nextgisweb && \
    chown -R www-data:www-data /var/www/nextgisweb /etc/nextgisweb

# 5. Копирование файлов кастомизации
# Убедитесь, что эти файлы есть в папке customization в вашем репозитории
COPY customization/css/custom-theme.css /tmp/custom-theme.css
COPY customization/assets/logo.svg /tmp/logo.svg

# 6. Скрипт запуска (Entry point)
# Он применяется при каждом старте контейнера, чтобы гарантировать наличие дизайна
COPY <<EOF /entrypoint.sh
#!/bin/bash
set -e

echo ">>> Applying Custom Design..."

# Находим путь к статике NextGIS
# Обычно это /usr/lib/python3/dist-packages/nextgisweb/static
NGW_PATH=\$(python3 -c "import nextgisweb; import os; print(os.path.join(os.path.dirname(nextgisweb.__file__), 'static'))")

CSS_DIR="\$NGW_PATH/css"
IMG_DIR="\$NGW_PATH/img"
TEMPLATE="\$NGW_PATH/../pyramid/templates/master.mako"

# Создаем директории
mkdir -p "\$CSS_DIR" "\$IMG_DIR"

# Копируем CSS
cp /tmp/custom-theme.css "\$CSS_DIR/custom-theme.css"
echo "CSS copied to \$CSS_DIR"

# Патчим шаблон master.mako для подключения CSS
if [ -f "\$TEMPLATE" ]; then
    if ! grep -q "custom-theme.css" "\$TEMPLATE"; then
        sed -i 's|</head>|    <link rel="stylesheet" href="/static/css/custom-theme.css">\n</head>|' "\$TEMPLATE"
        echo "Template patched."
    fi
fi

# Заменяем логотип
if [ -f "\$IMG_DIR/logo.svg" ]; then
    cp "\$IMG_DIR/logo.svg" "\$IMG_DIR/logo.svg.bak"
fi
cp /tmp/logo.svg "\$IMG_DIR/logo.svg"
echo "Logo replaced."

echo ">>> Starting NextGIS Web..."
# Запуск от имени пользователя www-data, если нужно, или просто запуск команды
# Для упрощения запускаем напрямую, права на папки уже даны выше
exec nextgisweb serve --bind 0.0.0.0:8000
EOF

RUN chmod +x /entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]

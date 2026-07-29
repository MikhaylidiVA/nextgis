# Используем официальный образ NextGIS Web как базу
FROM nextgis/nextgis_web:latest

# Переменные для путей кастомизации
ENV CUSTOM_CSS_PATH=/usr/local/lib/python3.10/dist-packages/nextgisweb/static/css/custom-theme.css
ENV CUSTOM_LOGO_PATH=/usr/local/lib/python3.10/dist-packages/nextgisweb/static/img/logo.svg

# Копируем файлы кастомизации в образ
# Примечание: путь к статике может отличаться в зависимости от версии Python в образе.
# Если версия изменится, нужно будет поправить путь выше или использовать поиск.

COPY customization/css/custom-theme.css /tmp/custom-theme.css
COPY customization/assets/logo.svg /tmp/logo.svg

# Скрипт инициализации, который выполнится при первом запуске контейнера
# Он скопирует наши файлы в системную папку NextGIS
RUN echo '#!/bin/bash \n\
set -e \n\
echo "Applying custom design..." \n\
# Находим реальную директорию пакета nextgisweb \n\
NGW_DIR=$(python3 -c "import nextgisweb, os; print(os.path.dirname(nextgisweb.__file__))") \n\
STATIC_DIR="$NGW_DIR/static" \n\
CSS_DIR="$STATIC_DIR/css" \n\
IMG_DIR="$STATIC_DIR/img" \n\
\
# Создаем директории если нет \n\
mkdir -p "$CSS_DIR" \n\
mkdir -p "$IMG_DIR" \n\
\n\
# Копируем файлы \n\
cp /tmp/custom-theme.css "$CSS_DIR/custom-theme.css" \n\
cp /tmp/logo.svg "$IMG_DIR/logo.svg" \n\
\
# Внедряем подключение CSS в основной шаблон, если еще не внедрено \n\
BASE_TEMPLATE="$NGW_DIR/pyramid/templates/master.mako" \n\
if ! grep -q "custom-theme.css" "$BASE_TEMPLATE"; then \n\
    sed -i "s|</head>|    <link rel=\"stylesheet\" href=\"/static/css/custom-theme.css\">\n</head>|" "$BASE_TEMPLATE"; \n\
fi \n\
\
# Заменяем стандартный логотип на наш (резервная копия оригинала) \n\
if [ ! -f "$IMG_DIR/logo.svg.bak" ]; then \n\
    mv "$IMG_DIR/logo.svg" "$IMG_DIR/logo.svg.bak" 2>/dev/null || true; \n\
fi \n\
cp /tmp/logo.svg "$IMG_DIR/logo.svg" \n\
\
echo "Custom design applied successfully!" \n\
' > /entrypoint.sh

# Делаем скрипт исполняемым
RUN chmod +x /entrypoint.sh

# Переопределяем точку входа
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nextgisweb", "serve", "--bind", "0.0.0.0:8000"]

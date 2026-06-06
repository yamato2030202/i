#!/bin/bash

# تشغيل خادم قاعدة البيانات داخلياً
service mysql start 2>/dev/null

# إعداد قاعدة بيانات افتراضية للوحة OGP بشكل تلقائي إذا لم تكن موجودة
mysql -e "CREATE DATABASE IF NOT EXISTS ogp_panel;" 2>/dev/null
mysql -e "GRANT ALL PRIVILEGES ON ogp_panel.* TO 'ogpuser'@'localhost' IDENTIFIED BY 'jzg14cBwPaJM';" 2>/dev/null
mysql -e "FLUSH PRIVILEGES;" 2>/dev/null

# ضبط الصلاحيات الصحيحة لمجلد الويب
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

# تفعيل مود التوجيه (Rewrite) في الـ Apache
a2enmod rewrite 2>/dev/null

# أخذ المنفذ الديناميكي الذي تفرضه منصة Railway وضبط Apache عليه تلقائياً
RAILWAY_PORT=${PORT:-8080}
echo "Configuring Apache to listen on port: $RAILWAY_PORT"

sed -i "s/Listen .*/Listen $RAILWAY_PORT/g" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:*>/<VirtualHost \*:$RAILWAY_PORT>/g" /etc/apache2/sites-available/000-default.conf

# تشغيل خادم Apache في الواجهة الأمامية (Foreground) لمنع الحاوية من الإغلاق
echo "Starting Apache Web Server..."
exec apache2ctl -D FOREGROUND

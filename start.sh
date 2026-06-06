#!/bin/bash

# تأمين تشغيل خادم ماريادب/مايسكول إذا كان متاحاً محلياً
service mysql start 2>/dev/null

# إعطاء الصلاحيات الصحيحة لمجلد الويب الخاص بلوحة OGP
chown -R www-data:www-data /var/www/html/ 2>/dev/null
chmod -R 755 /var/www/html/ 2>/dev/null

# تفعيل مود التوجيه (Rewrite) في الـ Apache
a2enmod rewrite 2>/dev/null

# أخذ المنفذ الديناميكي الذي تفرضه منصة Railway (غالباً 8080) وضبط Apache عليه تلقائياً
RAILWAY_PORT=${PORT:-8080}
echo "Configuring Apache to listen on port: $RAILWAY_PORT"

sed -i "s/Listen .*/Listen $RAILWAY_PORT/g" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:*>/<VirtualHost \*:$RAILWAY_PORT>/g" /etc/apache2/sites-available/000-default.conf

# تشغيل خادم Apache في الواجهة الأمامية (Foreground) لمنع الحاوية من الإغلاق المفاجئ ولتستجيب لـ Railway
echo "Starting Apache Web Server..."
exec apache2ctl -D FOREGROUND

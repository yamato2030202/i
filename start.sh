#!/bin/bash

# 1. تشغيل محرك Tailscale في الخلفية عبر شبكة المستخدم (Userspace) لتوافق تام مع Railway
tailscaled --state=/var/lib/tailscale/tailscaled.state --tun=userspace-networking &

# الانتظار للتأكد من أن المحرك يعمل بالكامل
sleep 5

# 2. ربط الحاوية بحساب Tailscale الخاص بك عبر المفتاح السري
if [ -n "$TAILSCALE_AUTH_KEY" ]; then
    echo "Connecting to Tailscale..."
    tailscale up --authkey=${TAILSCALE_AUTH_KEY} --hostname=railway-fast-rdp
else
    echo "ERROR: TAILSCALE_AUTH_KEY variable is missing!"
    exit 1
fi

# 3. تنظيف ملفات الـ PID السابقة لخادم RDP لمنع تعليق التشغيل
rm -f /var/run/xrdp/xrdp*.pid

# 4. تشغيل خادم xrdp وإبقائه يعمل في المقدمة للحفاظ على استمرار الحاوية
echo "Starting RDP Server..."
xrdp-sesman --nodaemon &
xrdp --nodaemon

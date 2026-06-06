FROM debian:9-slim

# منع الأسئلة التفاعلية أثناء التثبيت لضمان بناء تلقائي سريع
ENV DEBIAN_FRONTEND=noninteractive

# تعديل المستودعات لتشير إلى الأرشيف لأن Debian 9 لم تعد مدعومة رسميًا
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list \
    && sed -i 's/security.debian.org/archive.debian.org/g' /etc/apt/sources.list \
    && sed -i '/stretch-updates/d' /etc/apt/sources.list

# تحديث المستودعات وتثبيت الأدوات الأساسية، خادم الويب Apache، و بيئة PHP اللازمة لتشغيل اللوحة
RUN apt-get update && apt-get install -y --force-yes \
    apt-transport-https \
    ca-certificates \
    apache2 \
    php \
    php-mysql \
    php-xml \
    php-curl \
    mysql-server \
    lxde \
    xrdp \
    curl \
    sudo \
    wget \
    dbus-x11 \
    x11-xserver-utils \
    git \
    && rm -rf /var/lib/apt/lists/*

# تحميل ملفات لوحة Open Game Panel (OGP) مباشرة إلى مسار الويب الرئيسي
RUN rm -rf /var/www/html/* && \
    git clone https://github.com/OpenGamePanel/OGP-Website.git /var/www/html/

# إعداد خادم xrdp ليقوم بتشغيل واجهة LXDE الخفيفة فوراً عند الاتصال
RUN echo "startlxde" > /etc/skel/.Xclients
RUN mkdir -p /etc/xrdp && echo "allowed_users=anybody" > /etc/xrdp/Xwrapper.config

# تحسين أداء xrdp لتقليل التقطيع (تفعيل التخزين المؤقت والتعديل اللوني)
RUN sed -i 's/max_bpp=32/max_bpp=16/g' /etc/xrdp/xrdp.ini \
    && sed -i 's/crypt_level=high/crypt_level=none/g' /etc/xrdp/xrdp.ini

# تثبيت أداة Tailscale للاتصال السريع والآمن
RUN curl -fsSL https://tailscale.com/install.sh | sh

# إنشاء مستخدم الـ RDP السريع وتعيين كلمة المرور وصلاحيات الـ Sudo
RUN useradd -m -s /bin/bash RDP && \
    echo "RDP:123456" | chpasswd && \
    adduser RDP sudo

# نسخ سكربت التشغيل ومنحه صلاحيات التنفيذ
COPY start.sh /start.sh
RUN chmod +x /start.sh

# فتح المنفذ الديناميكي (ستقوم Railway بالتحكم به عبر متغير PORT)
EXPOSE 8080

# تشغيل السكربت عند بدء الحاوية
CMD ["/start.sh"]

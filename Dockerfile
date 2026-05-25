FROM ubuntu:22.04

# منع الأسئلة التفاعلية أثناء التثبيت لضمان بناء تلقائي سريع
ENV DEBIAN_FRONTEND=noninteractive

# تحديث المستودعات وتثبيت أخف واجهة رسومية في العالم (LXDE) مع خادم xrdp وأدوات الأداء
RUN apt-get update && apt-get install -y \
    lxde \
    xrdp \
    curl \
    sudo \
    wget \
    dbus-x11 \
    x11-xserver-utils \
    && rm -rf /var/lib/apt/lists/*

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

# فتح المنفذ الخاص بالـ RDP
EXPOSE 3389

# تشغيل السكربت عند بدء الحاوية
CMD ["/start.sh"]

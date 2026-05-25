FROM ubuntu:22.04

# منع الأسئلة التفاعلية أثناء التثبيت لضمان بناء تلقائي سلس
ENV DEBIAN_FRONTEND=noninteractive

# تحديث النظام وتثبيت الواجهة الرسومية (XFCE) وخادم الـ RDP والأدوات الأساسية
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xrdp \
    curl \
    sudo \
    wget \
    && rm -rf /var/lib/apt/lists/*

# إعداد خادم xrdp لفتح واجهة XFCE فور تسجيل الدخول
RUN echo "xfce4-session" > /etc/skel/.Xclients
RUN sed -i 's/allowed_users=console/allowed_users=anybody/g' /etc/xrdp/Xwrapper.config

# تثبيت أداة Tailscale للاتصال الآمن
RUN curl -fsSL https://tailscale.com/install.sh | sh

# إنشاء مستخدم الـ RDP وتعيين كلمة المرور وإعطائه صلاحيات الـ Sudo (الـ Administrator)
RUN useradd -m -s /bin/bash RDP && \
    echo "RDP:SecurePassword123!" | chpasswd && \
    adduser RDP sudo

# نسخ سكربت التشغيل ومنحه صلاحيات التنفيذ
COPY start.sh /start.sh
RUN chmod +x /start.sh

# فتح المنفذ الخاص بالـ RDP
EXPOSE 3389

# تشغيل السكربت عند بدء الحاوية
CMD ["/start.sh"]

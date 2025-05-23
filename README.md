# 🛠️ n8n Auto-Installer Script | اسکریپت نصب خودکار n8n

This is a one-line installer script for setting up [n8n](https://n8n.io) on **Ubuntu 22.04 / 24.04** using **Docker & Docker Compose**.  
You can install and start n8n with just one command.

این اسکریپت برای نصب خودکار n8n روی سیستم‌عامل های اوبونتو 22.04 و 24.04 نوشته شده و با استفاده از Docker و Docker Compose اجرا می‌شود.  
فقط با یک دستور ساده در ترمینال، n8n را نصب و راه‌اندازی کنید.

---

## 🚀 Quick Install | نصب سریع

Run this command as **root** user (or use `sudo` before it):

این دستور را با دسترسی root اجرا کنید:

```bash
bash <(curl -Ls https://raw.githubusercontent.com/DanialNaghavi/n8n-installer/main/n8n-install.sh)
```

📦 What it does | این اسکریپت چه کارهایی انجام می‌دهد:

✅ Updates system packages
بروزرسانی پکیج‌های سیستم

✅ Installs Docker & Docker Compose
نصب داکر و داکر کامپوز

✅ Asks for custom port
درخواست پورت دلخواه از کاربر

✅ Detects your public IP & timezone
تشخیص IP عمومی و منطقه زمانی سیستم

✅ Sets up n8n with Docker Compose
تنظیم و اجرای n8n با استفاده از Docker Compose

✅ Starts and verifies n8n container
راه‌اندازی و بررسی وضعیت اجرای 
🌐 After Installation | پس از نصب

You can access the n8n web interface in your browser:

شما می‌توانید رابط گرافیکی n8n را از طریق مرورگر و آدرس زیر مشاهده کنید:
```
http://<your-server-ip>:<your-port>
```

Replace <your-server-ip> with your server's public IP and <your-port> with the port you selected during installation.



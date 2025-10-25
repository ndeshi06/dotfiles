#!/bin/bash
# install_packages.sh — Cài đặt lại gói từ manual.txt cho mọi distro
# Hỗ trợ: Debian/Ubuntu, Arch, Fedora
set -e

PKGLIST="manual.txt"

if [ ! -f "$PKGLIST" ]; then
    echo "❌ Không tìm thấy file $PKGLIST trong thư mục hiện tại!"
    echo "➡️  Hãy tạo file này bằng lệnh: apt-mark showmanual > manual.txt (hoặc tương tự)"
    exit 1
fi

echo "🧩 Đang nhận dạng hệ điều hành..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "❌ Không xác định được distro!"
    exit 1
fi

echo "📦 Hệ điều hành phát hiện: $DISTRO"

# --- Debian / Ubuntu / Mint ---
if [[ "$DISTRO" =~ ^(debian|ubuntu|linuxmint)$ ]]; then
    echo "🔧 Cài đặt bằng apt..."
    sudo apt update -y
    xargs -a "$PKGLIST" sudo apt install -y

# --- Arch / Manjaro ---
elif [[ "$DISTRO" =~ ^(arch|manjaro)$ ]]; then
    echo "🔧 Cài đặt bằng pacman..."
    sudo pacman -Syu --noconfirm
    sudo pacman -S --needed --noconfirm - < "$PKGLIST"

# --- Fedora ---
elif [[ "$DISTRO" =~ ^(fedora)$ ]]; then
    echo "🔧 Cài đặt bằng dnf..."
    sudo dnf update -y
    xargs sudo dnf install -y < "$PKGLIST"

else
    echo "❌ Distro này chưa được hỗ trợ tự động."
    echo "➡️  Hãy cài thủ công dựa vào nội dung trong $PKGLIST."
    exit 1
fi

echo "✅ Hoàn tất cài đặt tất cả gói trong $PKGLIST!"


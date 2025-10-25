#!/bin/bash
# reverse_dotfiles.sh — Restore all dotfiles, .config, and .local back to system

set -e

DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"
LOCAL_DIR="$HOME/.local"

echo "🔁 Restoring dotfiles from $DOTFILES_DIR ..."

# ---------------------------------------------
# Hàm tạo symlink an toàn
# ---------------------------------------------
safe_link() {
    local src="$1"
    local dest="$2"

    # Nếu file đã là symlink tới đúng nguồn thì bỏ qua
    if [ -L "$dest" ] && [ "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]; then
        echo "⚙️  Skipped (already linked): $dest"
        return
    fi

    # Xoá file/folder cũ (nếu có)
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        rm -rf "$dest"
    fi

    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    echo "✅ Linked: $dest → $src"
}

# ---------------------------------------------
# 1️⃣ Restore các file dot (trong $HOME)
# ---------------------------------------------
echo "📂 Restoring home dotfiles..."
for item in "$DOTFILES_DIR"/.*; do
    name=$(basename "$item")
    # bỏ qua . và ..
    [[ "$name" == "." || "$name" == ".." ]] && continue

    # bỏ qua .config và .local vì xử lý riêng
    [[ "$name" == ".config" || "$name" == ".local" ]] && continue

    dest="$HOME/$name"
    safe_link "$item" "$dest"
done

# ---------------------------------------------
# 2️⃣ Restore ~/.config/*
# ---------------------------------------------
if [ -d "$DOTFILES_DIR/.config" ]; then
    echo "🧩 Restoring .config..."
    for dir in "$DOTFILES_DIR/.config"/*; do
        name=$(basename "$dir")
        dest="$CONFIG_DIR/$name"
        safe_link "$dir" "$dest"
    done
fi

# ---------------------------------------------
# 3️⃣ Restore ~/.local/*
# ---------------------------------------------
if [ -d "$DOTFILES_DIR/.local" ]; then
    echo "📦 Restoring .local..."
    for dir in "$DOTFILES_DIR/.local"/*; do
        name=$(basename "$dir")
        dest="$LOCAL_DIR/$name"
        safe_link "$dir" "$dest"
    done
fi

# ---------------------------------------------
# 4️⃣ Restore thủ công từ manual.txt (nếu có)
# ---------------------------------------------
manual_file="$DOTFILES_DIR/manual.txt"
if [[ -f "$manual_file" ]]; then
    echo "📘 Restoring extra entries from manual.txt..."
    while IFS= read -r extra; do
        [[ -z "$extra" || "$extra" == \#* ]] && continue

        if [[ "$extra" == .config/* ]]; then
            src="$DOTFILES_DIR/$extra"
            dest="$HOME/$extra"
        elif [[ "$extra" == .local/* ]]; then
            src="$DOTFILES_DIR/$extra"
            dest="$HOME/$extra"
        else
            src="$DOTFILES_DIR/.config/$extra"
            dest="$HOME/.config/$extra"
        fi

        if [ -e "$src" ]; then
            safe_link "$src" "$dest"
        else
            echo "❌ Skipped (not found in dotfiles): $src"
        fi
    done < "$manual_file"
fi

echo "🎉 Dotfiles restored successfully!"


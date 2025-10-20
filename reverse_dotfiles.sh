#!/bin/bash
# reverse_dotfiles.sh
# mục đích: symlink tất cả file trong dotfiles ra home hoặc ~/.config

DOTFILES_DIR="$HOME/dotfiles"  # thay đường dẫn nếu cần
CONFIG_DIR="$HOME/.config"

# hàm reverse 1 thư mục
reverse_dir() {
    local src_dir="$1"
    local dest_dir="$2"

    mkdir -p "$dest_dir"

    for item in "$src_dir"/*; do
        name=$(basename "$item")
        if [ -d "$item" ]; then
            # nếu là thư mục, gọi đệ quy
            reverse_dir "$item" "$dest_dir/$name"
        else
            # nếu là file, symlink
            mkdir -p "$(dirname "$dest_dir/$name")"
            ln -sf "$item" "$dest_dir/$name"
            echo "Linked $item -> $dest_dir/$name"
        fi
    done
}

# duyệt tất cả thư mục con trong dotfiles
for dir in "$DOTFILES_DIR"/*; do
    name=$(basename "$dir")
    # nếu là config (nvim, hypr, etc) thì vào .config
    case "$name" in
        nvim|tmux|hypr|waybar|kitty|rofi)
            reverse_dir "$dir" "$CONFIG_DIR/$name"
            ;;
        *)
            # các file khác copy ra home với dấu chấm
            for file in "$dir"/*; do
                fname=".$(basename "$file")"
                ln -sf "$file" "$HOME/$fname"
                echo "Linked $file -> $HOME/$fname"
            done
            ;;
    esac
done

echo "✅ Reverse dotfiles hoàn tất!"


#!/bin/bash
# setup_dotfiles.sh — Safe, idempotent, auto-detect configs and local data
set -e

DOTFILES_DIR="$HOME/dotfiles"
mkdir -p "$DOTFILES_DIR/.config"
mkdir -p "$DOTFILES_DIR/.local"

echo "🔧 Moving dotfiles and configs into $DOTFILES_DIR"

# ------------------------------
# Các file chính trong HOME
# ------------------------------
files=(
  ".bashrc"
  ".zshrc"
  ".oh-my-zsh"
  ".gitconfig"
  ".p10k.zsh"
  ".bash_aliases"
  ".tmux.conf"
)

# ------------------------------
# Ignore list cho ~/.config và ~/.local
# ------------------------------
ignore_configs=(
  "Code"
  "BraveSoftware"
  "chromium"
  "discord"
  "slack"
  "gtk-*"
  "dconf"
  "pulse"
  "autostart"
  "mimeapps.list"
)

ignore_local=(
  "share/Trash"
  "share/recently-used.xbel"
  "share/icons"
  "share/flatpak"
  "share/gnome-shell"
  "share/gvfs-metadata"
  "cache"
  "state"
  "lib"
)

# ------------------------------
# Đọc danh sách bổ sung từ manual.txt (nếu có)
# ------------------------------
manual_file="$DOTFILES_DIR/manual.txt"
if [[ -f "$manual_file" ]]; then
  echo "📘 Đang đọc danh sách config từ manual.txt..."
  mapfile -t manual_configs < "$manual_file"
else
  manual_configs=()
fi

# ------------------------------
# Hàm kiểm tra ignore
# ------------------------------
is_ignored() {
  local name="$1"
  shift
  local patterns=("$@")
  for pat in "${patterns[@]}"; do
    [[ "$name" == $pat ]] && return 0
  done
  return 1
}

move_and_link() {
  local src="$1"
  local dest="$2"

  if [ -L "$src" ]; then
    echo "⚠️  Skipped $src (already symlink)"
    return
  fi

  if [ -e "$src" ]; then
    mkdir -p "$(dirname "$dest")"
    mv "$src" "$dest"
    ln -s "$dest" "$src"
    echo "✅ Moved and linked $src → $dest"
  fi
}

# ------------------------------
# Di chuyển các file chính trong HOME
# ------------------------------
for f in "${files[@]}"; do
  move_and_link "$HOME/$f" "$DOTFILES_DIR/$f"
done

# ------------------------------
# Di chuyển ~/.config/*
# ------------------------------
echo "⚙️ Moving ~/.config files..."
for dir in "$HOME/.config"/*; do
  name=$(basename "$dir")
  if is_ignored "$name" "${ignore_configs[@]}"; then
    echo "⏩ Skipping $name"
    continue
  fi
  move_and_link "$dir" "$DOTFILES_DIR/.config/$name"
done

# ------------------------------
# Di chuyển ~/.local/*
# ------------------------------
echo "📦 Moving ~/.local files..."
for dir in "$HOME/.local"/*; do
  name=$(basename "$dir")
  if is_ignored "$name" "${ignore_local[@]}"; then
    echo "⏩ Skipping $name"
    continue
  fi
  move_and_link "$dir" "$DOTFILES_DIR/.local/$name"
done

# ------------------------------
# Di chuyển thêm các config trong manual.txt
# ------------------------------
for extra in "${manual_configs[@]}"; do
  # Hỗ trợ cả .config và .local đường dẫn
  if [[ "$extra" == .config/* ]]; then
    SRC="$HOME/$extra"
    DEST="$DOTFILES_DIR/$extra"
  elif [[ "$extra" == .local/* ]]; then
    SRC="$HOME/$extra"
    DEST="$DOTFILES_DIR/$extra"
  else
    SRC="$HOME/.config/$extra"
    DEST="$DOTFILES_DIR/.config/$extra"
  fi

  if [ -e "$SRC" ]; then
    move_and_link "$SRC" "$DEST"
  else
    echo "❌ $SRC không tồn tại — bỏ qua"
  fi
done

# ------------------------------
# Xử lý đặc biệt cho tmux plugins
# ------------------------------
TMUX_CONFIG_DIR="$HOME/.tmux"
TMUX_PLUGINS_SRC="$TMUX_CONFIG_DIR/plugins"
TMUX_PLUGINS_DEST="$DOTFILES_DIR/.config/tmux/plugins"

if [ -L "$TMUX_PLUGINS_SRC" ]; then
    echo "⚠️  Skipped $TMUX_PLUGINS_SRC (already symlink)"
elif [ -d "$TMUX_PLUGINS_SRC" ]; then
    if [ -e "$TMUX_PLUGINS_DEST" ]; then
        echo "ℹ️  $TMUX_PLUGINS_DEST already exists, backing up"
        mv "$TMUX_PLUGINS_DEST" "$TMUX_PLUGINS_DEST.bak_$(date +%s)"
    fi
    mkdir -p "$(dirname "$TMUX_PLUGINS_DEST")"
    mv "$TMUX_PLUGINS_SRC" "$TMUX_PLUGINS_DEST"
    ln -s "$TMUX_PLUGINS_DEST" "$TMUX_PLUGINS_SRC"
    echo "✅ Linked tmux plugins → $TMUX_PLUGINS_DEST"
else
    echo "ℹ️  No tmux plugins directory to link"
fi

echo "🎉 Done! Dotfiles + .local synced successfully."


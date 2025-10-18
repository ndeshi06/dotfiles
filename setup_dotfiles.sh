#!/bin/bash
# setup_dotfiles.sh — Safe, idempotent, and .config-aware
set -e

DOTFILES_DIR="$HOME/dotfiles"
mkdir -p "$DOTFILES_DIR/.config"

echo "🔧 Moving dotfiles and configs into $DOTFILES_DIR"

# Danh sách file trong $HOME cần quản lý
files=(
  ".bashrc"
  ".zshrc"
  ".oh-my-zsh"
  ".gitconfig"
  ".p10k.zsh"
  ".bash_aliases"
  ".tmux.conf"
)

# Thư mục cấu hình trong ~/.config cần giữ lại
configs=(
  "nvim"
  "kitty"
  "alacritty"
  "i3"
  "hypr"
  "ghostty"
  "starship.toml"
)

# Thư mục nên bỏ qua (cache, app GUI)
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
)

# Hàm check ignore
is_ignored() {
  local name="$1"
  for pat in "${ignore_configs[@]}"; do
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
    ln -s "$dest" "$src"
    echo "✅ Linked $src → $dest"
  fi
}

# Move file và folder trong HOME
for f in "${files[@]}"; do
  move_and_link "$HOME/$f" "$DOTFILES_DIR/$f"
done

# Move các config cụ thể hoặc toàn bộ ~/.config
if [ ${#configs[@]} -gt 0 ]; then
  for c in "${configs[@]}"; do
    SRC="$HOME/.config/$c"
    DEST="$DOTFILES_DIR/.config/$c"
    if [ -e "$SRC" ]; then
      move_and_link "$SRC" "$DEST"
    fi
  done
else
  echo "⚙️ Moving all ~/.config/* except ignored ones..."
  for dir in "$HOME/.config"/*; do
    name=$(basename "$dir")
    if is_ignored "$name"; then
      echo "⏩ Skipping $name"
      continue
    fi
    move_and_link "$dir" "$DOTFILES_DIR/.config/$name"
  done
fi

echo "🎉 Done! All dotfiles are now symlinked from $DOTFILES_DIR"


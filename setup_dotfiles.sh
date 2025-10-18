#!/bin/bash
# setup_dotfiles.sh — safe & idempotent version
set -e

DOTFILES_DIR="$HOME/dotfiles"
mkdir -p "$DOTFILES_DIR/.config"
BACKUP_DIR="$DOTFILES_DIR/.backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "🔧 Moving config files into $DOTFILES_DIR"

# Danh sách an toàn
files=(
  ".bashrc"
  ".zshrc"
  ".oh-my-zsh"
  ".gitconfig"
  ".bash_aliases"
  ".tmux.conf"
)

configs=(
  "nvim"
  "kitty"
  "alacritty"
  "i3"
  "hypr"
  "starship.toml"
)

move_and_link() {
  local src="$1"
  local dest="$2"

  # Nếu đã là symlink, bỏ qua
  if [ -L "$src" ]; then
    echo "⚠️  Skipped $src (already symlink)"
    return
  fi

  # Nếu tồn tại (file hoặc folder)
  if [ -e "$src" ]; then
    echo "📦 Backing up $src → $BACKUP_DIR"
    mv "$src" "$BACKUP_DIR/"
    mv "$BACKUP_DIR/$(basename "$src")" "$dest"
    ln -s "$dest" "$src"
    echo "✅ Moved and linked: $src"
  fi
}

# File + folder trong HOME
for f in "${files[@]}"; do
  move_and_link "$HOME/$f" "$DOTFILES_DIR/$f"
done

# Configs trong ~/.config
for c in "${configs[@]}"; do
  SRC="$HOME/.config/$c"
  DEST="$DOTFILES_DIR/.config/$c"
  move_and_link "$SRC" "$DEST"
done

echo "🎉 Done! All dotfiles are now in $DOTFILES_DIR"
echo "🗃️  Backups (if any) stored in $BACKUP_DIR"


#!/bin/bash
# setup_dotfiles.sh
set -e
DOTFILES_DIR="$HOME/dotfiles"
mkdir -p "$DOTFILES_DIR/.config"

echo "🔧 Moving config files into $DOTFILES_DIR"

# Danh sách an toàn để di chuyển
files=(
  ".bashrc"
  ".zshrc"
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

# Di chuyển file đơn
for file in "${files[@]}"; do
  if [ -f "$HOME/$file" ]; then
    mv "$HOME/$file" "$DOTFILES_DIR/$file"
    ln -s "$DOTFILES_DIR/$file" "$HOME/$file"
    echo "✅ $file moved & linked"
  fi
done

# Di chuyển thư mục .config
for dir in "${configs[@]}"; do
  if [ -d "$HOME/.config/$dir" ]; then
    mv "$HOME/.config/$dir" "$DOTFILES_DIR/.config/"
    ln -s "$DOTFILES_DIR/.config/$dir" "$HOME/.config/$dir"
    echo "✅ $dir config moved & linked"
  fi
done

echo "🎉 Done! All dotfiles are now in $DOTFILES_DIR"


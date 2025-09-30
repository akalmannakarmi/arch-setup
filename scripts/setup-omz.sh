# ===== SETUP OH-MY-ZSH =====
echo "==> Setup oh-my-zsh..."

# Install Oh My Zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "==> Setting zsh as default shell..."
chsh -s "$(which zsh)" "$USER"

# ===== THEMES & PLUGINS =====
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

echo "==> Installing Powerlevel10k theme (cyberpunk prompt)..."
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
fi

echo "==> Installing useful plugins..."
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

# ===== UPDATE ZSH CONFIG =====
ZSHRC="$HOME/.zshrc"

echo "==> Configuring ~/.zshrc..."
sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' $ZSHRC
sed -i 's|^plugins=.*|plugins=(git zsh-autosuggestions zsh-syntax-highlighting)|' $ZSHRC

# Add fastfetch to startup (if not already present)
if ! grep -q "fastfetch" "$ZSHRC"; then
    echo "fastfetch" >> "$ZSHRC"
fi

# Add Powerlevel10k config if not present
if [ ! -f "$HOME/.p10k.zsh" ]; then
    echo "==> Creating basic Powerlevel10k config..."
    cat << 'EOF' > ~/.p10k.zsh
# Minimal cyberpunk Powerlevel10k config
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs time)
typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="╭─"
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="╰→ "
typeset -g POWERLEVEL9K_TIME_FORMAT="%D{%H:%M}"
typeset -g POWERLEVEL9K_COLOR_SCHEME=neon
EOF
    echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> ~/.zshrc
fi

echo "==> Oh My Zsh installed and riced with Powerlevel10k, autosuggestions, syntax highlighting!"

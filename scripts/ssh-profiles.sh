#!/usr/bin/env bash
set -e

SSH_CONFIG="$HOME/.ssh/config"
GIT_CONFIG="$HOME/.gitconfig"

echo " Multi SSH + Git Config Setup"
echo "------------------------------------------"

mkdir -p ~/.ssh
chmod 700 ~/.ssh

read -p "How many accounts do you want to set up? " COUNT

for ((i = 1; i <= COUNT; i++)); do
  echo ""
  echo "Setting up account #$i"
  echo "----------------------------"

  read -p "Account name: " ACCOUNT
  read -p "Git username: " GIT_NAME
  read -p "Git email: " GIT_EMAIL

  KEY_FILE="$HOME/.ssh/id_ed25519_${ACCOUNT}"

  # Generate key if it doesn’t exist
  if [[ ! -f "$KEY_FILE" ]]; then
    echo "🔑 Generating ed25519 key for $ACCOUNT..."
    ssh-keygen -t ed25519 -f "$KEY_FILE" -N ""
  else
    echo "✅ SSH key already exists: $KEY_FILE"
  fi

  # Update SSH config
  if ! grep -q "Host github-${ACCOUNT}" "$SSH_CONFIG" 2>/dev/null; then
    echo "Adding SSH config entry..."
    cat <<EOF >> "$SSH_CONFIG"

# ${ACCOUNT^} Account
Host github-${ACCOUNT}
    HostName github.com
    User git
    IdentityFile $KEY_FILE
EOF
  else
    echo "SSH config for github-${ACCOUNT} already exists."
  fi

  # Ask for directories for this account
  echo ""
  echo "Enter one or more directories for this account (space-separated):"
  echo "(e.g. ~/Work ~/Code)"
  read -p "Directories: " -a DIRS

  # Create per-account gitconfig
  GITCONFIG_FILE="$HOME/.gitconfig-${ACCOUNT}"
  echo "Creating $GITCONFIG_FILE ..."
  cat <<EOF > "$GITCONFIG_FILE"
[user]
    name = $GIT_NAME
    email = $GIT_EMAIL
[core]
    sshCommand = ssh -i $KEY_FILE -F /dev/null
EOF

  # Update main ~/.gitconfig
  for DIR in "${DIRS[@]}"; do
    if ! grep -q "gitdir:${DIR}/" "$GIT_CONFIG" 2>/dev/null; then
      echo "📁 Linking $DIR → $ACCOUNT config"
      cat <<EOF >> "$GIT_CONFIG"

[includeIf "gitdir:${DIR}/"]
    path = ~/.gitconfig-${ACCOUNT}
EOF
    else
      echo "Git include for ${DIR} already exists."
    fi
  done

  echo "Account '$ACCOUNT' configured."
done

echo ""
echo "All done!"
echo "You can now use different Git + SSH identities automatically based on directories."

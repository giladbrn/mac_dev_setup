#!/bin/bash

# Set up logging
LOG_FILE="setup_$(date +%Y%m%d_%H%M%S).log"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

set -e  # Exit on any error
trap 'echo "❌ Error occurred at line $LINENO. Exiting..."; exit 1' ERR

# Get sudo password once at the beginning
echo "🔑 Please enter your password (it will be used for all sudo operations):"
read -s SUDO_PASSWORD
echo

# Ask about macOS update
echo "🔄 Would you like to update macOS? (y/n)"
read -r UPDATE_MACOS
if [[ $UPDATE_MACOS =~ ^[Yy]$ ]]; then
    UPDATE_MACOS=true
else
    UPDATE_MACOS=false
    TOTAL_STEPS=$((TOTAL_STEPS - 1))  # Reduce total steps if skipping update
fi

# Function to run sudo commands
sudo_cmd() {
    echo "$SUDO_PASSWORD" | sudo -S "$@"
}

# Total number of steps
TOTAL_STEPS=17
CURRENT_STEP=0

# Function to print step header
print_step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo "📋 Step $CURRENT_STEP/$TOTAL_STEPS: $1"
}

echo "🚀 Starting macOS Developer Setup..."
echo "📝 Logging output to: $LOG_FILE"

# Ensure system is up to date
if [ "$UPDATE_MACOS" = true ]; then
    print_step "Updating macOS"
    sudo_cmd softwareupdate --all --install --quiet || { echo "❌ macOS update failed"; exit 1; }
    echo "✅ Completed Step $CURRENT_STEP/$TOTAL_STEPS"
fi

# Install Homebrew
print_step "Installing Homebrew"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { echo "❌ Homebrew installation failed"; exit 1; }
  eval "$(/opt/homebrew/bin/brew shellenv)"  # Ensure Brew is in PATH
else
  echo "✅ Homebrew already installed"
fi
echo "✅ Completed Step $CURRENT_STEP/$TOTAL_STEPS"

# Update Homebrew
print_step "Updating Homebrew"
brew update || { echo "❌ Homebrew update failed"; exit 1; }
echo "✅ Completed Step $CURRENT_STEP/$TOTAL_STEPS"

# Install core applications
print_step "Installing core developer tools"
brew install git gh starship fzf bat lazygit gitui vim || { echo "❌ Brew packages installation failed"; exit 1; }
brew install --cask iterm2 raycast warp docker cursor || { echo "❌ Cask applications installation failed"; exit 1; }
echo "✅ Completed Step $CURRENT_STEP/$TOTAL_STEPS"

# Install additional CLI tools
print_step "Installing additional CLI tools"
brew install ripgrep jq yq tldr tree htop ncdu || { echo "❌ Additional CLI tools installation failed"; exit 1; }
echo "✅ Completed Step $CURRENT_STEP/$TOTAL_STEPS"

# Install Git tools
print_step "Installing Git tools"
brew install git-flow || { echo "❌ Git Flow installation failed"; exit 1; }
echo "✅ Completed Step $CURRENT_STEP/$TOTAL_STEPS"

# Install AWS CLI
print_step "Installing AWS CLI"
brew install awscli || { echo "❌ AWS CLI installation failed"; exit 1; }
echo "✅ Completed Step $CURRENT_STEP/$TOTAL_STEPS"

# Install PostgreSQL
print_step "Installing PostgreSQL"
brew install postgresql@14 || { echo "❌ PostgreSQL installation failed"; exit 1; }
brew services start postgresql@14 || { echo "❌ PostgreSQL service start failed"; exit 1; }
echo "✅ Completed Step $CURRENT_STEP/$TOTAL_STEPS"

# Install development applications
print_step "Installing development applications"
brew install --cask postman rectangle || { echo "❌ Development applications installation failed"; exit 1; }
echo "✅ Completed Step $CURRENT_STEP/$TOTAL_STEPS"

# Install Oh My Zsh
print_step "Installing Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || { echo "❌ Oh My Zsh installation failed"; exit 1; }
else
  echo "✅ Oh My Zsh already installed"
fi
echo "✅ Completed Step $CURRENT_STEP/$TOTAL_STEPS"

# Set up Starship prompt
print_step "Configuring Starship"
echo 'eval "$(starship init zsh)"' >>~/.zshrc || { echo "❌ Starship setup failed"; exit 1; }
echo "✅ Completed Step $CURRENT_STEP/$TOTAL_STEPS"

# Install Node.js + nvm
print_step "Installing Node.js & nvm"
brew install nvm || { echo "❌ NVM installation failed"; exit 1; }
mkdir -p ~/.nvm
echo 'export NVM_DIR="$HOME/.nvm"' >>~/.zshrc
echo '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"' >>~/.zshrc
echo '[ -s "/opt/homebrew/opt/nvm/etc/bash_completion" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion"' >>~/.zshrc
echo "✅ Completed Step $CURRENT_STEP/$TOTAL_STEPS"

# Install Python + uv
print_step "Installing Python & uv"
brew install python || { echo "❌ Python installation failed"; exit 1; }
curl -LsSf https://astral.sh/uv/install.sh | sh || { echo "❌ uv installation failed"; exit 1; }
echo "✅ Completed Step $CURRENT_STEP/$TOTAL_STEPS"

# Install Rust
print_step "Installing Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || { echo "❌ Rust installation failed"; exit 1; }
echo "✅ Completed Step $CURRENT_STEP/$TOTAL_STEPS"

# Set up fzf
print_step "Setting up fzf"
$(brew --prefix)/opt/fzf/install --all || { echo "❌ fzf setup failed"; exit 1; }
echo "✅ Completed Step $CURRENT_STEP/$TOTAL_STEPS"

# Set up Git Autocomplete
print_step "Setting up Git Autocomplete"
mkdir -p ~/.zsh/completions
curl -o ~/.zsh/completions/_git https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh || { echo "❌ Git autocomplete download failed"; exit 1; }
chmod +x ~/.zsh/completions/_git
echo "fpath+=~/.zsh/completions" >>~/.zshrc
echo "autoload -Uz compinit && compinit" >>~/.zshrc
echo "✅ Completed Step $CURRENT_STEP/$TOTAL_STEPS"

# Apply changes
print_step "Applying changes"
source ~/.zshrc || { echo "❌ Zsh configuration failed"; exit 1; }
echo "✅ Completed Step $CURRENT_STEP/$TOTAL_STEPS"

echo "🎉 All done! You can now start using your new tools."

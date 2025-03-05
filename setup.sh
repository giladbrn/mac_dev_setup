#!/bin/bash

# Set up logging
LOG_FILE="setup_$(date +%Y%m%d_%H%M%S).log"
STATE_FILE="state.log"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

# Ask about error handling
echo "🛑 How would you like to handle errors during installation?"
echo "1) Stop on any error (recommended)"
echo "2) Continue despite errors"
read -r ERROR_HANDLING
if [[ $ERROR_HANDLING == "1" ]]; then
    set -e  # Exit on any error
    STOP_ON_ERROR=true
else
    set +e  # Don't exit on errors
    STOP_ON_ERROR=false
fi

trap 'echo "❌ Error occurred at line $LINENO."; if [ "$STOP_ON_ERROR" = true ]; then exit 1; else echo "Continuing despite error..."; fi' ERR

# Function to check if a step was completed successfully
is_step_completed() {
    local step=$1
    if [ -f "$STATE_FILE" ] && grep -q "^$step$" "$STATE_FILE"; then
        return 0
    fi
    return 1
}

# Function to mark a step as completed
mark_step_completed() {
    local step=$1
    echo "$step" >> "$STATE_FILE"
}

# Function to ask user about skipping completed steps
ask_about_skipping() {
    if [ -f "$STATE_FILE" ]; then
        echo "📋 Found previous installation state in $STATE_FILE"
        echo "🔄 Would you like to skip steps that were completed successfully? (y/n)"
        read -r SKIP_COMPLETED
        if [[ $SKIP_COMPLETED =~ ^[Yy]$ ]]; then
            SKIP_COMPLETED=true
        else
            SKIP_COMPLETED=false
            # Clear the state file if user doesn't want to skip
            rm -f "$STATE_FILE"
        fi
    else
        SKIP_COMPLETED=false
    fi
}

# Get sudo password once at the beginning
echo "🔑 Please enter your password (it will be used for all sudo operations):"
read -s SUDO_PASSWORD
echo

# Ask about skipping completed steps
ask_about_skipping

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

# Function to check if a brew package is installed
is_brew_package_installed() {
    brew list "$1" &>/dev/null
}

# Function to check if a cask is installed
is_cask_installed() {
    local cask=$1
    if [ -d "/Applications/$cask.app" ]; then
        return 0
    fi
    brew list --cask "$cask" &>/dev/null
}

# Function to handle errors
handle_error() {
    local error_msg=$1
    echo "❌ $error_msg"
    if [ "$STOP_ON_ERROR" = true ]; then
        exit 1
    else
        echo "Continuing despite error..."
        return 1
    fi
}

# Function to install brew package if not already installed
install_brew_package() {
    local package=$1
    local step="brew_package_$package"
    
    if [ "$SKIP_COMPLETED" = true ] && is_step_completed "$step"; then
        echo "⏭️ Skipping $package (already installed)"
        return 0
    fi
    
    if ! is_brew_package_installed "$package"; then
        echo "📦 Installing $package..."
        brew install "$package" || handle_error "Failed to install $package"
        mark_step_completed "$step"
    else
        echo "✅ $package already installed"
        mark_step_completed "$step"
    fi
}

# Function to install cask if not already installed
install_cask() {
    local cask=$1
    local step="cask_$cask"
    
    if [ "$SKIP_COMPLETED" = true ] && is_step_completed "$step"; then
        echo "⏭️ Skipping $cask (already installed)"
        return 0
    fi
    
    if ! is_cask_installed "$cask"; then
        echo "📦 Installing $cask..."
        brew install --cask "$cask" || handle_error "Failed to install $cask"
        mark_step_completed "$step"
    else
        echo "✅ $cask already installed"
        mark_step_completed "$step"
    fi
}

# Total number of steps
TOTAL_STEPS=17
CURRENT_STEP=0

# Function to print step header
print_step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local step_name=$1
    local step_id="step_${CURRENT_STEP}_${step_name// /_}"
    
    if [ "$SKIP_COMPLETED" = true ] && is_step_completed "$step_id"; then
        echo "⏭️ Skipping Step $CURRENT_STEP/$TOTAL_STEPS: $step_name (already completed)"
        return 1
    fi
    
    echo "📋 Step $CURRENT_STEP/$TOTAL_STEPS: $step_name"
}

# Function to complete a step
complete_step() {
    local step_name=$1
    local step_id="step_${CURRENT_STEP}_${step_name// /_}"
    mark_step_completed "$step_id"
    echo "✅ Completed Step $CURRENT_STEP/$TOTAL_STEPS"
}

echo "🚀 Starting macOS Developer Setup..."
echo "📝 Logging output to: $LOG_FILE"

# Ensure system is up to date
if [ "$UPDATE_MACOS" = true ]; then
    if print_step "Updating macOS"; then
        sudo_cmd softwareupdate --all --install --quiet || handle_error "macOS update failed"
        complete_step "Updating macOS"
    fi
fi

# Install Homebrew
if print_step "Installing Homebrew"; then
    if ! command -v brew &>/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || handle_error "Homebrew installation failed"
        eval "$(/opt/homebrew/bin/brew shellenv)"  # Ensure Brew is in PATH
    else
        echo "✅ Homebrew already installed"
    fi
    complete_step "Installing Homebrew"
fi

# Update Homebrew
if print_step "Updating Homebrew"; then
    brew update || handle_error "Homebrew update failed"
    complete_step "Updating Homebrew"
fi

# Install core applications
if print_step "Installing core developer tools"; then
    for package in git gh starship fzf bat lazygit gitui vim; do
        install_brew_package "$package"
    done

    # Install cask applications
    echo "📦 Installing cask applications..."
    for cask in cursor iterm2 raycast warp docker; do
        install_cask "$cask"
    done
    complete_step "Installing core developer tools"
fi

# Install additional CLI tools
if print_step "Installing additional CLI tools"; then
    for package in ripgrep jq yq tldr tree htop ncdu; do
        install_brew_package "$package"
    done
    complete_step "Installing additional CLI tools"
fi

# Install Git tools
if print_step "Installing Git tools"; then
    install_brew_package "git-flow"
    complete_step "Installing Git tools"
fi

# Install AWS CLI
if print_step "Installing AWS CLI"; then
    install_brew_package "awscli"
    complete_step "Installing AWS CLI"
fi

# Install PostgreSQL
if print_step "Installing PostgreSQL"; then
    install_brew_package "postgresql@14"
    brew services start postgresql@14 || handle_error "PostgreSQL service start failed"
    complete_step "Installing PostgreSQL"
fi

# Install development applications
if print_step "Installing development applications"; then
    for cask in postman rectangle; do
        install_cask "$cask"
    done
    
    # Configure Rectangle to start on login and auto-restart
    if [ -d "/Applications/Rectangle.app" ]; then
        echo "⚙️ Configuring Rectangle..."
        # Add to login Items
        osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Rectangle.app", hidden:false}'
        # Enable auto-restart
        defaults write com.knollsoft.Rectangle launchOnLogin -bool true
        defaults write com.knollsoft.Rectangle hideMenuBarIcon -bool false
        echo "✅ Rectangle configured to start on login"
    fi
    
    complete_step "Installing development applications"
fi

# Install Oh My Zsh
if print_step "Installing Oh My Zsh"; then
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || handle_error "Oh My Zsh installation failed"
    else
        echo "✅ Oh My Zsh already installed"
    fi
    complete_step "Installing Oh My Zsh"
fi

# Set up Starship prompt
if print_step "Configuring Starship"; then
    echo 'eval "$(starship init zsh)"' >>~/.zshrc || handle_error "Starship setup failed"
    complete_step "Configuring Starship"
fi

# Install Node.js + nvm
if print_step "Installing Node.js & nvm"; then
    install_brew_package "nvm"
    mkdir -p ~/.nvm
    echo 'export NVM_DIR="$HOME/.nvm"' >>~/.zshrc
    echo '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"' >>~/.zshrc
    echo '[ -s "/opt/homebrew/opt/nvm/etc/bash_completion" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion"' >>~/.zshrc
    complete_step "Installing Node.js & nvm"
fi

# Install Python + uv
if print_step "Installing Python & uv"; then
    install_brew_package "python"
    curl -LsSf https://astral.sh/uv/install.sh | sh || handle_error "uv installation failed"
    complete_step "Installing Python & uv"
fi

# Install Rust
if print_step "Installing Rust"; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || handle_error "Rust installation failed"
    complete_step "Installing Rust"
fi

# Set up fzf
if print_step "Setting up fzf"; then
    $(brew --prefix)/opt/fzf/install --all || handle_error "fzf setup failed"
    complete_step "Setting up fzf"
fi

# Set up Git Autocomplete
if print_step "Setting up Git Autocomplete"; then
    mkdir -p ~/.zsh/completions
    curl -o ~/.zsh/completions/_git https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh || handle_error "Git autocomplete download failed"
    chmod +x ~/.zsh/completions/_git
    echo "fpath+=~/.zsh/completions" >>~/.zshrc
    echo "autoload -Uz compinit && compinit" >>~/.zshrc
    complete_step "Setting up Git Autocomplete"
fi

# Apply changes
if print_step "Applying changes"; then
    echo "🔄 Applying configuration changes..."
    
    # Add Homebrew to PATH if not already there
    if ! grep -q 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.zprofile; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
    
    # Add uv to PATH if not already there
    if ! grep -q 'source $HOME/.local/bin/env' ~/.zshrc; then
        echo '. "$HOME/.local/bin/env"' >> ~/.zshrc
    fi
    
    # Add fzf configuration if not already there
    if ! grep -q 'source ~/.fzf.zsh' ~/.zshrc; then
        echo '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh' >> ~/.zshrc
    fi
    
    # Add Git completions if not already there
    if ! grep -q 'fpath+=~/.zsh/completions' ~/.zshrc; then
        echo 'fpath+=~/.zsh/completions' >> ~/.zshrc
        echo 'autoload -Uz compinit && compinit' >> ~/.zshrc
    fi
    
    echo "✅ Configuration changes applied"
    echo "🔄 Please restart your terminal or run 'source ~/.zshrc' to apply all changes"
    complete_step "Applying changes"
fi

echo "🎉 All done! You can now start using your new tools."

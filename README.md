# 🚀 macOS Developer Setup Script

A one-command setup script to transform your fresh macOS into a developer's paradise. Because life's too short to manually install everything! 

> "Why did the developer go broke? Because he used up all his cache!" 😅

## 🎯 What This Script Does

This script automates the installation of essential developer tools, programming languages, and applications for macOS. It's like having a personal IT department, but without the awkward small talk! 

## 🛠️ Core Developer Tools

### Version Control
- [Git](https://git-scm.com/) - The OG of version control
- [GitHub CLI](https://cli.github.com/) - Because typing `gh` is faster than clicking buttons
- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/) - For those who like their Git workflow as structured as their morning coffee

### Terminal & Shell
- [iTerm2](https://iterm2.com/) - The terminal that makes your terminal jealous
- [Oh My Zsh](https://ohmyz.sh/) - Making your shell prettier than your browser history
- [Starship](https://starship.rs/) - The prompt that makes other prompts feel inadequate
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder that's so good, it's almost cheating

### CLI Utilities
- [ripgrep](https://github.com/BurntSushi/ripgrep) - grep, but it actually found your keys
- [bat](https://github.com/sharkdp/bat) - cat with wings
- [jq](https://stedolan.github.io/jq/) - JSON processor that makes JSON feel less like alphabet soup
- [yq](https://github.com/mikefarah/yq) - jq's YAML cousin
- [tldr](https://tldr.sh/) - Man pages for people who don't have time to read
- [tree](http://mama.indstate.edu/users/ice/tree/) - Directory visualization that's more organized than my life
- [htop](https://htop.dev/) - Process viewer that makes you feel like you're in The Matrix
- [ncdu](https://dev.yorhel.nl/ncdu) - Disk usage analyzer that helps you find what's eating your SSD

### Git UI Tools
- [lazygit](https://github.com/jesseduffield/lazygit) - Git interface for people who can't be bothered to type
- [gitui](https://github.com/extrawurst/gitui) - Another Git UI, because one is never enough

## 💻 Development Applications

### IDEs & Editors
- [Cursor](https://cursor.sh/) - The AI-powered editor that's smarter than your ex
- [Vim](https://www.vim.org/) - The editor that's been around longer than your favorite programming language

### API & Testing
- [Postman](https://www.postman.com/) - Making API testing less painful than debugging production

### System Tools
- [Raycast](https://raycast.com/) - Spotlight on steroids
- [Rectangle](https://rectangleapp.com/) - Window management that actually makes sense (auto-starts on login)
- [Docker](https://www.docker.com/) - Because "it works on my machine" is so last year

## 🗄️ Databases

### SQL Databases
- [PostgreSQL](https://www.postgresql.org/) - The database that's been reliable since before you were born

## ☁️ Cloud Tools

### AWS
- [AWS CLI](https://aws.amazon.com/cli/) - Because clicking buttons in the AWS console is for amateurs

## 🚀 Programming Languages & Tools

### Node.js
- [nvm](https://github.com/nvm-sh/nvm) - Node Version Manager, because one version is never enough

### Python
- [Python](https://www.python.org/) - The language that's as readable as your ex's Instagram
- [uv](https://github.com/astral-sh/uv) - Python package installer that's faster than your coffee machine

### Rust
- [Rust](https://www.rust-lang.org/) - The language that makes C++ look like it was written by a drunk raccoon

## 🎨 Bonus Features

- Automatic logging of all installations
- Error handling that actually tells you what went wrong
- Emoji-based progress indicators (because why not?)
- Automatic service management for databases

## 🚀 Getting Started

1. Clone this repository
2. Make the script executable:
   ```bash
   chmod +x setup.sh
   ```
3. Run the script:
   ```bash
   ./setup.sh
   ```
4. Wait for the magic to happen (and maybe grab a coffee)

## 📝 Notes

- The script requires an active internet connection
- Some installations might require your password
- A log file will be created in the current directory
- You might need to restart your terminal after the installation
- The script modifies your `.zshrc` file to add the following configurations:
  - Starship prompt configuration
  - NVM (Node Version Manager) setup
  - uv package manager PATH configuration
  - fzf fuzzy finder setup
  - Git completions
  - All modifications are safe and check for existing configurations before adding

> "Why do programmers prefer dark mode? Because light attracts bugs!" 🪲

## 🤝 Contributing

Feel free to submit issues and enhancement requests! Just remember, we're all friends here (except for those who use tabs instead of spaces).

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

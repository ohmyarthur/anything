#!/usr/bin/env bash
set -e

# ==============================================================================
#       DEBIAN SETUP SCRIPT
#      Author: Arthur
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
add_to_path() {
    local env_path="$1"
    local shell_rc=""
    
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_rc="$HOME/.zshrc"
    else
        shell_rc="$HOME/.bashrc"
    fi

    if ! grep -q "$env_path" "$shell_rc"; then
        echo -e "\n# Added by Setup Script\nexport PATH=\"\$PATH:$env_path\"" >> "$shell_rc"
        log_success "Added $env_path to $shell_rc"
    else
        log_info "$env_path already exists in $shell_rc"
    fi
}

update_system() {
    log_info "Updating system packages..."
    sudo apt update -y && sudo apt upgrade -y
    log_success "System updated."
}

install_essentials() {
    log_info "Installing essential tools..."
    sudo apt install -y dkms libdw-dev clang lld llvm \
        wget curl ca-certificates gnupg lsb-release \
        git vim nano htop tmux screen \
        net-tools lsof iptables \
        unzip zip tar gzip bzip2 xz-utils \
        jq build-essential gcc g++ make cmake pkg-config \
        autoconf automake libtool gdb ninja-build \
        valgrind strace ltrace \
        libffi-dev libssl-dev libbz2-dev libreadline-dev \
        libsqlite3-dev liblzma-dev zlib1g-dev \
        libncurses5-dev libncursesw5-dev tk-dev uuid-dev \
        libxml2-dev libxslt1-dev libjpeg-dev libpng-dev \
        libfreetype6-dev libwebp-dev \
        libuv1-dev libevent-dev libunwind-dev \
        libcap-dev libseccomp-dev libsystemd-dev
    log_success "Essential tools installed."
}

install_media_tools() {
    log_info "Installing media and utility tools..."
    sudo apt install -y \
        ffmpeg libmediainfo0v5 libglib2.0-0t64 \
        fonts-noto-color-emoji fastfetch \
        imagemagick graphicsmagick \
        sox libsox-fmt-all \
        tesseract-ocr
    log_success "Media tools installed."
}

install_python() {
    log_info "Installing Python environment..."
    sudo apt install -y python3 python3-full python3-dev python3-pip python3-venv \
        python3-wheel python3-setuptools python3-build \
        python3-cffi python3-cryptography python3-numpy \
        python3-openssl python3-msgpack python3-psutil python3-yaml
    curl -LsSf https://astral.sh/uv/install.sh | sh
    log_success "Python and UV installed."
}

install_go() {
    log_info "Fetching latest Go version..."
    LATEST_GO=$(curl -s https://go.dev/dl/?mode=json | jq -r '.[0].version')
    log_info "Installing Go $LATEST_GO..."
    curl -Lo go.tar.gz "https://go.dev/dl/${LATEST_GO}.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go.tar.gz
    rm go.tar.gz
    
    add_to_path "/usr/local/go/bin"
    add_to_path "$HOME/go/bin"
    
    export PATH=$PATH:/usr/local/go/bin
    log_success "Go $LATEST_GO installed."
}

install_rust() {
    log_info "Installing Rust..."
    sudo apt install -y rustc cargo
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    log_success "Rust installed."
}

install_node() {
    log_info "Installing NVM and Node.js..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install 24
    nvm use 24
    npm install -g pm2 pnpm
    log_success "Node.js and PM2 installed."
}

install_docker() {
    log_info "Installing Docker..."
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    
    sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
    log_success "Docker installed (Log out and back in to use without sudo)."
}

install_databases() {
    log_info "Installing Databases (SQLite, PostgreSQL client)..."
    sudo apt install -y sqlite3 postgresql-client
    
    log_info "Installing Redis from official repository..."
    sudo apt-get install -y lsb-release curl gpg
    curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/redis-archive-keyring.gpg
    sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
    sudo apt-get update
    sudo apt-get install -y redis
    sudo systemctl enable redis-server
    sudo systemctl start redis-server
    
    log_success "Databases and Redis installed and started."
}

install_extra_runtimes() {
    log_info "Installing Deno and Bun..."
    curl -fsSL https://deno.land/install.sh | sh
    curl -fsSL https://bun.sh/install | bash
    log_success "Deno and Bun installed."
}

install_monitoring_security() {
    log_info "Installing Monitoring and Security tools..."
    sudo apt install -y nginx iotop iftop nethogs sysstat atop glances \
        fail2ban ufw openssl certbot
    log_success "Monitoring and Security tools installed."
}

install_ytdlp() {
    log_info "Installing yt-dlp..."
    sudo wget -O /usr/local/bin/yt-dlp \
        https://github.com/yt-dlp/yt-dlp-nightly-builds/releases/latest/download/yt-dlp_linux
    sudo chmod +x /usr/local/bin/yt-dlp
    log_success "yt-dlp installed."
}

cleanup() {
    log_info "Cleaning up..."
    sudo apt autoremove -y
    sudo apt autoclean -y
    log_success "Cleanup complete."
}

show_banner() {
    echo -e "${YELLOW}"
    echo "============================================"
    echo "          DEBIAN 13 TRIXIE SETUP"
    echo "                   BY ARTHUR"
    echo "============================================"
    echo -e "${NC}"
}

main_menu() {
    show_banner
    echo "Pilih opsi instalasi:"
    echo "1. Install SEMUANYA (Full Stack)"
    echo "2. Pilih paket secara manual"
    echo "3. Keluar"
    read -p "Masukkan pilihan [1-3]: " main_choice

    case $main_choice in
        1)
            update_system
            install_essentials
            install_media_tools
            install_python
            install_go
            install_rust
            install_node
            install_docker
            install_databases
            install_extra_runtimes
            install_monitoring_security
            install_ytdlp
            cleanup
            ;;
        2)
            echo -e "\nCentang paket yang ingin diinstal (y/n):"
            read -p "Update sistem? [y/N]: " ch_update
            read -p "Install alat esensial (gcc, git, curl, etc)? [y/N]: " ch_ess
            read -p "Install alat media (ffmpeg, imagemagick)? [y/N]: " ch_media
            read -p "Install Python & UV? [y/N]: " ch_py
            read -p "Install Go (Versi terbaru)? [y/N]: " ch_go
            read -p "Install Rust? [y/N]: " ch_rust
            read -p "Install Node.js & PM2? [y/N]: " ch_node
            read -p "Install Docker? [y/N]: " ch_docker
            read -p "Install Databases? [y/N]: " ch_db
            read -p "Install Deno & Bun? [y/N]: " ch_extra
            read -p "Install Monitoring & Security (Nginx, UFW)? [y/N]: " ch_mon
            read -p "Install yt-dlp? [y/N]: " ch_yt

            [[ $ch_update =~ ^[Yy]$ ]] && update_system
            [[ $ch_ess =~ ^[Yy]$ ]] && install_essentials
            [[ $ch_media =~ ^[Yy]$ ]] && install_media_tools
            [[ $ch_py =~ ^[Yy]$ ]] && install_python
            [[ $ch_go =~ ^[Yy]$ ]] && install_go
            [[ $ch_rust =~ ^[Yy]$ ]] && install_rust
            [[ $ch_node =~ ^[Yy]$ ]] && install_node
            [[ $ch_docker =~ ^[Yy]$ ]] && install_docker
            [[ $ch_db =~ ^[Yy]$ ]] && install_databases
            [[ $ch_extra =~ ^[Yy]$ ]] && install_extra_runtimes
            [[ $ch_mon =~ ^[Yy]$ ]] && install_monitoring_security
            [[ $ch_yt =~ ^[Yy]$ ]] && install_ytdlp
            cleanup
            ;;
        3)
            echo "Keluar..."
            exit 0
            ;;
        *)
            log_error "Pilihan tidak valid."
            exit 1
            ;;
    esac

    show_banner
    log_success "SETUP COMPLETE!"
    echo "Silakan jalankan: source ~/.bashrc (atau .zshrc) untuk memuat konfigurasi baru."
    echo "🎉 DORRRRRRRRRRRRRRRRRRR by Arthur!"
    echo "============================================"
}

main_menu

#!/usr/bin/env bash
set -e

# ==============================
#      DEBIAN 13 TRIXIE SETUP
#         ARTHUR STUFF!
# ==============================

echo "Starting Debian 13 Trixie Setup..."

echo "📦 Installing XanMod Kernel..."
wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --dearmor -vo /etc/apt/keyrings/xanmod-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/xanmod-release.list
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y linux-xanmod-lts-x64v3
sudo apt install -y --no-install-recommends dkms libdw-dev clang lld llvm
sudo apt install -y \
    wget curl ca-certificates gnupg lsb-release \
    git vim nano htop tmux screen \
    net-tools lsof iptables \
    apt-utils software-properties-common \
    unzip zip tar gzip bzip2 xz-utils \
    jq
sudo apt install -y \
    ffmpeg \
    libmediainfo0v5 \
    libglib2.0-0t64 \
    fonts-noto-color-emoji \
    fastfetch
sudo apt install -y \
    python3 python3-full python3-dev python3-pip python3-venv \
    python3-wheel python3-setuptools python3-build \
    python3-cffi python3-cryptography python3-numpy \
    python3-openssl python3-msgpack python3-psutil python3-yaml
sudo apt install -y \
    build-essential gcc g++ make cmake pkg-config \
    autoconf automake libtool gdb ninja-build \
    valgrind strace ltrace
sudo apt install -y \
    libffi-dev libssl-dev libbz2-dev libreadline-dev \
    libsqlite3-dev liblzma-dev zlib1g-dev \
    libncurses5-dev libncursesw5-dev tk-dev uuid-dev \
    libxml2-dev libxslt1-dev libjpeg-dev libpng-dev \
    libfreetype6-dev libwebp-dev \
    libuv1-dev libevent-dev libunwind-dev \
    libcap-dev libseccomp-dev libsystemd-dev
sudo apt install -y sqlite3 postgresql-client
sudo apt install -y rustc cargo
sudo apt install -y \
    llvm lld clang clang-tools libclang-dev
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 24
nvm use 24
nvm alias default 24
echo "✅ Node.js version: $(node -v)"
echo "✅ npm version: $(npm -v)"
sudo apt update
sudo apt install -y ca-certificates curl
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
sudo apt install -y \
    docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker $USER

curl -Lo go.tar.gz https://go.dev/dl/go1.23.4.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go.tar.gz
rm go.tar.gz


export PATH=$PATH:/usr/local/go/bin
sudo tee /etc/profile.d/go-path.sh <<EOF
export PATH=\$PATH:/usr/local/go/bin
export GOPATH=\$HOME/go
export PATH=\$PATH:\$GOPATH/bin
EOF

curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

curl -fsSL https://deno.land/install.sh | sh


export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
echo 'export DENO_INSTALL="$HOME/.deno"' >> ~/.bashrc
echo 'export PATH="$DENO_INSTALL/bin:$PATH"' >> ~/.bashrc

curl -fsSL https://bun.sh/install | bash

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
echo 'export BUN_INSTALL="$HOME/.bun"' >> ~/.bashrc
echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> ~/.bashrc

curl -fsSL https://get.pnpm.io/install.sh | sh -

sudo apt install -y nginx

sudo apt install -y redis-server

npm install -g pm2

sudo apt install -y \
    iotop iftop nethogs \
    sysstat atop glances

sudo apt install -y \
    fail2ban ufw \
    openssl certbot

sudo apt install -y \
    imagemagick graphicsmagick \
    sox libsox-fmt-all \
    tesseract-ocr

sudo apt autoremove -y
sudo apt autoclean -y

echo ""
echo "============================================"
echo " SETUP COMPLETE!"
echo "============================================"
echo ""
echo "📦 Installed packages:"
echo "   - XanMod Kernel (Performance)"
echo "   - Python 3.13 + uv"
echo "   - Node.js 24 LTS (NVM)"
echo "   - Docker & Docker Compose"
echo "   - Go 1.23.4"
echo "   - Deno (Modern JS/TS)"
echo "   - Bun (Fast JS Runtime)"
echo "   - pnpm (Fast Package Manager)"
echo "   - Rust & Cargo"
echo "   - Nginx"
echo "   - Redis"
echo "   - PM2"
echo "   - FFmpeg & Media tools"
echo "   - Build tools (GCC, Clang, LLVM)"
echo "   - Security tools (fail2ban, ufw)"
echo ""
echo ""
echo "🎉 DORRRRRRRRRRRRRRRRRRR by Arthur!"
echo "============================================"

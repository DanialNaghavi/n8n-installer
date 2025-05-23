#!/bin/bash



set -e


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  n8n Auto Installation Script  ${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
}


check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        exit 1
    fi
}


get_public_ip() {
    print_status "Getting public IP address..."
    PUBLIC_IP=$(curl -s ifconfig.me || curl -s ipinfo.io/ip || curl -s icanhazip.com)
    if [[ -z "$PUBLIC_IP" ]]; then
        print_error "Could not determine public IP address"
        exit 1
    fi
    print_status "Public IP: $PUBLIC_IP"
}


get_timezone() {
    TIMEZONE=$(timedatectl show --property=Timezone --value)
    print_status "System timezone: $TIMEZONE"
}


get_port() {
    while true; do
        read -p "Enter port for n8n (default: 5678): " PORT
        PORT=${PORT:-5678}
        
        if [[ "$PORT" =~ ^[0-9]+$ ]] && [ "$PORT" -ge 1 ] && [ "$PORT" -le 65535 ]; then
            # Check if port is already in use
            if ss -tuln | grep -q ":$PORT "; then
                print_warning "Port $PORT is already in use. Please choose another port."
                continue
            fi
            print_status "Using port: $PORT"
            break
        else
            print_error "Please enter a valid port number (1-65535)"
        fi
    done
}

update_system() {
    print_status "Updating system packages..."
    apt update -y >/dev/null 2>&1
    apt upgrade -y >/dev/null 2>&1
    print_status "System updated successfully"
}


install_docker() {
    print_status "Installing Docker..."
    

    apt install apt-transport-https ca-certificates curl software-properties-common -y >/dev/null 2>&1
    

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg >/dev/null 2>&1
    

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null
    

    apt update -y >/dev/null 2>&1
    apt install docker-ce docker-ce-cli containerd.io -y >/dev/null 2>&1
    

    systemctl start docker >/dev/null 2>&1
    systemctl enable docker >/dev/null 2>&1
    
    print_status "Docker installed successfully"
}


install_docker_compose() {
    print_status "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >/dev/null 2>&1
    chmod +x /usr/local/bin/docker-compose
    print_status "Docker Compose installed successfully"
}


setup_n8n() {
    print_status "Setting up n8n..."
    

    mkdir -p /opt/n8n-docker
    cd /opt/n8n-docker
    

    cat > docker-compose.yml << EOF
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    restart: always
    ports:
      - "${PORT}:5678"
    environment:
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - WEBHOOK_URL=http://${PUBLIC_IP}:${PORT}/
      - GENERIC_TIMEZONE=${TIMEZONE}
      - N8N_METRICS=true
      - N8N_SECURE_COOKIE=false
    volumes:
      - n8n_data:/home/node/.n8n
    networks:
      - n8n-network

volumes:
  n8n_data:

networks:
  n8n-network:
    driver: bridge
EOF
    
    print_status "n8n configuration created"
}


start_n8n() {
    print_status "Starting n8n..."
    cd /opt/n8n-docker
    docker-compose up -d >/dev/null 2>&1
    print_status "n8n started successfully"
}


check_n8n() {
    print_status "Checking n8n status..."
    

    sleep 10
    

    if docker-compose ps | grep -q "Up"; then
        print_status "n8n container is running"
        

        for i in {1..30}; do
            if curl -s http://localhost:$PORT >/dev/null 2>&1; then
                print_status "n8n is responding on port $PORT"
                return 0
            fi
            sleep 2
        done
        
        print_warning "n8n container is running but not responding. Please check logs with: docker-compose logs -f"
        return 1
    else
        print_error "n8n container failed to start"
        return 1
    fi
}


main() {
    print_header
    
    check_root
    get_public_ip
    get_timezone
    get_port
    
    print_status "Starting installation process..."
    
    update_system
    install_docker
    install_docker_compose
    setup_n8n
    start_n8n
    
    if check_n8n; then
        echo
        echo -e "${GREEN}================================${NC}"
        echo -e "${GREEN}  Installation Complete!        ${NC}"
        echo -e "${GREEN}================================${NC}"
        echo
        echo -e "${BLUE}n8n web interface is available at:${NC}"
        echo -e "${GREEN}http://${PUBLIC_IP}:${PORT}${NC}"
        echo
        echo "Click the link above to open n8n in your browser."
    else
        print_error "Installation completed but n8n is not responding properly"
        echo "You can check the logs with: cd /opt/n8n-docker && docker-compose logs -f"
    fi
}


main

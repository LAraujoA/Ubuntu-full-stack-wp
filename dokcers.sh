#!/usr/bin/env bash
# =====================================================
#  Setup Ubuntu (Azure): Docker + Firewall
#  Adaptado para Ubuntu 24.04 LTS
#  Autor original: Nazarhet
#  Adaptación: Luis Araujo (El Mero Dev ⚙️)
# =====================================================

set -euo pipefail

# --- Colores ---
verde="\e[32m"; azul="\e[34m"; amarillo="\e[33m"; rojo="\e[31m"; reset="\e[0m"

# --- Helper: imprimir paso ---
step() { echo -e "${azul}➤ $*${reset}"; }
ok()   { echo -e "${verde}✔ $*${reset}"; }
warn() { echo -e "${amarillo}⚠ $*${reset}"; }
fail() { echo -e "${rojo}❌ $*${reset}"; }

# ================================
# Comprobar root
# ================================
if [[ $EUID -ne 0 ]]; then
  fail "Debes ejecutar este script como root (usa: sudo -i)."
  exit 1
fi

# ================================
# Actualizar sistema
# ================================
step "Actualizando el sistema…"
apt update -y
apt upgrade -y
ok "Sistema actualizado."

# ================================
# Instalar herramientas básicas
# ================================
step "Instalando utilidades base…"
apt install -y curl wget git unzip zip net-tools htop ufw openssh-server sudo ca-certificates gnupg lsb-release
systemctl enable ssh >/dev/null 2>&1 || true
systemctl start ssh  >/dev/null 2>&1 || true
ok "SSH habilitado."

# ================================
# Instalar Docker
# ================================
step "Instalando Docker…"
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
  systemctl enable docker >/dev/null 2>&1 || true
  systemctl start docker  >/dev/null 2>&1 || true
  ok "Docker instalado."
else
  ok "Docker ya estaba instalado."
fi

# ================================
# Instalar Docker Compose plugin
# ================================
if ! docker compose version >/dev/null 2>&1; then
  step "Instalando Docker Compose plugin…"
  apt install -y docker-compose-plugin || warn "No se pudo instalar docker-compose-plugin. (Opcional)"
else
  ok "Docker Compose ya estaba instalado."
fi

# ================================
# Firewall (UFW)
# ================================
step "Configurando firewall (UFW)…"
ufw allow OpenSSH >/dev/null 2>&1 || true
ufw allow 80/tcp   >/dev/null 2>&1 || true
ufw allow 443/tcp  >/dev/null 2>&1 || true
ufw --force enable >/dev/null 2>&1 || true
ok "Reglas UFW aplicadas."

# ================================
# Estructura de carpetas para web
# ================================
step "Creando estructura de trabajo…"
mkdir -p /home/azureuser/servidor_web/{proyectos,scripts,backups}
chown -R azureuser:azureuser /home/azureuser/servidor_web
ok "Carpetas en /home/azureuser/servidor_web listas."

# ================================
# Mensaje final
# ================================
clear
IP_ACTUAL=$(hostname -I | awk '{print $1}')
ok "Configuración completa, Luis. Misión cumplida. 🚀"
echo -e "${amarillo}📁 Proyectos web: /home/azureuser/servidor_web${reset}"
echo -e "${azul}🌐 Acceso SSH: ssh azureuser@${IP_ACTUAL}${reset}"
echo -e "${azul}By: Nazarhet & Luis Araujo — 'build first, brag later' 💼${reset}"

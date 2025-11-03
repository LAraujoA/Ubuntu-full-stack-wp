#!/usr/bin/env bash
set -e

echo "🧹 Iniciando limpieza total de Docker..."

# === 1️⃣ Detener contenedores y Portainer ===
if command -v docker >/dev/null 2>&1; then
  echo "🧱 Eliminando contenedores y volumenes de Portainer..."
  docker rm -f $(docker ps -aq) 2>/dev/null || true
  docker volume rm portainer_data 2>/dev/null || true
fi

# === 2️⃣ Detener servicios ===
echo "🛑 Deteniendo servicios Docker y Containerd..."
systemctl stop docker.socket 2>/dev/null || true
systemctl stop docker.service 2>/dev/null || true
systemctl stop containerd.service 2>/dev/null || true

# === 3️⃣ Desinstalar Docker y plugins ===
echo "🗑️ Desinstalando Docker y sus componentes..."
apt-get purge -y docker-ce docker-ce-cli containerd.io \
  docker-compose-plugin docker-buildx-plugin || true
apt-get autoremove -y --purge
apt-get autoclean -y

# === 4️⃣ Borrar directorios de datos ===
echo "🧹 Borrando directorios residuales..."
rm -rf /var/lib/docker /var/lib/containerd /etc/docker
rm -f /etc/apt/sources.list.d/docker.list
rm -f /usr/share/keyrings/docker.gpg

# === 5️⃣ Mensaje final ===
echo "✅ Docker y Portainer eliminados completamente del sistema."
echo "💡 Consejo: puedes reinstalar Docker con tu script 'setup-portainer.sh' cuando quieras."

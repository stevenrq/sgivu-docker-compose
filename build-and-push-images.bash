#!/bin/bash

# Carpeta donde están los microservicios
BASE_DIR="/home/steven/Documents/sgivu/code/backend"

# Lista de microservicios y sus tags
declare -A SERVICES
SERVICES=(
  ["sgivu-auth"]="v1"
  ["sgivu-client"]="v1"
  ["sgivu-config"]="v1"
  ["sgivu-discovery"]="v1"
  ["sgivu-gateway"]="v1"
  ["sgivu-user"]="v1"
  ["sgivu-vehicle"]="v1"
  ["sgivu-purchase-sale"]="v1"
  ["sgivu-ml"]="v1"s
)

# Iterar sobre cada microservicio
for SERVICE in "${!SERVICES[@]}"; do
  TAG=${SERVICES[$SERVICE]}
  SERVICE_DIR="$BASE_DIR/$SERVICE"

  echo "=============================="
  echo "Construyendo y subiendo $SERVICE con tag $TAG..."
  echo "Directorio: $SERVICE_DIR"
  
  if [ -d "$SERVICE_DIR" ]; then
    pushd "$SERVICE_DIR" > /dev/null || exit 1

    if [ -x "build-image.bash" ]; then
      echo "Ejecutando build-image.bash para $SERVICE..."
      ./build-image.bash || { echo "build-image.bash falló para $SERVICE"; popd > /dev/null; exit 1; }
      popd > /dev/null
      echo "$SERVICE completado"
      continue
    fi

    # Verifica si es un proyecto de Python
    if [ -f "requirements.txt" ]; then
      echo "Proyecto Python detectado, saltando Maven..."
    else
      echo "Ejecutando Maven..."
      ./mvnw clean package -DskipTests || { echo "Maven failed for $SERVICE"; popd > /dev/null; exit 1; }
    fi

    echo "Construyendo Docker..."
    docker build -t "stevenrq/$SERVICE:$TAG" . || { echo "Docker build failed for $SERVICE"; popd > /dev/null; exit 1; }

    echo "Subiendo Docker..."
    docker push "stevenrq/$SERVICE:$TAG" || { echo "Docker push failed for $SERVICE"; popd > /dev/null; exit 1; }

    popd > /dev/null
    echo "$SERVICE completado"
  else
    echo "Carpeta $SERVICE no existe"
  fi
done

echo "=============================="
echo "Todos los microservicios han sido construidos y subidos."

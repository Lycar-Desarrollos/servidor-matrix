# Servidor Matrix para macOS (Synapse + PostgreSQL + Element Web)

Servidor de chat privado para el equipo, con las imágenes oficiales:

| Servicio | Imagen | Puerto |
|---|---|---|
| Servidor Matrix | `matrixdotorg/synapse` | 8008 |
| Base de datos | `postgres:15-alpine` | interno |
| Cliente web | `vectorim/element-web` | 80 |

Funciona en Macs con Apple Silicon (M1–M4) y con Intel.

## 1. Requisitos

- [Docker Desktop para Mac](https://www.docker.com/products/docker-desktop/), abierto y en ejecución.
- Una IP fija para la Mac (resérvala en el router).

## 2. Instalación (solo la primera vez)

```bash
git clone https://github.com/Lycar-Desarrollos/servidor-matrix.git
cd servidor-matrix
chmod +x *.sh
./setup.sh              # detecta la IP de la Mac
# o: ./setup.sh 192.168.0.50
./iniciar.sh
```

`setup.sh` crea los secretos de forma local (`.env`, `data/`, `element-config.json`). **No los subas a GitHub.**

## 3. Uso diario

```bash
./iniciar.sh    # iniciar
./detener.sh    # detener
```

Docker vuelve a levantar los contenedores solo (`restart: unless-stopped`) cuando Docker Desktop arranca.
Activa *Docker Desktop → Settings → General → Start Docker Desktop when you sign in*.

## 4. Mantener la Mac encendida todo el día

*Ajustes del Sistema → Energía* (o *Batería → Opciones*):
- Evitar el reposo automático con la pantalla apagada.
- Encender automáticamente después de un corte de luz.

Si macOS pregunta si Docker puede aceptar conexiones entrantes, elige **Permitir**.

## 5. Cómo se conecta el equipo

- **Navegador:** `http://IP_DE_LA_MAC`
- **App Element (escritorio):** servidor `http://IP_DE_LA_MAC:8008`
- **Desde fuera de la oficina:** primero se conectan a OpenVPN y luego usan las mismas direcciones.

> Las apps de celular (Android/iOS) pueden rechazar servidores `http://` sin cifrar. Para usarlas en el celular hace falta HTTPS (dominio + certificado o un proxy inverso). Ese será el siguiente paso.

## 6. Respaldo

Haz copia de la carpeta `data/` y de la base de datos:

```bash
docker exec synapse-db pg_dump -U synapse synapse > respaldo.sql
```

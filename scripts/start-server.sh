#!/bin/bash
# Determine target version and download URL
if [ "${SOLIDCRAFT_V}" == "latest" ]; then
  LAT_V="$(wget -qO- https://api.github.com/repos/bherbruck/solidcraft/releases/latest 2>/dev/null | grep tag_name | cut -d '"' -f4)"
  if [ -z "${LAT_V}" ]; then
    echo "---Failed to get latest version from GitHub---"
  fi
else
  echo "---Version manually set to: ${SOLIDCRAFT_V}---"
  LAT_V="v${SOLIDCRAFT_V#v}"
fi

# Check currently installed version
CUR_V="$(find ${DATA_DIR} -maxdepth 1 -type f -name "solidcraft_v*" 2>/dev/null | cut -d '_' -f2)"

if [ -z "${LAT_V}" ]; then
  if [ -z "${CUR_V}" ]; then
    echo "---Can't determine SolidCraft version, putting container into sleep mode!---"
    sleep infinity
  else
    echo "---Can't determine latest SolidCraft version, falling back to installed v${CUR_V}---"
    LAT_V="${CUR_V}"
  fi
fi

# Remove old or failed downloads
rm -f ${DATA_DIR}/solvecraft-web.zip
rm -rf /tmp/solvecraft-web-*

echo "---Version Check---"
if [ -z "${CUR_V}" ]; then
  echo "---SolidCraft not found, downloading and installing ${LAT_V}...---"
  cd ${DATA_DIR}
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/solvecraft-web.zip "https://github.com/bherbruck/solidcraft/releases/download/${LAT_V}/solvecraft-web-${LAT_V#v}.zip" ; then
    echo "---Successfully downloaded SolidCraft ${LAT_V}---"
  else
    echo "---Something went wrong, can't download SolidCraft ${LAT_V}, putting container into sleep mode!---"
    sleep infinity
  fi
elif [ "${CUR_V}" != "${LAT_V}" ]; then
  echo "---Version mismatch, installed v${CUR_V}, downloading latest ${LAT_V}...---"
  rm -rf ${DATA_DIR}/solidcraft_v*
  cd ${DATA_DIR}
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/solvecraft-web.zip "https://github.com/bherbruck/solidcraft/releases/download/${LAT_V}/solvecraft-web-${LAT_V#v}.zip" ; then
    echo "---Successfully downloaded SolidCraft ${LAT_V}---"
  else
    echo "---Something went wrong, can't download SolidCraft ${LAT_V}, putting container into sleep mode!---"
    sleep infinity
  fi
elif [ "${CUR_V}" == "${LAT_V}" ]; then
  echo "---SolidCraft v${CUR_V} up-to-date---"
fi

# Extract archive if present
if [ -f ${DATA_DIR}/solvecraft-web.zip ]; then
  echo "---Installing SolidCraft from archive...---"
  unzip -q ${DATA_DIR}/solvecraft-web.zip -d /tmp
  rm -rf ${DATA_DIR}/www
  mv /tmp/solvecraft-web-* ${DATA_DIR}/www
  rm -f ${DATA_DIR}/solvecraft-web.zip
  touch ${DATA_DIR}/solidcraft_${LAT_V}
  echo "---SolidCraft installed---"
fi

echo "---Prepare Server---"
if [ ! -f "${DATA_DIR}/www/favicon.ico" ]; then
  echo "---No favicon found, copying default...---"
  cp -f /opt/icons/solidcraft.png ${DATA_DIR}/www/favicon.ico
fi
chmod -R ${DATA_PERM} ${DATA_DIR}

echo "---Start Server---"
cd ${DATA_DIR}/www
if [ ! -f "${DATA_DIR}/www/index.html" ]; then
  echo "---Something went wrong, couldn't find the webapp, putting container into sleep mode!---"
  sleep infinity
else
  exec /usr/bin/static-web-server -a 0.0.0.0 -p 8080 -w ${DATA_DIR}/www ${START_PARAMS}
fi

#!/bin/bash
#
# This file is part of the dune-gdt-python-bindings project:
#   https://github.com/ftschindler-work/dune-gdt-python-bindings
# Copyright holders: Felix Schindler
# License: BSD 2-Clause License (http://opensource.org/licenses/BSD-2-Clause)
# Authors:
#   Felix Schindler (2020)

# the dir containing this script is needed for mounting stuff into the container
PROJECTDIR="$(cd "$(dirname ${BASH_SOURCE[0]})" ;  pwd -P )"
CONTAINER=ftschindlerwork/dune-gdt-python-bindings
CID_FILE=/tmp/ftschindlerwork_dune-gdt-python-bindings.cid
PORT="18$(( ( RANDOM % 10 ) ))$(( ( RANDOM % 10 ) ))$(( ( RANDOM % 10 ) ))"

# Start the jupyter notebook server and only mount the notebooks/ subdir if no arguments are given
# The former is done within the container if started without arguments, the latter is achieved here.
if [ "X$@" == "X" ]; then
  SOURCE="${PROJECTDIR}/notebooks"
  TARGET="/data/home/dune-gdt-python-bindings/notebooks"
  EXEC=""
else
  SOURCE="${PROJECTDIR}"
  TARGET="/data/home/dune-gdt-python-bindings"
  EXEC="$@"
fi


if [ -e ${CID_FILE} ]; then

  echo "A docker container for this project is already running. Execute"
  echo "  ./${PROJECTDIR}/docker_exec.sh"
  echo "to connect to it."
  echo
  echo "If you are absolutely certain that there is no running container"
  echo "(check with 'sudo docker ps -a' and stop it otherwise), you may"
  echo "  sudo rm $CID_FILE"
  echo "and try again."

else

  if [[ "$(id -u)" != "1000" || "$(id -g)" != "1000" ]]; then
    echo "WARNING: This docker image assumes the source directory to be writable by the user/group with id 1000/1000!"
    echo "         Changing ownership of ${SOURCE} to 1000:1000..."
    sudo chown -R 1000:1000 "${SOURCE}"
    echo
  fi

  echo "==============================================================================="
  echo "Starting a docker container for this project"
  echo "based on ${CONTAINER} on port ${PORT}. Making"
  echo "  ${SOURCE}"
  echo "available as ${TARGET} within the container"
  echo "(the only place for persistent data)!"
  if [ "X${EXEC}" == "X" ]; then
    echo "Starting the Jupyter-Notebook server, open the printed"
    echo "  URL starting with 127.0.0.1"
    echo "in your favorite browser. You can shutdown the server with"
    echo "  CTRL + C"
    echo "(twice)."
  fi
  echo "==============================================================================="
  echo

  sudo docker run --rm=true --privileged=true -t -i --hostname docker --cidfile=${CID_FILE} \
    -e LOCAL_USER=$USER -e LOCAL_UID=$(id -u) -e LOCAL_GID=$(id -g) \
    -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e QT_X11_NO_MITSHM=1 \
    -e QT_SCALE_FACTOR=${QT_SCALE_FACTOR:-1} \
    -e GDK_DPI_SCALE=${GDK_DPI_SCALE:-1} \
    -e EXPOSED_PORT=$PORT -p 127.0.0.1:$PORT:$PORT \
    -v /etc/localtime:/etc/localtime:ro \
    -v "${SOURCE}":"${TARGET}" \
    ${CONTAINER} "${EXEC}"

  if [[ "$(id -u)" != "1000" || "$(id -g)" != "1000" ]]; then
    echo
    echo "WARNING: This docker image assumes the source directory to be writable by the user/group with id 1000/1000!"
    echo "         Restoring ownership of ${SOURCE} to $(id -u):$(id -g)..."
    sudo chown -R $(id -u):$(id -g) "${SOURCE}"
  fi

  echo
  echo "Removing ${CID_FILE}"
  sudo rm -f ${CID_FILE}

fi

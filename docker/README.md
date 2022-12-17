# 🏄‍♂️ Using Docker

Prerequisites:

- [Docker](https://docs.docker.com/engine/install/)
- [Git](https://git-scm.com/)
- Bash Shell: available in macOS by default and the vast majority of Linux distros

> [basic] run the script that sets the stack up and that's it (takes some minutes to finish):

```bash
cd dataflix
./docker/setup.sh start
```

> [basic] to re-deploy your contracts (container must be up and running):

```bash
./docker/setup.sh deploy
```

> [advanced] running front-end on a different port (eg. 8080):

```bash
DOCKER_IMAGE=$(docker ps --filter name=SCAFFOLD_ETH -q)
[ -z "$DOCKER_IMAGE" ] || docker rm -f SCAFFOLD_ETH

docker run \
  --name SCAFFOLD_ETH \
  -v `pwd`:/opt/dataflix \
  -w /opt/dataflix \
  -e PORT=8080 \
  -p 8080:8080 \
  -p 8545:8545 \
  -dt node:16

./docker/setup.sh start
```

> [advanced] running the container in interactive mode (must run each tool manually):

```bash
DOCKER_IMAGE=$(docker ps --filter name=SCAFFOLD_ETH -q)
[ -z "$DOCKER_IMAGE" ] || docker rm -f SCAFFOLD_ETH

docker run \
  --name SCAFFOLD_ETH \
  -v `pwd`:/opt/dataflix \
  -w /opt/dataflix \
  -p 3000:3000 \
  -p 8545:8545 \
  --entrypoint /bin/bash \
  -ti node:16
```

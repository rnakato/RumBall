# RumBall: Docker image for RNA-seq analysis

## 0. Changelog

See [Changelog](https://github.com/rnakato/RumBall/blob/main/ChangeLog.md)

## 1. Installation

Docker image is available at [DockerHub](https://hub.docker.com/r/rnakato/rumball).

### 1.1 Docker
To use docker command, type:

    docker pull rnakato/rumball
    docker run -it --rm rnakato/rumball <command>

### 1.2 Singularity

Singularity can also be used to execute the docker image:

    singularity build rumball.sif docker://rnakato/rumball
    singularity exec rumball.sif <command>

Singularity mounts the current directory automatically. If you access the files in the other directory, mount it by `--bind` option:

    singularity exec --bind /work rumball.sif <command>

This command mounts `/work` directory.

## 2. Usage

See https://rumball.readthedocs.io for the detailed Manual.


## 3. Build Docker image from Dockerfile

First clone and move to the repository

    git clone https://github.com/rnakato/RumBall.git
    cd RumBall/Dockerfiles

Then type:

    docker build -f Dockerfile.<version> -t <account>/rumball

## 5. Contact

Ryuichiro Nakato: rnakato AT iqb.u-tokyo.ac.jp

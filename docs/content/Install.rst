Installation
================

Docker image (based on Ubuntu 22.04) is available at `DockerHub <https://hub.docker.com/r/rnakato/rumball>`_.

Docker
++++++++++++++

To use the docker command, type:

.. code-block:: bash

    # Pull docker image
    docker pull rnakato/rumball

    # Container login
    docker run --rm -it rnakato/rumball /bin/bash
    # Execute a command
    docker run -it --rm rnakato/rumball <command>

- user:password
    - ubuntu:ubuntu

Singularity
+++++++++++++++++++++++

Singularity is the alternative way to use the docker image.
With this command you can build the singularity file (.sif) of RumBall:

.. code-block:: bash

   # build image
   singularity build rumball.sif docker://rnakato/rumball

Instead, you can download the RumBall singularity image from our `Dropbox <https://www.dropbox.com/scl/fo/lptb68dirr9wcncy77wsv/h?rlkey=whhcaxuvxd1cz4fqoeyzy63bf&dl=0>`_ (We use singularity version 3.8.5).

Then you can run RumBall with the command:

.. code-block:: bash

   singularity exec rumball.sif <command>

Singularity will automatically mount the current directory. If you want to access the files in the other directory, use the ``--bind`` option, for instance:

.. code-block:: bash

   singularity exec --bind /work rumball.sif <command>

This command mounts the ``/work`` directory.
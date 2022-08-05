Installation
================

Docker image is available at `DockerHub <https://hub.docker.com/r/rnakato/rumball>`_.

Docker
++++++++++++++

To use docker command, type:

.. code-block:: bash

   # pull docker image
   docker pull rnakato/rumball
   # execute a command
   docker run -it --rm rnakato/rumball <command>
   
Singularity
+++++++++++++++++++++++

Singularity can also be used to execute the docker image:

.. code-block:: bash

   # build image
   singularity build rumball.sif docker://rnakato/rumball
   # execute a command
   singularity exec rumball.sif <command>

Singularity mounts the current directory automatically. If you access the files in the other directory, 
mount it by ``--bind`` option:

.. code-block:: bash

   singularity exec --bind /work rumball.sif <command>

This command mounts ``/work`` directory.
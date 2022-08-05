Installation
================

Docker image is available at `DockerHub <https://hub.docker.com/r/rnakato/rumball>`_.

**RumBall** internally uses the tools including:

- STAR version 2.7.10a
- RSEM version 1.3.3
- salmon version 1.7.0
- edgeR version 3.38.1
- DESeq2 version 1.36.0
- hisat version 2.2.1
- stringtie version 2.2.1
- ballgown version 2.18.0
- kallisto version 0.46.1
- sleuth version 0.30.0


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
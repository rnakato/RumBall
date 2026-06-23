tag=1.1.0
docker build -f Dockerfile.$tag -t rnakato/rumball:$tag . #--no-cache
apptainer build -F /work3/SingularityImages/rumball.$tag.sif docker-daemon://rnakato/rumball:$tag

#docker save -o rumball-$tag.tar rnakato/rumball:$tag
#singularity build -F /work3/SingularityImages/rumball.$tag.sif docker-archive://rumball-$tag.tar
#exit

#docker push rnakato/rumball:$tag
#docker tag rnakato/rumball:$tag rnakato/rumball:latest
#docker push rnakato/rumball

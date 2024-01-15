tag=0.6.0
docker build -f Dockerfile.$tag -t rnakato/rumball:$tag . #--no-cache
#docker save -o rumball-$tag.tar rnakato/rumball:$tag
#singularity build -F rumball.$tag.sif docker-archive://rumball-$tag.tar
#exit

docker push rnakato/rumball:$tag
docker tag rnakato/rumball:$tag rnakato/rumball:latest
docker push rnakato/rumball

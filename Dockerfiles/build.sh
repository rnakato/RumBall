tag=1.2.1
docker build -f Dockerfile.$tag -t rnakato/rumball:$tag . #--no-cache
apptainer build -F /work3/SingularityImages/rumball.$tag.sif docker-daemon://rnakato/rumball:$tag
exit

docker push rnakato/rumball:$tag
docker tag rnakato/rumball:$tag rnakato/rumball:latest
docker push rnakato/rumball

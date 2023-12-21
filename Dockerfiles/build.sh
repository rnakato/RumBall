tag=0.5.0
docker build -f Dockerfile.$tag -t rnakato/rumball:$tag . #--no-cache
>>>>>>> upstream/main
docker push rnakato/rumball:$tag
docker tag rnakato/rumball:$tag rnakato/rumball:latest
docker push rnakato/rumball

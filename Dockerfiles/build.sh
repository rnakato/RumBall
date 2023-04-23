tag=0.4.2
docker build -f Dockerfile.$tag -t rnakato/rumball:$tag .
docker push rnakato/rumball:$tag
docker tag rnakato/rumball:$tag rnakato/rumball:latest
docker push rnakato/rumball

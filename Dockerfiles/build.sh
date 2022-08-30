for tag in 0.2.0
do
    docker build -f Dockerfile.$tag -t rnakato/rumball:$tag .
    docker push rnakato/rumball:$tag
    docker tag rnakato/rumball:$tag rnakato/rumball:latest
    docker push rnakato/rumball
done

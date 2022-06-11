for tag in latest 0.1.0
do
    docker build -t rnakato/rumball:$tag .
    docker push rnakato/rumball:$tag
done

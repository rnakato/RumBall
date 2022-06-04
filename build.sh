for tag in latest 2022.05
do
    docker build -t rnakato/rumball:$tag .
    docker push rnakato/rumball:$tag
done

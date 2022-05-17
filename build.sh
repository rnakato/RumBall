for tag in latest 2022.05 #2022.04
do
    docker build -t rnakato/rna-seq:$tag .
    docker push rnakato/rna-seq:$tag
done

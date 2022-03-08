for tag in 2022.03 latest
do
    docker build -t rnakato/rna-seq:$tag .
    docker push rnakato/rna-seq:$tag
done

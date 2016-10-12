terraform plan -target=google_compute_subnetwork.default-us-east1 -out ./out/network.out
terraform apply -backup=.\out\network.tfstate.backup -state-out=.\out\network.tfstate  .\out\network.out 
terraform show .\out\network.tfstate
terraform destroy -force -state=.\out\network.tfstate -backup=.\out\network.tfstate.backup
packer validate google.json 
packer build -only googlecompute google.json 

terraform plan -target=google_compute_instance.docker-test-us-east1-b -out ./out/instance.out
terraform apply -target=google_compute_instance.docker-test-us-east1-b -backup=.\out\instance.tfstate.backup -state-out=.\out\instance.tfstate
terraform destroy -force -state=.\out\instance.tfstate -backup=.\out\instance.tfstate.backup

gcloud config set compute/region us-east1
gcloud config set compute/zone us-east1-b
gcloud compute project-info describe
gcloud compute instances  describe docker-test-us-east1-b
gcloud compute instances add-metadata docker-test-us-east1-b --metadata-from-file ssh-keys=.\keys\rootkey.pub
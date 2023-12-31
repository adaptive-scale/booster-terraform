# Terraform for Adaptive Booster

If you wish to setup booster via terraform, you can follow the instructions below.

# Step to create a booster

Download `terraform`. You can follow the link [here](https://developer.hashicorp.com/terraform/downloads)

Clone the repository

```azure
git clone https://github.com/adaptive-scale/booster-terraform.git
cd booster-terraform
```

Please make sure the AWS credentials are set either in location `~/.aws/credentials` or as environment variables.
A credentials files might looks as follows:

```azure
[default]
region = <your-region>
aws_access_key_id=<acess_key>
aws_secret_access_key=<secret_access>
```

Environment variables might look as follows:
`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_REGION` should be set.

Make sure in terraform code, region is appropriately set as well as a corresponding `ami` is set too.
Make sure the key that you are going to use to access this VM exists in your machine too. You would need that later to access the VM and install booster.

Run the following commands:

```azure
terraform init
terraform apply
```

If the terraform scripts run successfully. Do as follows:

```bash
terraform output -json|jq -r .private_key.value > /tmp/keypair.pem
ssh -i  /tmp/keypair.pem ec2-user@$(terraform output -json| jq -r .ec2instance.value)
```

If the image is `ubuntu`, then run:

```bash
terraform output -json|jq -r .private_key.value > /tmp/keypair.pem
ssh -i /tmp/keypair.pem ubuntu@$(terraform output -json| jq -r .ec2instance.value)
```

This should take you the VM, you just created.

Install booster's pre-requisites. On Amazon linux, following are the installation instructions

```bash
sudo yum update -y
sudo yum install -y docker
sudo groupadd docker
sudo usermod -aG docker $USER
sudo yum install -y jq
newgrp docker
sudo service docker start
curl https://cli.adaptive.live/booster/installer.sh | bash && source ~/.profile
adaptive-booster version
# By default, it is us-east-2, but if the region you want to route it via is ap-south-1, use this - `adaptive-booster setup create --region ap-south-1`
adaptive-booster setup create
```

Follow the instructions generated by the CLI. On success, go to the platform for rest of the setup.

If the selected `ami` is debian or ubuntu. Please follow the instructions below:

```bash
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo groupadd docker
sudo usermod -aG docker $USER
sudo apt-get install -y jq
newgrp docker
sudo systemctl start docker
curl https://cli.adaptive.live/booster/installer.sh | bash && source ~/.profile
adaptive-booster version
# By default, it is us-east-2, but if the region you want to route it via is ap-south-1, use this - `adaptive-booster setup create --region ap-south-1`
adaptive-booster setup create
```

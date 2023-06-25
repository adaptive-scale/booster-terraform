# Booster setup from scratch

This repository has a terraform code for creating a VM with booster.

# Step to create a booster

- Download `terraform`. You can follow the link [here](https://developer.hashicorp.com/terraform/downloads)
- Run:
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

Please make sure in terraform code, region is appropriately set as well as a corresponding `ami` is set too.

Please make sure the key that you are going to use to access this VM exists in your machine too. You would need that later to access the VM and install booster.

Run the following commands:

```azure
terraform init 
terraform apply
```

If the terraform scripts run successfully. Do as follows:

```
 ssh -i <location-of-the-key> ec2-user@$(terraform output -json| jq -r .ec2instance.value)
```

This should take you the VM, you just created.

- Install booster's pre-requisites. You Amazon linux, following are the installation instructions
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
adaptive-booster setup create #by default, it is us-east-2, but if the region you want to route it via is ap-south-1, use this - `adaptive-booster setup create --region ap-south-1`
```

Follow the instructions generated by the CLI. On success, go to the platform for rest of the setup. 
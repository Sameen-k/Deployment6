## Purpose 

## System Diagram 

## Steps 

#### Terraform:
There are a total of 3 different main.tf Terraform files. General knowledge of instance contents is essential for understanding what infrastructure each Terraform file is creating. The diagram below shows each main.tf file and what each is responsible for creating:

![Deployment6extra drawio](https://github.com/Sameen-k/Deployment6/assets/128739962/9e9bde7b-2500-46f9-aca7-2f3d30b13e05)


1. The first terraform main.tf file is utilized to create the Jenkins infrastructure which includes 2 EC2 instances. There is a user-data script on that first main.tf file that installs Jenkins on the first instance. When the second instance launched terraform was installed manually. Some pre-existing resources were used to create this infrastructure. Refer to main.tf in the Jenkins Infrastructure folder to see the usage of pre-existing VPC and subnets.

2. Using the terraform which is installed on the third instance, two additional main.tf files were created (main.tf 2 and main.tf 3). As seen in the diagram above, main.tf 2 created the infrastructure in the East region whereas, main.tf 3 created the infrastructure in the West region. Each of these main.tf files (2 & 3) both have a user-data script that is responsible for installing dependencies as well as creating the environment and launching the application within that environment.

#### Keypair configuration:
1. It's important to note that resources vary by region they are created in. This includes the creation of a key-pair. The infrastructure in both the East and West regions requires 1 key-pair each. This is essential since the key-pair must be specified in the instance resource blocks in the terraform files when creating the infrastructure.

_AT THIS POINT CHECK TO MAKE SURE THE INFRASTRUCTURE IS SUCCESSFULLY CREATED_

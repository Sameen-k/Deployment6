## Purpose 
The purpose of this deployment was to create infrastructure with terraform that is redundant (multiple instances) and resilient (in different regions, East and West). This deployment also introduces application load balancers to the infrastructure.

## System Diagram 

![Untitled Diagram drawio (4)](https://github.com/Sameen-k/Deployment6/assets/128739962/739567cb-d62c-431f-bb78-122deba7df22)

## Steps 
#### Terraform:
There are a total of 3 different main.tf Terraform files. General knowledge of instance contents is essential for understanding what infrastructure each Terraform file is creating. The diagram below shows each main.tf file and what each is responsible for creating:

![Deployment6extra drawio](https://github.com/Sameen-k/Deployment6/assets/128739962/9e9bde7b-2500-46f9-aca7-2f3d30b13e05)


1. The first terraform main.tf file is utilized to create the Jenkins infrastructure which includes 2 EC2 instances. There is a user-data script on that first main.tf file that installs Jenkins on the first instance. When the second instance launched terraform was installed manually. Some pre-existing resources were used to create this infrastructure. Refer to main.tf in the Jenkins Infrastructure folder to see the usage of pre-existing VPC and subnets.

2. Using the terraform that is installed on the third instance, two additional main.tf files were created (main.tf 2 and main.tf 3). As seen in the diagram above, main.tf 2 created the infrastructure in the East region whereas, main.tf 3 created the infrastructure in the West region. Each of these main.tf files (2 & 3) both have a user-data script (setup.sh) that is responsible for installing dependencies as well as creating the environment and launching the application within that environment.

#### Keypair configuration:
1. It's important to note that resources vary by region they are created in. This includes the creation of a key-pair. The infrastructure in both the East and West regions requires 1 key-pair each. This is essential since the key-pair must be specified in the instance resource blocks in the terraform files when creating the infrastructure.

_AT THIS POINT CHECK TO MAKE SURE THE INFRASTRUCTURE IS SUCCESSFULLY CREATED_

#### RDS Database configuration:
Now an AWS RDS database can be configured. The purpose of it is so that the 4 SQLite databases on each application instance can connect to each other for shared data. 

1. Navigate to AWS to configure the RDS database. For this deployment, make sure to select MySQL for "Engine Options". Then use the free tier template, create a username and password, allow public access, and disable encryption.

2. After the database is created a default Security Group is also created, so make sure to edit that default Security Group and add the inbound rule to open port 3306 to IPv4 (everyone)

#### Jenkins AWS Credentials and Jenkins Agent Configuration:
In the Terraform main.tf files, AWS credentials are necessary to create infrastructure. In order for Jenkins to use the main.tf files, they must be uploaded to GitHub for this deployment. This means that the main.tf files cannot contain our AWS credentials in order to maintain security. This means we must securely configure AWS access keys in Jenkins. 
1. On the Jenkins interface, under the credentials tab, select "System" and "Global Credentials", and add your AWS credentials for both your access key and secret access key. The keys are saved in Jenkins and the Jenkins file with the names "AWS_ACCESS_KEYS" and "AWS_SECRET_KEYS". Jenkins file also has assigned the keys a variable that must match the terraform file. In this deployment, the keys are saved as variables called "aws_access_key" and "aws_secret_keys". The variables must stay consistent with both the Jenkins file and the main.tf file.
2. This is a good time to also configure the Jenkins agent. This can be done by generating a key manually on the Agent instance and saving it to Jenkins as secret text along with the IP address of the Agent instance. The Jenkins agent is configured through SSH. 

_MAKE SURE TO CHECK THE LOGS TO MAKE SURE THE SSH CONNECTION WAS SUCCESSFUL_

#### Using Git to Push Terraform Files to GitHub 
As stated before, main.tf 1 was used to create the Jenkins infrastructure, main.tf 2 was used to create the East infrastructure and main.tf 3 was used to create the West infrastructure. On the terminal of the Jenkins Agent instance, git commands were used to create a second branch called "WEST". The main branch had main.tf 2 which created the East infrastructure. The branch called "WEST" had a main.tf 3 which created the "WEST" infrastructure. 
1. On the "main" branch, push the variables.tf file, setup.sh, and the main.tf (2) file
2. On the "WEST" branch, push the variables.tf file, setup.sh, the main.tf (3) file
During this process, it's best to keep each main.tf, setup.sh, and the variables.tf file in their own directory. This is so Terraform can know what main.tf to apply as well as make it easier to push to branches using Git commands.

#### Running the Jenkins Pipeline:
Finally, we can create and run a multibranch pipeline in Jenkins. 
When the pipeline runs it will create the infrastructure and and run the setup.sh script on each instance created. This means that once the instance launches the application should be launched as well. 

![Screen Shot 2023-10-28 at 12 18 38 AM](https://github.com/Sameen-k/Deployment6/assets/128739962/0498e208-e27e-4eb8-a67e-3ef060763cde)

_MAKE SURE EACH INSTANCE HAS THE APPLICATION RUNNING_

#### Configuring Load Balancers: 
The last step is to add load balancers to this infrastructure. For this deployment, 2 application load balancers and 4 target groups were configured (1 load balancer and 2 target groups for each region (named: "ALB-east" and "ALB-west")). Each load balancer was placed in a security group called "ALB-HTTP" which had an HTTP port 80 open.

## Optimization
This infrastructure does well with redundancy as there are 4 total application instances in two different regions. Some places of improvement could be to integrate private subnets, particularly for the database as well as a private subnet for the applications with their own security groups for more security 
Additionally, introducing a CDN could help with latency. 

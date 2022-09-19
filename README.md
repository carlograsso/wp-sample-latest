# wp-sample-latest

Infrastruttura per un progetto basato su wordpress in terraform su AWS

Architettura:
- Networking:  1 VPC nella region eu-west-1 con 3 subnet private e 3 pubbliche su 3 Availability Zone.
- Storage: Lo storage è basato su EFS con mount target nelle 3 subnet private
- Database: Mysql Aurora serverlessv2 sulle 3 subnet private con Autoscaling
- Applicativo: 
  - ECS fargate sulle 3 subnet private con Autoscaling (utilizzo cpu)
  - Application loadbalancer sulle subnet pubbliche 

# Per deployare l´infra

1) clonare il repo e spostarsi in wp-sample-latest/terraform
2) loggarsi nella aws cli, esportare la AWS_REGION
3) lanciare lo script init_script.sh che aiuterà nel setup iniziale facendo:
   1) Se non esiste già creerà un bucket per il tfstate
   2) Andrà a sostituire il nome del buchet nel backend.tf
   3) Se non esiste già creerà un secret su ssm con la password del database
4) Inserire la variabile 'ci_cd_source_repo_token = "TOKEN_FORNITO"' nel terraform.tfvars.
5) terraform init
6) terraform apply

note:
- Sarebbe necessario un plugin come https://wordpress.org/plugins/hyperdb/ per sfruttare la scalabilità del database (ora usato solo il reader endpoint)
- Stessa cosa dicasi per un eventual Offload dei file statici su s3 implementabile con apposito plugin di wp

# CI/CD Applicativa

Assieme all´infrastruttura viene deployata una Pipeline CodePipeline e un´application CodeDeploy e un ECR che consentono di buildare il Dockerfile presente nella home della main branch di questo repository e di effettuare un blue/green deployment su ECS.

nota: al primo avvio l´immagine wordpress viene presa dal registry Docker.







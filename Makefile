SHELL := /bin/bash

# check_credentials:
# 	ifndef AWS_ACCESS_KEY_ID
# 		$(error AWS_ACCESS_KEY_ID is not set. Please export your AWS credentials.)
# 	endif
# 	ifndef AWS_SECRET_ACCESS_KEY
# 		$(error AWS_SECRET_ACCESS_KEY is not set. Please export your AWS credentials.)
# 	endif

apply: # check_credentials
	cd terraform; terraform init; terraform apply -auto-approve

destroy: #check_credentials
	cd terraform; terraform init; terraform destroy -auto-approve

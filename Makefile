SHELL := /bin/bash

apply:
	cd terraform; terraform init; terraform apply -auto-approve

destroy:
	cd terraform; terraform init; terraform destroy -auto-approve

GCP_PROJECT_ID=<>
REGION=us-central1
CLUSTER_NAME=mtls-demo

create-cluster:
	gcloud container clusters create-auto $(CLUSTER_NAME) \
		--region $(REGION)

enable-gateway-api:
	gcloud container hub gateway-api enable

gen-certs:
	cd certs && ./generate.sh

deploy:
	kubectl create ns httpbin || true
	kubectl apply -f k8s/app.yaml
	kubectl apply -f k8s/secrets.yaml
	kubectl apply -f k8s/configmap.yaml
	kubectl apply -f k8s/gateway.yaml
	kubectl apply -f k8s/httproute.yaml

test:
	bash scripts/test.sh

destroy:
	gcloud container clusters delete $(CLUSTER_NAME) --region $(REGION) --quiet

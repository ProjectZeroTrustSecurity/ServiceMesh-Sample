PROJECT=calculator
DOCKERREPOSITORY=docker.io/arunimi

#PROXYNODE=localhost:9080
PROXYNODE=35.232.232.2
PROXY=$(PROXYNODE)
UIPROXY=$(PROXYNODE):$(shell kubectl get svc istio-ingressgateway -n istio-system -o json | jq .spec.ports[1].nodePort)

BASICOPADD=$(DOCKERREPOSITORY)/add
BASICOPSUB=$(DOCKERREPOSITORY)/subtract
BASICOPMUL=$(DOCKERREPOSITORY)/multiply
BASICOPDIV=$(DOCKERREPOSITORY)/divide
COMPOSITEOP=$(DOCKERREPOSITORY)/compositeop
PROCESSOR=$(DOCKERREPOSITORY)/processor
UI=$(DOCKERREPOSITORY)/ui

GITHUBREPO=https://github.com/abalasu1/IBM-Private-Cloud.git

FORTIO_POD=$(shell kubectl get pod -n $(PROJECT) -l app=fortio -o jsonpath='{.items[0].metadata.name}')
DEBUG_POD=$(shell kubectl get pod -n $(PROJECT) -l app=curl -o jsonpath='{.items[0].metadata.name}')

init:
	-bash -c 'kubectl create ns $(PROJECT)'
	-bash -c 'kubectl label ns $(PROJECT) istio-injection=enabled'

	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/debug.yaml | kubectl apply -f -
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/fortio-deploy.yaml | kubectl apply -f -		

	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/gateway.yaml  | kubectl apply -f -
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/destinationrules.yaml  | kubectl apply -f -	
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/virtualservice.yaml  | kubectl apply -f -		

	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/mtls.yaml  | kubectl apply -f -

clean:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/gateway.yaml  | kubectl delete -f -
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/destinationrules.yaml  | kubectl delete -f -	
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/virtualservice.yaml  | kubectl delete -f -

	-bash -c 'kubectl delete ns $(PROJECT)'	
	
init-add:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/add-service.yaml  | kubectl apply -f -

deploy-add:
	-sed -e 's~<CONTAINER>~$(BASICOPADD)~g' -e 's~<PROJECT>~$(PROJECT)~g' ./istio/add-deployment.yaml  | kubectl apply -f -

clean-add:
	-kubectl delete all -l app=add

test-add:
	-bash -c 'basicop/add/test.sh $(PROXY)'

init-subtract:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/subtract-service.yaml  | kubectl apply -f -

deploy-subtract:
	-sed -e 's~<CONTAINER>~$(BASICOPSUB)~g' -e 's~<PROJECT>~$(PROJECT)~g' ./istio/subtract-deployment.yaml  | kubectl apply -f -

clean-subtract:
	-kubectl delete all -l app=subtract

test-subtract:
	-bash -c 'basicop/subtract/test.sh $(PROXY)'	

init-multiply:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/multiply-service.yaml  | kubectl apply -f -

deploy-multiply:
	-sed -e 's~<CONTAINER>~$(BASICOPMUL)~g' -e 's~<PROJECT>~$(PROJECT)~g' ./istio/multiply-deployment.yaml  | kubectl apply -f -

clean-multiply:
	-kubectl delete all -l app=multiply

test-multiply:
	-bash -c 'basicop/multiply/test.sh $(PROXY)'	

init-divide:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/divide-service.yaml  | kubectl apply -f -

deploy-divide:
	-sed -e 's~<CONTAINER>~$(BASICOPDIV)~g' -e 's~<PROJECT>~$(PROJECT)~g' ./istio/divide-deployment.yaml  | kubectl apply -f -

clean-divide:
	-oc delete all -l app=divide

test-divide:
	-bash -c 'basicop/divide/test.sh $(PROXY)'	

init-compositeop:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/compositeop-service.yaml  | kubectl apply -f -

deploy-compositeop:
	-sed -e 's~<CONTAINER>~$(COMPOSITEOP)~g' -e 's~<PROJECT>~$(PROJECT)~g' ./istio/compositeop-deployment.yaml  | kubectl apply -f -

clean-compositeop:
	-kubectl delete all -l app=compositeop

test-compositeop:
	-bash -c 'compositeop/test.sh $(PROXY)'	

init-processor:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/processor-service.yaml  | kubectl apply -f -

deploy-processor:
	-sed -e 's~<CONTAINER>~$(PROCESSOR)~g' -e 's~<PROJECT>~$(PROJECT)~g' ./istio/processor-deployment.yaml  | kubectl apply -f -

clean-processor:
	-kubectl delete all -l app=processor

test-processor:
	-bash -c 'processor/test.sh $(PROXY)'	

init-ui:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/ui-service.yaml  | kubectl apply -f -

deploy-ui:
	-sed -e 's~<CONTAINER>~$(UI)~g' -e 's~<PROJECT>~$(PROJECT)~g' ./istio/ui-deployment.yaml  | kubectl apply -f -
	
clean-ui:
	-kubectl delete all -l app=ui	

init-all: init init-add init-subtract init-multiply init-divide init-compositeop init-processor init-ui
build-all: build-add build-subtract build-multiply build-divide build-compositeop build-processor build-ui
push-all: push-add push-subtract push-multiply push-divide push-compositeop push-processor push-ui
deploy-all: deploy-add deploy-subtract deploy-multiply deploy-divide deploy-compositeop	deploy-processor deploy-ui
clean-all: clean-add clean-subtract clean-multiply clean-divide clean-compositeop clean-processor clean-ui clean
test-all: test-add test-subtract test-multiply test-divide test-compositeop test-processor

UI_POD_NAME=$(shell kubectl -n $(PROJECT) get pod -l app=ui -o jsonpath='{.items[0].metadata.name}') 

uiaccess:
	$(shell kubectl -n $(PROJECT) port-forward $(UI_POD_NAME) 9080:80)

initts1:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/ts1/trafficshifting-1.yaml | kubectl apply -f -

testts1:
	-bash -c './istio/ts1/testtrafficshifting-1.sh $(PROXY)'

cleants1:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/ts1/trafficshifting-1.yaml | kubectl delete -f -

initts2:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/ts2/trafficshifting-2.yaml | kubectl apply -f -

testts2:
	-bash -c './istio/ts2/testtrafficshifting-2.sh $(PROXY)'

cleants2:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/ts2/trafficshifting-2.yaml | kubectl delete -f -

initts3:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/ts3/trafficshifting-3.yaml | kubectl apply -f -

testts3:
	-bash -c './istio/ts3/testtrafficshifting-3.sh $(DEBUG_POD) $(PROJECT)'

cleants3:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/ts3/trafficshifting-3.yaml | kubectl delete -f -

initfd:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/fd/fixeddelay.yaml | kubectl apply -f -

testfd:
	-bash -c './processor/test.sh $(PROXY)'

cleanfd:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/fd/fixeddelay.yaml | kubectl delete -f -

initrt:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/rt/requesttimeout.yaml | kubectl apply -f -

testrt:
	-bash -c './istio/rt/testtimeout.sh $(DEBUG_POD) $(PROJECT)'

cleanrt:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/rt/requesttimeout.yaml | kubectl delete -f -

initfi:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/fi/faultinjection.yaml | kubectl apply -f -	

testfi:
	-bash -c './processor/test.sh $(PROXY)'	

cleanfi:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/fi/faultinjection.yaml | kubectl delete -f -

initmirror:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/mirror/trafficmirroring.yaml  | kubectl apply -f -	

testmirror:
	-bash -c './istio/mirror/testmirroring.sh $(PROXY)'	

cleanmirror:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/mirror/trafficmirroring.yaml  | kubectl delete -f -

initcb:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/cb/circuitbreaker.yaml  | kubectl apply -f -	
	
testreqcb:
	-bash -c 'kubectl exec -it $(FORTIO_POD) -n $(PROJECT) -c fortio fortio -- load -curl "http://compositeop:8080/compositeop/eval?expr=5%2B6%2B3%2B4%2B5%2B2%2B3%2B3%2B4%2B2%2B2%2B2%2B2%2B2%2B2-2"'

testreqscb:
	-bash -c 'kubectl exec -it $(FORTIO_POD) -n $(PROJECT) -c fortio fortio -- load -c 200 -qps 100 -n 1000 -loglevel Warning "http://compositeop:8080/compositeop/eval?expr=5%2B6%2B3%2B4%2B5%2B2%2B3%2B3%2B4%2B2%2B2%2B2%2B2%2B2%2B2%2B2%2B5%2B6%2B3%2B4%2B5%2B2%2B3%2B3%2B4%2B2%2B2%2B2%2B2%2B2%2B2%2B2"'
	-bash -c 'kubectl exec -it $(FORTIO_POD) -n $(PROJECT) -c istio-proxy -- sh -c "curl localhost:15000/stats" | grep compositeop | grep pending'

infocb:
	-bash -c 'kubectl exec -it $(FORTIO_POD) -n $(PROJECT) -c istio-proxy  -- sh -c "curl localhost:15000/stats" | grep compositeop | grep pending'

cleancb:	
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/cb/circuitbreaker.yaml  | kubectl delete -f -

initrl:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/rl/ratelimit.yaml | kubectl apply -f -

testrl:
	-bash -c './compositeop/test.sh $(PROXY)'

cleanrl:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/rl/ratelimit.yaml | kubectl delete -f -

initsp:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/sp/securitypolicy.yaml | kubectl apply -f -

testsp:
	-bash -c './processor/test.sh $(PROXY)'

cleansp:
	-sed -e 's~<PROJECT>~$(PROJECT)~g' ./istio/sp/securitypolicy.yaml | kubectl delete -f -
	
JAEGER_POD_NAME=$(shell kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}')
KIALI_POD_NAME=$(shell kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}')
GRAFANA_POD_NAME=$(shell kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}')
PROMETHEUS_POD_NAME=$(shell kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}')

monitor-mesh:
	$(shell kubectl -n istio-system port-forward $(JAEGER_POD_NAME) 16686:16686 & kubectl -n istio-system port-forward $(KIALI_POD_NAME) 20001:20001 & kubectl -n istio-system port-forward $(GRAFANA_POD_NAME) 3000:3000 & kubectl -n istio-system port-forward $(PROMETHEUS_POD_NAME) 9090:9090)
	
restart-all:
	kubectl delete pods --all -n $(PROJECT)

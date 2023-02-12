# Calculator
A simple polyglot microservices application to experiment with and understand features of istio service mesh.
![calculator](https://user-images.githubusercontent.com/70085633/218314458-09456f73-7155-4ec5-b0fd-15505ba56598.png)

## Getting Started
Clone the project or download to your local file system

### Prerequisites
1. A working kubernetes cluster like on google cloud

2. Set up kubectl to point to a valid kubernetes cluster

3. Install istio on the cluster (https://istio.io/docs/setup/kubernetes/)

4. python, node.js, ruby, go compilers are needed to compile locally

### Deployment
To deploy the entire application:

1) "make init-all" command initializes all the services, ingress and other cluster roles needed

2) "make deploy-all" deploys all the services

To deploy the services one by one:

1) "make init-add" and "make deploy-add" to deploy add service.

2) "make init-subtract" and "make deploy-subtract" to deploy subtract service.

3) "make init-multiply" and "make deploy-multiply" to deploy multiply service.

4) "make init-divide" and "make deploy-divide" to deploy divide service.

5) "make init-compositeop" and "make deploy-compositeop" to deploy compositeop service.

6) "make init-processor" and "make deploy-processor" to deploy processor service.

7) "make init-ui" and "make deploy-ui" to deploy ui for the application.

## Versioning of compositeop service:
There are three versions of the compositeop service deployment. It is the same source code deployed thrice with
each one returning version=v1, v2 & v3 respectively. This is used to test traffic shaping and other istion features.

## Running the tests
1) "make test-processor" to test the services end to end

2) Individual services can be tested easily with "make test-add",  "make test-subtract", "make test-multiply", "make test-divide" & "make test-compositeop"

## Cleanup
- "make restart-all" - restart all pods within the calculator application

- "make clean" - Clean up the entire application, namespaces and all services, ingress inside
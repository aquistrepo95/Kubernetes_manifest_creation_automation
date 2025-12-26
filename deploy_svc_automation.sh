#!/bin/bash

# This script will automate the creation of a deployment manifest AND/OR an accompanying service that can be applied to your cluster.
echo "This script will help you create a deployment manifest and optionally a service manifest for your Kubernetes cluster."

# collect user specifications, create and execute the yaml creation command       
echo "Enter deployment name: "
read  deploy_name
        
echo "Enter the container image: " 
read  container_image
 
echo "Enter the container port: "
read  deploy_port

echo "Enter the number of replicas for this deployment: "
read  deploy_replicas

# create the deployment manifest and store the manifest in yaml file
kubectl create deployment $deploy_name --image=$container_image --port=$deploy_port --replicas=$deploy_replicas --dry-run=client -o yaml > "${deploy_name}.yaml" 

# display the deployment manifest
cat "${deploy_name}.yaml"

# apply the deployment manifest to the cluster
echo "Would you like to apply the deployment (y/n) ?"
read apply_now

if [ $apply_now == "y" ]; then
        kubectl apply -f "${deploy_name}.yaml"
        echo "Deployment manifest applied to the cluster."
else
        echo "You can apply the manifest later using 'kubectl apply -f <manifest_file>'."
        exit 0
fi

# prompt user to create a service manifest
echo "Would you like to create a service for this deployment? (y/n)"
read create_svc

# create a service if user agrees else exit 
if [ $create_svc == "y" ]; then
        echo "Enter service type (ClusterIP/NodePort/LoadBalancer): "
        read svc_type
       
        echo "Enter service port: "
        read svc_port 

        kubectl expose deployment $deploy_name --type=$svc_type --port=$svc_port --target-port=$deploy_port --dry-run=client -o yaml > "${deploy_name}_svc.yaml"
else
        echo "Skipping service manifest creation."
        exit 0
fi      

# display the service manifest
cat "${deploy_name}_svc.yaml"

# apply the service manifest to the cluster
echo "Would you like to apply the service (y/n) ?"
read apply_now_svc

if [ $apply_now_svc == "y" ]; then
        kubectl apply -f "${deploy_name}_svc.yaml"
        echo "service manifest applied to the cluster."
else
        echo "You can apply the manifest later using 'kubectl apply -f <manifest_file>'."
        exit 0
fi



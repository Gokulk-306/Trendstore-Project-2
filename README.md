# TrendStore – AWS CI/CD Deployment (Docker, Jenkins, EKS, Prometheus, Grafana)

## 📌 Project Summary
This project demonstrates a complete CI/CD workflow for deploying a containerized web application to AWS EKS using Jenkins, DockerHub, and Kubernetes. The goal was to automate the build → push → deployment process and monitor the application using open-source tools.

---

## ✔️ What I Did

### **1. Dockerization**
- Created a Dockerfile for the TrendStore application.
- Built and tested the Docker image locally.
- Pushed the image to DockerHub:  
  **gokulk306/trendstore-app**

---

### **2. Jenkins Automation (CI/CD Pipeline)**
- Created a Jenkins pipeline that:
  - Pulls source code from GitHub
  - Builds Docker image and tags it
  - Logs in to DockerHub and pushes new image
  - Connects to AWS EKS via kubectl
  - Applies Kubernetes manifests to update the deployment
- Added GitHub Webhook to automatically trigger the pipeline on each push.

---

### **3. Kubernetes on AWS EKS**
- Created an EKS cluster and configured worker nodes.
- Generated deployment and service YAML files.
- Deployment:
  - Nginx container running on port 80
  - 2 replicas
  - Pulls latest DockerHub image
- Service:
  - Type LoadBalancer
  - Exposes the application on **port 3000**
- Verified nodes, pods, deployments, and service LoadBalancer.

---

### **4. Monitoring (Open Source)**
- Installed **kube-prometheus-stack** using Helm, which includes:
  - Prometheus (metrics collection)
  - Grafana (dashboards)
  - Node Exporter
  - Kube State Metrics
- Accessed Prometheus UI through port-forward.
- Accessed Grafana to monitor:
  - Pod CPU & memory
  - Node health
  - Deployment status
  - Cluster performance

---

## 🎯 Final Outcome

- Application successfully containerized and deployed on EKS.
- Fully automated CI/CD pipeline using Jenkins.
- GitHub → Jenkins → DockerHub → EKS → LoadBalancer deployment workflow.
- Monitoring system fully configured using Prometheus & Grafana.
- Application accessible publicly using AWS LoadBalancer DNS.

---

## 🌐 Application LoadBalancer URL
`http://afc12bf3852f143a1b0118f6457df055-2135021047.us-east-2.elb.amazonaws.com:3000/`

This LoadBalancer exposes the Trendstore application publicly from the EKS cluster.

Note : I paused the worker nodes and deleted the LoadBalancer to eliminate EC2 and ELB charges. The control plane remains active to avoid reconfiguring the cluster. I can scale nodes back up and redeploy.

---

## 📸 Screenshots & Evidence

📂 **Screenshots Drive Link:**  
👉 [Click here to view screenshots](https://docs.google.com/document/d/1OZ10wY2BJUhac8w_UX3UkkUmgrmeCYxIN_G5_hqYwv0/edit?usp=sharing)

Screenshots include:
- Docker build & push
- Jenkins pipeline stages
- EKS cluster, nodes, and pods
- LoadBalancer output
- Grafana dashboards
- Application running in browser
- Terraform init, apply 
- Jenkins output console

---
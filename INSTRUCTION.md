# 📝 ToDo App: Advanced Kubernetes Infrastructure

This project demonstrates a production-grade Kubernetes deployment for a Django-based ToDo application with a persistent MySQL backend. It focuses on advanced scheduling techniques, including **Taints/Tolerations**, **Node Affinity**, and **Pod Anti-Affinity** to ensure high availability and resource isolation.

## 🏗️ Architecture Overview

The infrastructure is designed for a multi-node **kind** cluster consisting of one control-plane and three worker nodes.

### 1. MySQL Backend (StatefulSet)

* **Replicas**: 2 pods (as per the "rule of three" for quorum).
* **Isolation**: Hosted on dedicated nodes (`worker2`, `worker3`) using **Taints** (`NoSchedule`) and **Tolerations**.
* **Affinity**:
* **Node Affinity (Required)**: Ensures pods only land on nodes labeled `app=mysql`.
* **Pod Anti-Affinity (Required)**: Ensures each MySQL replica resides on a different physical node to prevent a single point of failure.


* **Storage**: Persistent storage via `volumeClaimTemplates`.

### 2. ToDo Application (Deployment)

* **Affinity**:
* **Node Affinity (Preferred)**: Uses `preferredDuringSchedulingIgnoredDuringExecution` with `weight: 100` to target nodes labeled `app=todoapp`.
* **Pod Anti-Affinity (Required)**: Prevents multiple application pods from running on the same node.


* **Updates**: Managed via `RollingUpdate` strategy.

### 3. Ingress & Networking

* **Controller**: NGINX Ingress Controller.
* **Routing**: Path-based routing with regex capture groups and rewrite annotations to handle sub-paths correctly.

---

## 🚀 Getting Started

### Prerequisites

* [Docker](https://www.docker.com/)
* [kind](https://kind.sigs.k8s.io/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)

### Deployment Steps

1. **Create the Cluster**:
```bash
kind create cluster --config cluster.yml --name todoapp-cluster

```


2. **Run the Bootstrap Script**:
The `bootstrap.sh` script automates labeling, tainting, and deploying all manifests in the correct order.
```bash
chmod +x bootstrap.sh
./bootstrap.sh

```



---

## 🔍 Validation Guide

### 1. Check Node Labels and Taints

Verify that nodes are correctly prepared for scheduling:

```bash
kubectl get nodes -o custom-columns=NAME:.metadata.name,LABELS:.metadata.labels.app,TAINTS:.spec.taints

```

* `worker2` and `worker3` should show the `app=mysql:NoSchedule` taint.

### 2. Verify Pod Distribution

Check the `NODE` column to ensure pods are scheduled according to the affinity rules:

```bash
kubectl get pods -o wide -A

```

* **MySQL pods** should be on `worker2` and `worker3`.
* **ToDo App pods** should be on the `worker` node.

### 3. Test Ingress Access

Once the Ingress Controller is ready, access the app via your browser:

* URL: `http://localhost`
* **Requirement Check**: Open Browser DevTools (F12) -> Network tab. Ensure there are **no 404 errors** for static files (CSS/JS).

---

## 📂 Project Structure

```text
.
├── .infrastructure/
│   ├── app/           # Deployment, PVC, Service, HPA
│   ├── mysql/         # StatefulSet, ConfigMap, Secret, Service
│   └── ingress/       # Ingress rules
├── cluster.yml        # Kind cluster configuration
├── bootstrap.sh       # Automation script
└── README.md          # This file

```

---

## 🧹 Cleanup

To delete the cluster and all resources:

```bash
kind delete cluster --name todoapp-cluster

```

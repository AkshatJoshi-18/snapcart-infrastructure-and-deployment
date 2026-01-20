# AWS High-Availability Architecture Documentation

## Overview
This document outlines the infrastructure architecture designed for high availability (HA), security, and automated self-healing. The system utilizes **Amazon ECS (Elastic Container Service) on EC2** for application hosting and **Amazon DocumentDB** for a managed, MongoDB-compatible database layer.

## High-Level Architecture Diagram
*(Insert Architecture Diagram Here)*

---

## Detailed Component Breakdown

### 1. Networking (Security & Isolation)
The network architecture is designed with a strict security-first approach, utilizing VPC isolation to protect internal resources.

* **VPC (Virtual Private Cloud):** A custom VPC spanning **2 Availability Zones (AZs)** to ensure fault tolerance and high availability.
* **Public Subnets:**
    * Host the **Application Load Balancer (ALB)** and **NAT Gateways**.
    * **Note:** No application code or databases reside in these subnets.
* **Private Subnets (App):**
    * Host **EC2 instances** (running ECS clusters).
    * Instances have **no direct internet access** (0.0.0.0/0). They communicate with the internet solely via NAT Gateways for specific tasks like pulling Docker images or system updates.
* **Private Subnets (Data):**
    * Host the **Amazon DocumentDB** cluster.
    * This is the deepest layer of security; these subnets are accessible *only* from the Private App subnets.

### 2. Compute: Frontend & Backend (Self-Healing & Auto-Scaling)
The application logic runs on Amazon ECS using the EC2 Launch Type, replacing manual Docker management with an orchestrated control plane.

* **Orchestration:**
    * **Amazon ECS** manages the scheduling and placement of frontend and backend containers onto the underlying EC2 instances.
* **Self-Healing (Container Level):**
    * ECS Services define the desired number of tasks (replicas).
    * If a container crashes or fails a health check, the **ECS Service Scheduler** detects the failure and immediately provisions a replacement task to maintain the desired count.
* **Auto-Scaling:**
    * **Application Scaling:** ECS monitors CPU/Memory utilization and scales the *number of containers* out/in based on traffic demand.
    * **Infrastructure Scaling (ASG):** An **Auto Scaling Group (ASG)** monitors the underlying EC2 capacity. If the cluster runs low on resources, the ASG automatically launches new EC2 instances to support the load.

### 3. Database: MongoDB Compatible (Amazon DocumentDB)
The data layer utilizes **Amazon DocumentDB**, a fully managed database service compatible with MongoDB workloads.

* **High Availability:**
    * Deployed as a cluster with a **Primary instance in AZ-1** and a **Replica instance in AZ-2**.
    * In the event of a primary node failure, AWS automatically fails over to the replica with minimal downtime.
* **Security:**
    * The database resides strictly within the **Private Data Subnets**.
    * **AWS Secrets Manager** is used to rotate and store database credentials. Credentials are injected into containers at runtime and are never hard-coded in the source code.

---

## 4. Traffic Flow

1.  **User Entry:** The user accesses the website via a secure HTTPS connection.
2.  **Load Balancing:** The **Application Load Balancer (ALB)** receives the encrypted traffic in the **Public Subnet**.
3.  **Routing:** The ALB routes the traffic to the healthy **Frontend Containers** running on EC2 instances within the **Private App Subnet**.
4.  **Internal Communication:** The Frontend service communicates with the **Backend Containers** (via internal service discovery or an internal Load Balancer).
5.  **Data Access:** The Backend service performs Read/Write operations on the **DocumentDB Cluster** located in the **Private Data Subnet**.# AWS High-Availability Architecture Documentation

## Overview
This document outlines the infrastructure architecture designed for high availability (HA), security, and automated self-healing. The system utilizes **Amazon ECS (Elastic Container Service) on EC2** for application hosting and **Amazon DocumentDB** for a managed, MongoDB-compatible database layer.

## High-Level Architecture Diagram
*(Insert Architecture Diagram Here)*

---

## Detailed Component Breakdown

### 1. Networking (Security & Isolation)
The network architecture is designed with a strict security-first approach, utilizing VPC isolation to protect internal resources.

* **VPC (Virtual Private Cloud):** A custom VPC spanning **2 Availability Zones (AZs)** to ensure fault tolerance and high availability.
* **Public Subnets:**
    * Host the **Application Load Balancer (ALB)** and **NAT Gateways**.
    * **Note:** No application code or databases reside in these subnets.
* **Private Subnets (App):**
    * Host **EC2 instances** (running ECS clusters).
    * Instances have **no direct internet access** (0.0.0.0/0). They communicate with the internet solely via NAT Gateways for specific tasks like pulling Docker images or system updates.
* **Private Subnets (Data):**
    * Host the **Amazon DocumentDB** cluster.
    * This is the deepest layer of security; these subnets are accessible *only* from the Private App subnets.

### 2. Compute: Frontend & Backend (Self-Healing & Auto-Scaling)
The application logic runs on Amazon ECS using the EC2 Launch Type, replacing manual Docker management with an orchestrated control plane.

* **Orchestration:**
    * **Amazon ECS** manages the scheduling and placement of frontend and backend containers onto the underlying EC2 instances.
* **Self-Healing (Container Level):**
    * ECS Services define the desired number of tasks (replicas).
    * If a container crashes or fails a health check, the **ECS Service Scheduler** detects the failure and immediately provisions a replacement task to maintain the desired count.
* **Auto-Scaling:**
    * **Application Scaling:** ECS monitors CPU/Memory utilization and scales the *number of containers* out/in based on traffic demand.
    * **Infrastructure Scaling (ASG):** An **Auto Scaling Group (ASG)** monitors the underlying EC2 capacity. If the cluster runs low on resources, the ASG automatically launches new EC2 instances to support the load.

### 3. Database: MongoDB Compatible (Amazon DocumentDB)
The data layer utilizes **Amazon DocumentDB**, a fully managed database service compatible with MongoDB workloads.

* **High Availability:**
    * Deployed as a cluster with a **Primary instance in AZ-1** and a **Replica instance in AZ-2**.
    * In the event of a primary node failure, AWS automatically fails over to the replica with minimal downtime.
* **Security:**
    * The database resides strictly within the **Private Data Subnets**.
    * **AWS Secrets Manager** is used to rotate and store database credentials. Credentials are injected into containers at runtime and are never hard-coded in the source code.

---

## 4. Traffic Flow

1.  **User Entry:** The user accesses the website via a secure HTTPS connection.
2.  **Load Balancing:** The **Application Load Balancer (ALB)** receives the encrypted traffic in the **Public Subnet**.
3.  **Routing:** The ALB routes the traffic to the healthy **Frontend Containers** running on EC2 instances within the **Private App Subnet**.
4.  **Internal Communication:** The Frontend service communicates with the **Backend Containers** (via internal service discovery or an internal Load Balancer).
5.  **Data Access:** The Backend service performs Read/Write operations on the **DocumentDB Cluster** located in the **Private Data Subnet**
# OpenShift in a Hardened Zero Trust Azure Environment

This article defines and helps you execute a production-ready DevSecOps environment for Government workloads that is seamlessly configured, deployed, and governed on Azure.

## Benefits of the solution
This solution aims to help app developers and security administrators achieve DevSecOps in a few different cutting-edge ways. The benefits of the ecosystem are three-fold: 
* *Accelerated speed of deployment and delivery.* This is the Dev part of DevSecOps – Developers get to focus on writing code and building and delivering application workloads at speed.
* *Advanced security posture.* The Sec part of DevSecOps – Security needs to be at the heart of DoD software development. In our hierarchal Zero Trust solution, each level of the production architecture inherits security from the level below it. This results in a continuously hardened environment from infra all the way up to the workload running on top of it all. We ensure security extends throughout your digital estate
* *Compliant operations.* The Ops part of DevSecOps can be seriously time-consuming. Our entire DevSecOps environment is continuously defensible with 24-hour compliance checks against DoD requirements, which ensures limited or no drift. This greatly reduces operational overhead and allows your team to run their services, 24-7 with confidence

## Components of the solution
Here are the architectural components of the solution.

![Pyramid](./pyramid.PNG)

* *Secure infrastructure*. This layer is secure infrastructure. Developers and security admins need strongly governed components like networking, storage, and monitoring, that abide by the Zero Trust “never trust, always verify” philosophy. When you leverage a Zero Trust model it becomes possible to ensure every request is authenticated, authorized, and inspected before granting access.
* *Container orchestration*. This layer is the container orchestration part of the architecture that deploys and manages Kubernetes nodes. Your compute solution also should be setup and leveraged in a secure way. This is a secure deployment of RedHat OpenShift on Azure. The deployment is unique as it’s (1) fully automated and runs quickly with close to 1-click and (2) has hardening baked-in, including a script that STIGs all host OSes. All of this neatly deploys on top of the Zero Trust Blueprint – inheriting and building on its security and allowing your architecture to remain compliant.
* *Workload*. Lastly, we have the top layer - deploying your application workload! Here you pull a trusted container image from [Iron Bank](https://ironbank.dsop.io), which is the DoD’s central repository for hardened Docker images, and use it to seamlessly deploy a basic web app.

## Deploying the solution
* *Secure infrastructure*. Use the [Zero Trust Blueprint](https://github.com/Azure/ato-toolkit/automation/zero-trust-architecture) to setup strongly governed components like networking, storage, and monitoring that abide by the Zero Trust "never trust, always verify" philosophy on Azure
* *Container orchestration*. Use the [secure OpenShift deployment](https://github.com/Azure/ato-toolkit/automation/openshift/ocp3.11/ocp3.11-on-azure-gov-in-zta.md) to deploy a functional OpenShift 3.11 cluster
* *Workload*. Use the [Iron Bank verification script](xxx) to ensure you're using a secure Docker image 

> [!NOTE]
> For more information on Parts 2 and 3 of solution deployment, e.g. Container Orchestration and Workload, please [contact Microsoft-trusted partner CloudFit](https://www.cloudfitsoftware.com/contact-us/)
> 
> 

For a full end-to-end tutorial of the solution [see demo video here](https://www.youtube.com/watch?v=gntpwbeWbak).

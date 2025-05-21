## **fully detailed Argo CD setup using the OpenShift Console (OCP Web UI)** — this is the Red Hat-recommended method using the **OpenShift GitOps Operator** from OperatorHub.

## This approach integrates Argo CD tightly with OCP and adds useful security and OpenShift-native features.

---

## 🧭 Goal

Deploy **Argo CD** using the **OpenShift Console**, configure it for GitOps workflows, and deploy a sample app.

---

## 🔧 Prerequisites

* OpenShift cluster access (Web Console).
* Cluster admin or user with permissions to install Operators and create namespaces.
* A Git repository (public or private) with manifests or Kustomize/Helm charts.

---

## 📘 Step-by-Step Setup via OpenShift Console

---

### 🔹 Step 1: Install OpenShift GitOps Operator

1. **Log in to OpenShift Web Console**.
2. Go to **Operators → OperatorHub**.
3. Search for **"OpenShift GitOps"**.
4. Click it → **Install**.

   * Select:

     * Installation mode: **All namespaces on the cluster** (default)
     * Installed Namespace: **openshift-operators**
5. Wait for the operator to install (check under **Installed Operators**).

---

### 🔹 Step 2: Create a GitOps Instance (Argo CD)

1. Once the operator is installed, go to:

   * **Operators → Installed Operators**
   * Click **OpenShift GitOps**
2. Click **ArgoCD → Create ArgoCD**.
3. Fill the form:

   * Name: `argocd`
   * Namespace: `argocd` (create a new one)
   * Leave defaults or customize.
4. Click **Create**.

🎉 This creates an Argo CD instance in its own namespace and sets up components (UI, repo server, controller, etc.)

---

### 🔹 Step 3: Access the Argo CD UI

1. Go to **Networking → Routes**
2. Choose **Project: argocd**
3. Look for the route named `argocd-server`
4. Click the URL to open Argo CD UI

---

### 🔹 Step 4: Log in to Argo CD

#### Get Initial Admin Password

1. Open the **Developer Console** or run:

```bash
oc -n argocd get secret argocd-cluster -o jsonpath="{.data.admin\.password}" | base64 -d
```

2. Username: `admin`
3. Paste the password in the UI to log in.

---

### 🔹 Step 5: Create an Application (from UI)

1. Go to the Argo CD UI
2. Click **+ New App**
3. Fill in:

   * Application Name: `nginx-demo`
   * Project: `default`
   * Sync Policy: **Automatic or Manual**
   * Repository URL: `https://github.com/YOUR-ORG/YOUR-REPO`
   * Revision: `HEAD` or tag
   * Path: folder in the repo containing the manifest/kustomize/chart
   * Destination:

     * Cluster URL: [https://kubernetes.default.svc](https://kubernetes.default.svc)
     * Namespace: `default`
4. Click **Create**

---







```
helm create mta-txn-merchant-status

```


```
helm template mta-txn-merchant-status
```

```
helm package mta-txn-merchant-status
```


```
helm registry login registry.preprod.finopaymentbank.in --username admin --password redhat --insecure
```


```
 helm push mta-txn-merchant-status-0.1.1.tgz oci://registry.preprod.finopaymentbank.in/mta --insecure-skip-tls-verify

```



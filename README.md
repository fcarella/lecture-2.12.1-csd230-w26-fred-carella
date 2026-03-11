# Bookstore Admin - JWT & React Integration

## Introduction

This repository contains the starting codebase and in-class exercise for **[Lecture 2.12 CSD230 W26 V3 : Securing the Bookstore (JWT + React Integration)](https://docs.google.com/document/d/1busZdk3_fRobhRXB28Lgzw3ROjyC8ZvVpefSgqOO6tk/edit?usp=sharing)**.

**Please refer to the lecture document linked above for the complete, step-by-step instructions and code modifications required to complete this exercise.**

### What this App Does
The Bookstore Admin application is a full-stack project featuring a Spring Boot REST API backend (connected to a MySQL database) and a React (Vite) frontend. It allows administrators to manage a digital bookstore inventory—including adding, editing, and deleting books and magazines—and simulates a shopping cart experience.

In this exercise, we take the existing unsecured application and lock it down by implementing JSON Web Token (JWT) authentication. We secure the backend API endpoints and build a complete login/logout flow on the React frontend, utilizing React Router v7 and Axios interceptors to ensure that only authenticated users can access the inventory management features.

---

## Running the Application

### Backend (Spring Boot)
1. Ensure your Docker MySQL container is running.
2. Run `Application.java` from your Backend IntelliJ window.
3. The API server will start on `http://localhost:8080`.

### Frontend (React/Vite)
1. Open the terminal in your Frontend IntelliJ window (inside the `frontend` folder).
2. Run the development server:
   ```bash
   npm run dev
   ```
3. Open the provided local URL (usually `http://localhost:5173/`) in your browser to view the application.
```

---

## Running the Application

### **Prerequisites**
Before starting either side of the application, ensure your MySQL database is running via Docker:
```bash
docker-compose up -d
```

---

### **1. Running from the Command Line (CLI)**

#### **Backend (Spring Boot)**
Open a terminal in the **root** folder of the project:
*   **Windows:**
    ```cmd
    mvnw.cmd spring-boot:run
    ```
*   **macOS / Linux:**
    ```bash
    ./mvnw spring-boot:run
    ```

#### **Frontend (React/Vite)**
Open a second terminal window and navigate to the `frontend` folder:
```bash
cd frontend
npm install   # Only needed the first time
npm run dev
```

---

### **2. Running from IntelliJ IDEA**

#### **Backend (Spring Boot)**
1.  Open the **root project folder** in IntelliJ.
2.  In the Project window, navigate to: `src/main/java/csd230/bookstore/Application.java`.
3.  Right-click the `Application` class and select **Run 'Application'**.
4.  Alternatively, open the **Maven** tool window (usually on the right), expand `Application > Plugins > spring-boot`, and double-click `spring-boot:run`.

#### **Frontend (React/Vite)**
1.  Open the **`frontend` sub-folder** in a separate IntelliJ window (as per the dual-window setup).
2.  Open the `package.json` file.
3.  Look for the `"scripts"` section and click the **green Play button** in the gutter next to the `"dev": "vite"` line.
4.  Select **Run 'dev'**.
5.  Check the **Terminal** tab at the bottom of IntelliJ to see the local URL (usually `http://localhost:5173/`).

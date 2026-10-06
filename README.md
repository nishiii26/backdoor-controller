# C-Based Backdoor and Controller – Security Analysis

## 📌 Project Overview

This project demonstrates a basic **TCP-based client-server communication system written in C**.

The project contains two components:

* **Backdoor (`backdoor.c`)** – Acts as a TCP server and waits for a connection from the controller.
* **Controller (`controller.c`)** – Acts as a TCP client and connects to the server.

After a connection is established, the controller can send commands to the server, and the server processes the commands and sends the output back.

> **Note:** This project is created for educational purposes to understand network communication, socket programming, and the security risks associated with remote command execution.

---

## 🎯 Objectives

The main objectives of this project are:

* To understand TCP client-server communication.
* To learn basic socket programming in C.
* To understand how a server accepts incoming connections.
* To understand how a client establishes a TCP connection.
* To study data transmission using `send()` and `recv()`.
* To understand how remote command execution can create security risks.
* To analyze the behavior of a basic backdoor from a cybersecurity perspective.

---

## 🛠️ Technologies Used

* **Programming Language:** C
* **Networking:** TCP/IP
* **Socket API:** Linux/POSIX Sockets
* **Operating System:** Linux / Unix-based systems
* **Compiler:** GCC

---

### `backdoor.c`

The server-side program that:

1. Creates a TCP socket.
2. Binds the socket to a port.
3. Listens for an incoming connection.
4. Accepts a controller connection.
5. Receives commands.
6. Processes the received commands.
7. Sends the resulting output back to the controller.

### `controller.c`

The client-side program that:

1. Creates a TCP socket.
2. Connects to the server.
3. Accepts commands from the user.
4. Sends commands to the server.
5. Receives the response.
6. Displays the output.

---

## 🔄 Working Flow


              CONTROLLER
                   |
                   |
              TCP Connection
                   |
                   ↓
             BACKDOOR/SERVER
                   |
                   ↓
           Receive Command
                   |
                   ↓
            Process Command
                   |
                   ↓
             Send Output
                   |
                   ↓
              CONTROLLER
                   |
                   ↓
             Display Output

---







# Platform Engineer Challenge

## Description
This project is part of a recruitment challenge aimed at creating a Dockerized deployment of a sample web application using Tomcat. The task specifically involves enabling SSL/TLS on Tomcat in an automated way.

## Requirements
- The docker must expose the port 4041
- Tomcat version is 8.5
- The docker base image is centos:7
- No manual commands should be required after the docker run command is executed in order to start and make the Sample App available.
- SSL/TLS is enabled at the 4041 endpoint.

## How it is tested

- 1 -> Clone the Repository
- 2 -> Open the terminal in directory where are the Dockerfile, private key and certificate
- 3 -> Create the Docker image with this command:  
```cmd
docker build -t tomcat-ssl .
```
- 4 -> Run the Docker Conteiner with this command:
```cmd
docker run -d -p 4041:4041 --name tomcat-ssl tomcat-ssl
```
- 5 -> Open browser and access the Sample App: https://localhost:4041/sample

## Secutity and its functionality  

The protocol SSL/TLS is very important for the Secutity in communication between the client (browser) and the server (tomcat). This protocol makes the encryption of the messages between the client and the server.
For using this protocol we have to take a private key and a certificate created from this key.
- **Certificate (server.crt)**: Verify the server's identity. It contains information such as the domain name, the state, the country and the server's public key;
- **Private Key (server.key)**: The private key is generated along with the certificate and must be keep confidential by the server. It allows the server to decrypt messages received from clients.

## OpenSSL
Generated private Key:
```cmd
openssl genpkey -algorithm RSA -out server.key
```
Generated Certificate:
```cmd
openssl req -new -x509 -key server.key -out server.crt
```

## PKCS12
**PKCS12** is a well-known standard for securely storing or transporting a digital certificate, its private key, and optionally, certificate chains. By combining the **certificate** (server.crt) and **private key** (server.key) into a PKCS12 keystore file, we create a reliable and standardized configuration for SSL/TLS in the Dockerized Tomcat environment.
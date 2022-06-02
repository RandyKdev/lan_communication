# LAN ENCRYPTED COMMUNICATION

 - This is a command line application that implements a LAN Connection between devices and permits encrypted communication.

## Required Environment for running the project
- Dart SDK version: 2.17.0 (stable)
- Git version 2.25.1

### After downloading and setting up your environment,
 - Connect the computers you want to test with to thesame Wi-Fi
 - Choose one computer among the devices to act as the server
 - Replace the value of `serverAddress` in lib/global.dart file to the IPv4 address of the server
 - From the root directory of the project, run the project with this command `dart run bin/lan_communication.dart`

## Implemented Features
 - Caesar's Cipher Encryption
 - Public Key Encryption (RSA algorithm)
 - PGP (Pretty Good Privacy) Encryption

## Folder Structure
- lib - Contains all source files
- bin - Contains the entry point of the application

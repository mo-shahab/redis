# README for Client-Server Communication Implementation

## Overview
This project implements a simple client-server communication mechanism using sockets in C. The communication is designed with a clear protocol where the client sends requests to the server, and the server responds. The implementation includes structured message handling with a length-prefixed protocol to ensure correct parsing and handling of data.

### Features
- **Server Implementation**
  - Listens for incoming client connections.
  - Handles client requests in a simple, structured format.
  - Sends responses back to the client based on the requests.
- **Client Implementation**
  - Establishes a connection to the server.
  - Sends multiple requests to the server.
  - Reads and processes responses from the server.

---

## Server Implementation
### Key Components

1. **Socket Setup**
   - Creates a listening socket using `socket()`.
   - Binds the socket to a specific IP and port using `bind()`.
   - Listens for incoming connections using `listen()`.

2. **Accepting Connections**
   - Accepts client connections in a loop using `accept()`.
   - Each client is handled iteratively (no multi-threading for simplicity).

3. **Request Handling**
   - Reads messages from the client.
   - Messages are expected to be prefixed with a 4-byte length header.
   - Processes the message and sends an appropriate response.

4. **Protocol Handling**
   - Reads the length header to determine the size of the incoming message.
   - Reads the message body and processes it.
   - Prepares and sends a response back to the client, also prefixed with a length header.

### Example Workflow
1. A client connects to the server.
2. The server reads a 4-byte length header to determine the size of the incoming request.
3. The server reads the request body based on the size.
4. The server processes the request and sends a response prefixed with a 4-byte length header.

### Key Functions
- `read_full()`: Ensures that the entire request or response is read.
- `write_full()`: Ensures that the entire response is sent.
- `handle_request()`: Processes the incoming request and prepares a response.

---

## Client Implementation
### Key Components

1. **Socket Setup**
   - Creates a client socket using `socket()`.
   - Connects to the server using `connect()`.

2. **Request Sending**
   - Sends a request to the server with a 4-byte length header followed by the request body.

3. **Response Handling**
   - Reads the response length header (4 bytes).
   - Reads the response body based on the length.
   - Ensures the response is null-terminated for safe string handling.

### Example Workflow
1. The client establishes a connection to the server.
2. The client sends a message prefixed with a 4-byte length header.
3. The client reads the 4-byte response length header from the server.
4. The client reads the response body and prints it.
5. The client sends additional requests or terminates the connection.

### Key Functions
- `read_full()`: Ensures the entire server response is read.
- `write_full()`: Ensures the entire client request is sent.
- `query()`: Handles the complete cycle of sending a request and reading the response.

---

## Communication Protocol
The communication protocol is designed as follows:

1. **Message Format (Client to Server)**
   - **Length Header (4 bytes)**: Indicates the size of the message body.
   - **Message Body (variable)**: The actual content of the message.

2. **Message Format (Server to Client)**
   - **Length Header (4 bytes)**: Indicates the size of the response body.
   - **Response Body (variable)**: The actual response content.

### Example Request
- Request Body: `"hello1"` (6 bytes)
- Sent Data: `[0x00 0x00 0x00 0x06] ["hello1"]`

### Example Response
- Response Body: `"world"` (5 bytes)
- Sent Data: `[0x00 0x00 0x00 0x05] ["world"]`

---

## Detailed Breakdown of `query()` Function
The `query()` function in the client handles the entire request-response cycle. Here's how it works:

1. **Prepare the Request**
   - Calculate the length of the request body using `strlen()`.
   - Ensure the request size does not exceed the maximum allowed size.
   - Construct the request:
     - Copy the length header into the first 4 bytes.
     - Copy the message body after the length header.

2. **Send the Request**
   - Use `write_full()` to send the complete request (length header + body).

3. **Read the Response**
   - Read the 4-byte response length header to determine the size of the response body.
   - Read the response body based on the length.

4. **Null-Terminate the Response**
   - Ensure the response is null-terminated to treat it as a string.

5. **Print the Response**
   - Print the server's response, starting at `&rbuf[4]` to skip the length header.

---

## Running the Project
### Server
1. Compile the server code:
   ```sh
    g++ -Wall -Wextra -O2 -g server.cpp -o server
    ```
2. Run the server:
   ```sh
   ./server
   ```

### Client
1. Compile the client code:
   ```sh
    g++ -Wall -Wextra -O2 -g client.cpp -o client
   ```
2. Run the client:
   ```sh
   ./client
   ```

---

## Notes
- The server and client use a loopback address (`127.0.0.1`) for communication.
- The protocol is designed for simplicity and assumes little-endian byte ordering.
- Error handling is minimal; production systems should handle edge cases more robustly.

Let me know if further details are needed!



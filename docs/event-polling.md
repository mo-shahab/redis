Here's an updated version of the documentation that integrates parts of your provided code for better clarity and explanation of core functions.

---

# Detailed Documentation: Event Poll Mechanism and Client-Server Interaction

## **Overview**
This document explains how the server implements an event poll mechanism to handle I/O events and processes messages, and how the client sends and receives messages. Key parts of the code are referenced to clarify the concepts.

---

## **Server: Event Poll Mechanism**

The server uses an event-polling mechanism, often implemented with `epoll` or `select`, to manage multiple I/O connections. While the exact server code isn't provided, the typical workflow is inferred based on standard practices.

### **Core Steps**

1. **Socket Creation and Binding**
   - The server creates a listening socket (`socket`) and binds it to an address and port.
   - Example (implied code):
     ```c
     int server_fd = socket(AF_INET, SOCK_STREAM, 0);
     bind(server_fd, ...);
     listen(server_fd, SOMAXCONN);
     ```

2. **Event Loop Initialization**
   - The server initializes an event-polling structure (e.g., `epoll_create` in Linux).
     - Incoming connections and existing connections are monitored for events like readability (`EPOLLIN`) or writability (`EPOLLOUT`).

3. **Handling Events**
   - When a new event is detected (e.g., data is ready to be read from a client socket), the server calls appropriate handler functions.
   - For each connection, the server processes as much data as available in non-blocking mode and keeps track of partially processed requests.

---

### **Message Processing**
When the server reads a message, it follows these steps:

1. **Header Handling**
   - The server first reads a fixed-length header (e.g., 4 bytes) to determine the message size.
   - This is done in `read_full`:
     ```c
     static int32_t read_full(int fd, uint8_t *buf, size_t n) {
         while (n > 0) {
             ssize_t rv = read(fd, buf, n);
             if (rv <= 0) {
                 return -1;  // error or EOF
             }
             n -= (size_t)rv;
             buf += rv;
         }
         return 0;
     }
     ```
     - This ensures the entire header is read before proceeding.

2. **Body Handling**
   - Once the header is processed, the server reads the message body using the same `read_full` function.
   - The server may process the message incrementally if it cannot read the entire body in one go.

3. **Message Processing Logic**
   - The server performs application-specific processing, such as logging or replying.

4. **Non-blocking Mode**
   - If the message is large, the server processes it in parts, allowing other connections to proceed. The server avoids blocking by using `read` in small chunks as data becomes available.

---

## **Client: Sending and Receiving Messages**

The client program you provided implements the following core functionality:

### **Core Functions in the Client**

#### **1. Message Sending (`send_req`)**
This function sends a message to the server, starting with the 4-byte header indicating the message length, followed by the actual message body.

```c
static int32_t send_req(int fd, const uint8_t *text, size_t len) {
    if (len > k_max_msg) {
        return -1;
    }

    std::vector<uint8_t> wbuf;
    buf_append(wbuf, (const uint8_t *)&len, 4);  // Add header
    buf_append(wbuf, text, len);                // Add message body
    return write_all(fd, wbuf.data(), wbuf.size());
}
```

- **Key Points**:
  - A length-prefixed protocol is used.
  - `write_all` ensures the entire message is sent:
    ```c
    static int32_t write_all(int fd, const uint8_t *buf, size_t n) {
        while (n > 0) {
            ssize_t rv = write(fd, buf, n);
            if (rv <= 0) {
                return -1;  // error
            }
            n -= (size_t)rv;
            buf += rv;
        }
        return 0;
    }
    ```

#### **2. Message Reading (`read_res`)**
This function reads a response from the server, starting with a 4-byte header (message length), followed by the actual message body.

```c
static int32_t read_res(int fd) {
    // Read header
    std::vector<uint8_t> rbuf(4);
    int32_t err = read_full(fd, rbuf.data(), 4);
    if (err) {
        return err;
    }

    uint32_t len;
    memcpy(&len, rbuf.data(), 4);  // Little-endian

    if (len > k_max_msg) {
        return -1;  // Message too long
    }

    // Read body
    rbuf.resize(4 + len);
    err = read_full(fd, &rbuf[4], len);
    if (err) {
        return err;
    }

    printf("len:%u data:%.*s\n", len, len < 100 ? len : 100, &rbuf[4]);
    return 0;
}
```

- **Key Points**:
  - Similar to the server, the client processes the message in parts.
  - If a large message is received, the function ensures it reads in chunks until complete.

---

## **Interaction: A Story Perspective**

1. **Client Sends Requests**
   - The client prepares a list of requests (e.g., `"hello1"`, `"hello2"`, large message, etc.):
     ```c
     std::vector<std::string> query_list = {
         "hello1", "hello2", "hello3", std::string(k_max_msg, 'z'), "hello5"
     };
     ```
   - For each request, the client calls `send_req`.

2. **Server Receives Requests**
   - The server, using its event loop, detects incoming data.
   - It reads the header and body, processing each request incrementally.

3. **Server Sends Responses**
   - After processing, the server sends back a response using its non-blocking write mechanism.

4. **Client Reads Responses**
   - The client processes the server’s responses using `read_res`.

---

## **How Large Messages are Handled**
- The client and server break large messages into smaller chunks during transmission.
- Both use fixed-size buffers and read/write loops to ensure complete data transfer.
- The server processes partial data without blocking, ensuring responsiveness.

---

## **Conclusion**
This client-server implementation uses efficient event-driven techniques to handle I/O, with clear separation of concerns for reading, writing, and message handling. Both the client and server utilize fixed-length headers to manage message boundaries and support large, incremental data transfers.

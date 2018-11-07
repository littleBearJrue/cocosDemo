
#include "VxSocket.h"
#include "VxConst.h"

VxSocket::VxSocket(SOCKET sock)
{
	m_sock = sock;
}

VxSocket::~VxSocket()
{
	if(INVALID_SOCKET != m_sock)
	{
		this->close();
	}
}

bool VxSocket::create(int af, int type, int protocol)
{
	m_sock = socket(af, type, protocol);
	if (m_sock == INVALID_SOCKET)
	{
		return false;
	}
	return true;
}

bool VxSocket::bind(unsigned short port)
{
	struct sockaddr_in svraddr;
	svraddr.sin_family = AF_INET;
	svraddr.sin_addr.s_addr = INADDR_ANY;
	svraddr.sin_port = htons(port);
	int opt =  1;
	if(setsockopt(m_sock, SOL_SOCKET, SO_REUSEADDR, (char*)&opt, sizeof(opt)) < 0)
	{
		return false;
	}

	int ret = ::bind(m_sock, (struct sockaddr*)&svraddr, sizeof(svraddr));   
	if(ret == SOCKET_ERROR)
	{
		return false;
	}

	return true;
}

bool VxSocket::listen(int backlog)
{
	int ret = ::listen(m_sock, backlog);
	if (ret == SOCKET_ERROR)
	{
		return false;
	}
	return true;
}

bool VxSocket::accept(VxSocket& s, char* fromip)
{
	struct sockaddr_in cliaddr;
	socklen_t addrlen = sizeof(cliaddr);
	SOCKET sock = ::accept(m_sock, (struct sockaddr*)&cliaddr, &addrlen);

	if(sock == SOCKET_ERROR)
	{
		return false;
	}

	s = sock;
	if(fromip != NULL)
	{
		sprintf(fromip, "%s", inet_ntoa(cliaddr.sin_addr));
	}

	return true;
}

bool VxSocket::connect(const char* ip, unsigned short port)
{
	struct sockaddr_in svraddr; 
	svraddr.sin_family = AF_INET;
	svraddr.sin_addr.s_addr = inet_addr(ip);
	svraddr.sin_port = htons(port);

	int ret = ::connect(m_sock, (struct sockaddr*)&svraddr, sizeof(svraddr));

	if (ret == SOCKET_ERROR)
	{
		return false;
	}

	return true;
}

int VxSocket::send(const char* buf, int len, int flags)
{
	int bytes;
	int count = 0;
	while (count < len)
	{
		bytes = ::send(m_sock, buf + count, len - count, flags);

		if (bytes == -1 || bytes == 0)
		{
			return -1;
		}
		count += bytes;
	}
	return count;
}

int VxSocket::recv(char* buf, int len, int flags)
{
	return (::recv(m_sock, buf, len, flags));
}

int VxSocket::close()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	return (::closesocket(m_sock));
#else
	::shutdown(m_sock, SHUT_RDWR);
	return (::close(m_sock));
#endif
}

int VxSocket::getError()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	return (WSAGetLastError());
#else
	return (errno);
#endif
}

VxSocket& VxSocket::operator = (SOCKET sock)
{
	m_sock = sock;
	return (*this);
}

SOCKET VxSocket::handle()
{
	return m_sock;
}

int VxSocket::init()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	WSADATA wsaData;
	//#define MAKEWORD(a,b) ((WORD) (((BYTE) (a)) | ((WORD) ((BYTE) (b))) << 8))    
	WORD version = MAKEWORD(2, 0);
	//win sock start up
	int ret = WSAStartup(version, &wsaData);
	if (ret)
	{
		VXLOG("Initilize winsock error !");
		return VXERR_FAILED;
	}
#endif
	return VXERR_SUCCESS;
}

int VxSocket::clean()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	return (WSACleanup());
#endif
	return 0;
}

bool VxSocket::parseDns(const char* domain, char* ip)
{
	struct hostent* p;
	if ((p = gethostbyname(domain)) == NULL)
	{
		return false;
	}
	sprintf(ip,
		"%u.%u.%u.%u",
		(unsigned char)p->h_addr_list[0][0],
		(unsigned char)p->h_addr_list[0][1],
		(unsigned char)p->h_addr_list[0][2],
		(unsigned char)p->h_addr_list[0][3]);
	return true;  
}



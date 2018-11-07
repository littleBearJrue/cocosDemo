
#ifndef __VX_NET_MANAGER_H__
#define __VX_NET_MANAGER_H__


#include "VxSocket.h"
#include "VxConst.h"
#include "XGMacros.h"


class VxNetManager
{
public:
	VxNetManager();
	~VxNetManager();
	XG_SINGLET_WITH_INIT_DECLARE(VxNetManager);
	
	void connectToServer(int nNetSocketId, std::string sIp, short port);
	void disconnectToServer(int nNetSocketId);
	bool hasConnectServer(int nNetSocketId);

	void sendMsgToServer(int nNetSocketId, const char* sMsgData,int nMsgSize);


	static void socketEventCallback(void* pArg, int eEventId, void *pvEventArgs);
public:
	
};

#endif	// __VX_NET_MANAGER_H__
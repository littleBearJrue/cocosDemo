#ifndef __XG_BASE_SYS_H__
#define __XG_BASE_SYS_H__

#include "XGEvent.h"
#include "XGDelegate.h"
#include <unordered_map>

class XGBaseSys
{
protected:
	XGBaseSys(int nEventIdFlag);
	~XGBaseSys();

public:
	void registerEventHandler(int nEventId, XGEventHandlerPtr pFunc, void *pArg = NULL, int nPriority = XG_EVENT_PRIORITY_NORMAL);
	void unregisterEventHandler(int nEventId, XGEventHandlerPtr pFunc, void *pArg = NULL);

	void onBaseEvent(XGEvent* pEvent);
	void onBaseEvent(int nEventId);

	bool matchEventType(int nEventId);

public:
	//std::map<int, VxDelegate*> m_sEventTable;
	int m_nEventIdFlag;
	std::unordered_map<int ,XGDelegate*>m_pDelegates;
	std::string m_sPreEventName;
};






#endif
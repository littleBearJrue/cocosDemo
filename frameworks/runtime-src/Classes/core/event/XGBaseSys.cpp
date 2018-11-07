#include "XGBaseSys.h"
//#include "XGConvert.h"


XGBaseSys::XGBaseSys(int nEventIdFlag)
	: m_nEventIdFlag(nEventIdFlag)
{
	// m_pDispatcher = Director::getInstance()->getEventDispatcher();
}

XGBaseSys::~XGBaseSys()
{
	for(auto it = m_pDelegates.begin(); it != m_pDelegates.end(); it++)
	{
		XG_SAFE_DELETE(it->second);
	}
}

void XGBaseSys::onBaseEvent(XGEvent* pEvent)
{
	//std::map<int, VxDelegate*>::iterator i = m_sEventTable.find(pEvent->getEventId());
	//if(i != m_sEventTable.end())
	{
		//i->second->run(pEvent);
	}
	//std::string sTemp =m_sPreEventName+FLConvert::integerToString(pEvent->m_nId);
	//m_pDispatcher->dispatchCustomEvent(sTemp,pEvent);
	auto it = m_pDelegates.find(pEvent->getEventId());
	if(it != m_pDelegates.end())
	{
		it->second->run(pEvent);
	}

}

void XGBaseSys::onBaseEvent(int nEventId)
{
    XGEvent sTemp = XGEvent(nEventId);
	onBaseEvent(&sTemp);
}


void XGBaseSys::registerEventHandler(int nEventId, XGEventHandlerPtr pFunc, void *pArg, int nPriority)
{
	//std::string sTemp =m_sPreEventName+FLConvert::integerToString(nEventId);

	//const std::function<void(EventCustom*)> callback;

	//m_pDispatcher->addCustomEventListener(sTemp,callback);
	 auto it = m_pDelegates.find(nEventId);
	 if(it != m_pDelegates.end())
	 {
		 VxPriorityFuncion sData((void*)pFunc,pArg,nPriority);
		 it->second->addFunc(&sData);
	 }
	 else
	 {
		 XGDelegate* pDelegate = new XGDelegate();
		 pDelegate->m_nEventId = nEventId;
		 VxPriorityFuncion sData((void*)pFunc,pArg,nPriority);
		 pDelegate->addFunc(&sData);
		 m_pDelegates[nEventId] = pDelegate;
	 }

	
}

void XGBaseSys::unregisterEventHandler(int nEventId, XGEventHandlerPtr pFunc, void *pArg)
{
	auto it = m_pDelegates.find(nEventId);
	if(it != m_pDelegates.end())
	{
		VxPriorityFuncion sData((void*)pFunc,pArg);
		it->second->removeFunc(&sData);
		if(it->second->m_pFuncs.empty())
		{
			XG_SAFE_DELETE(it->second);
			m_pDelegates.erase(it);
		}
	}
}

bool XGBaseSys::matchEventType(int nEventId)
{
	return ((nEventId & 0xFFFF0000) == (m_nEventIdFlag & 0xFFFF0000));
}
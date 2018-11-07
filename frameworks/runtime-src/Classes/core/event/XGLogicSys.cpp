#include "XGLogicSys.h"

static std::list<XGEvent*> m_sDelayEvents;

XGLogicSys::XGLogicSys()
	: XGBaseSys(XGEvent::XG_EVENT_LOGIC)
{
	m_sDelayEvents.clear();
}

void XGLogicSys::onEvent(int nId)
{
    XGEvent sTemp = XGEvent(nId);
	onEvent(&sTemp);
}

void XGLogicSys::onEvent(XGEvent *pEvent)
{
	XGLogicSys* pInst = getInstance();
	if(pInst)
	{
		//CCASSERT(pInst->matchEventType(pEvent->getEventId()), "");
		pInst->onBaseEvent(pEvent);
	}
}

void XGLogicSys::onEvent(XGEvent &sEvent)
{
	XGLogicSys* pInst = getInstance();
	if(pInst)
	{
		//CCASSERT(pInst->matchEventType(sEvent.getEventId()), "");
		pInst->onBaseEvent(&sEvent);
	}
}

void XGLogicSys::dispatchEvent(XGEvent* sEvent)
{
	if (sEvent->m_fDelayTime > 0.0)
	{
		m_sDelayEvents.push_back(sEvent);
	}
	else
	{
		onEvent(sEvent);
	}
	

}

void XGLogicSys::regEventHandler(int nEventId, XGEventHandlerPtr pFunc, void* pArg , int nPriority )
{
	XGLogicSys* pInst = getInstance();
	if(pInst)
	{
		//CCASSERT(pInst->matchEventType(nEventId), "");
		pInst->registerEventHandler(nEventId, pFunc, pArg, nPriority);
	}
}

void XGLogicSys::unregEventHandler(int nEventId, XGEventHandlerPtr pFunc, void* pArg)
{
	XGLogicSys* pInst = getInstance();
	if(pInst)
	{
		//CCASSERT(pInst->matchEventType(nEventId), "");
		pInst->unregisterEventHandler(nEventId, pFunc, pArg);
	}
}

void XGLogicSys::updateDelayEvent(long nCurTime)
{
	//long nCurTime = GetTickCount();
	for (auto it = m_sDelayEvents.begin(); it != m_sDelayEvents.end();)
	{
		if ((*it)->m_fDelayTime > 0.0)
		{
			float dt = (nCurTime - (*it)->m_nStartTime);
			if (dt >= (*it)->m_fDelayTime*1000)
			{
				XGLogicSys* pInst = getInstance();
				pInst->onBaseEvent((*it));
				delete (*it);
				m_sDelayEvents.erase(it++);
				continue;
			}
		}

		it++;
	}
}

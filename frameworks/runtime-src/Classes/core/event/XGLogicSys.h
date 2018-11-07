#ifndef __XG_LOGIC_SYS_H__
#define __XG_LOGIC_SYS_H__

#include "XGLogicEvent.h"
#include "XGBaseSys.h"


class XGLogicSys : public XGBaseSys
{
protected:
	XGLogicSys();
public:
	XG_SINGLET_WITH_INIT_DECLARE(XGLogicSys);

	static void onEvent(int nId);
	static void onEvent(XGEvent *pEvent);
	static void onEvent(XGEvent &sEvent);

	static void dispatchEvent(XGEvent *sEvent);

	static void regEventHandler(int nEventId, XGEventHandlerPtr pFunc, void* pArg = NULL, int nPriority = XG_EVENT_PRIORITY_NORMAL);
	static void unregEventHandler(int nEventId, XGEventHandlerPtr pFunc, void* pArg = NULL);

	static void updateDelayEvent(long nCurTime);
};

#endif

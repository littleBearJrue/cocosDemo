#ifndef __XG_EVENT_H__
#define __XG_EVENT_H__

#include "XGMacros.h"

enum 
{
	XG_EVENT_PRIORITY_LOWEST,
	XG_EVENT_PRIORITY_LOWER,
	XG_EVENT_PRIORITY_LOW,
	XG_EVENT_PRIORITY_NORMAL,
	XG_EVENT_PRIORITY_HIGH,
	XG_EVENT_PRIORITY_HIGHER,
	XG_EVENT_PRIORITY_HIGHEST,
};

class XGEvent
{
public:
	enum 
	{
		XG_EVENT_LOGIC = 1<<16,
		XG_EVENT_VIEW = 2<<16
	};

	XGEvent(int nId)
		: m_nId(nId)
		, m_nStartTime(0)
		, m_fDelayTime(0.0)
	{

	}

	int getEventId(){return m_nId;};
	void setStartAndDelayTime(float fDelayTime)
	{
		m_nStartTime = clock();
		m_fDelayTime = fDelayTime;
	}
public:
	int m_nId;
	long m_nStartTime;
	float m_fDelayTime;
};

typedef bool (*XGEventHandlerPtr)(void* pArg,XGEvent* pEvent);
typedef bool (*XGEventHandlerPtrBAAA)(void* pArg, int pEvent,void *eventArg);

typedef void (*XGEventTimeHandlerPtr)(void* pArg);

#endif
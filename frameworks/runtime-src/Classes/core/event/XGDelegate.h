
#ifndef __XG_DELEGATE_H__
#define __XG_DELEGATE_H__

#include "XGEvent.h"
#include <list>

/************************************************************************/
/* VxFunction
/************************************************************************/
class VxFunction
{
public:
	VxFunction(void* func = NULL, void* arg = NULL)
	{
		m_func = func;
		m_arg = arg;
	}

	inline bool valid()
	{
		return NULL != m_func;
	}

	inline void clear()
	{
		m_func = NULL;
		m_arg = NULL;
	}

	inline bool equal(void* func)
	{
		return m_func == func;
	}

	inline bool equal(void* func, void* arg)
	{
		return (func == m_func && arg == m_arg);
	}

public:
	void* m_func;
	void* m_arg;
};

/************************************************************************/
/* VxPriorityFuncion
/************************************************************************/
class VxPriorityFuncion : public VxFunction
{
public:
	VxPriorityFuncion(void* func = NULL, void* arg = NULL, int priority = XG_EVENT_PRIORITY_NORMAL)
		: VxFunction(func, arg), m_priority(priority)
	{
	}
public:
	int m_priority;
};


class XGDelegate
{
public:
	XGDelegate();
	~XGDelegate();

	void add(void* func, void* arg = NULL, int priority = XG_EVENT_PRIORITY_NORMAL);
	void addFunc(VxPriorityFuncion* pFunc);
	void removeFunc(VxPriorityFuncion* pFunc);

	void run(XGEvent* pEvent);
	void run(int eventId, void* prg);
	int m_nEventId;
	std::list<VxPriorityFuncion>m_pFuncs;
};

#endif	// __VX_DELEGATE_H__
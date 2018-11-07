#include "XGDelegate.h"

XGDelegate::XGDelegate()
{

}

XGDelegate::~XGDelegate()
{
	m_pFuncs.clear();
}



void XGDelegate::add(void* func, void* arg, int priority)
{
	auto a = VxPriorityFuncion(func, arg, priority);
	addFunc(&a);
}



void XGDelegate::addFunc(VxPriorityFuncion* pFunc)
{
	removeFunc(pFunc);
	for(auto it = m_pFuncs.begin(); it != m_pFuncs.end(); it++)
	{
		if((*it).m_priority < pFunc->m_priority )
		{
			m_pFuncs.insert(it,*pFunc);
			return;
		}
	}
	
	m_pFuncs.push_back(*pFunc);
}


void XGDelegate::removeFunc(VxPriorityFuncion* pFunc)
{
	for(auto it = m_pFuncs.begin(); it != m_pFuncs.end(); it++)
	{
		if((*it).equal(pFunc->m_func,pFunc->m_arg))
		{
			m_pFuncs.erase(it);
			
			break;
		}
	}
}

void XGDelegate::run(XGEvent* pEvent)
{

	for(auto it = m_pFuncs.begin(); it != m_pFuncs.end(); it++)
	{
		bool bRet = ((XGEventHandlerPtr)((*it).m_func))((*it).m_arg,pEvent);
		if(bRet)
		{
			break;
		}
	}
}

void XGDelegate::run(int eventId,void* prg)
{

	for (auto it = m_pFuncs.begin(); it != m_pFuncs.end(); it++)
	{
		bool bRet = ((XGEventHandlerPtrBAAA)((*it).m_func))((*it).m_arg, eventId, prg);
		if (bRet)
		{
			break;
		}
	}
}

#ifndef __VX_MSG_H__
#define __VX_MSG_H__

#include "VxExternal.h"
#include "VxType.h"
#include "VxObject.h"

class VxStream;

/************************************************************************/
/* VxMsg
/************************************************************************/
class VxMsg : public VxObject
{
public:
	enum VxMsgType
	{
		NONE,

		MODULE = 1000,
		MODULE_EXIT,
		MODULE_REG_MSG_CB,
		MODULE_UNREG_MSG_CB,
		
		TIMER = 2000,
		TIMER_CB,

		NET = 3000,
		NET_SEND_STREAM,
		NET_HTTP_REQUEST,

		EXECUTION = 4000,
		EXECUTION_A,
		EXECUTION_AA,
		EXECUTION_AAA,
	};

public:
	VxMsg(int nMsgType)
	{
		m_nMsgType = nMsgType;
	}

	inline int msgType()
	{
		return m_nMsgType;
	}

protected:
	int m_nMsgType;
};

template<class T>
class VxMsgTemplate : public VxMsg
{
public:
	VxMsgTemplate(int nMsgType)
		: VxMsg(nMsgType)
	{
	}

	void free()
	{
		T* ptr = (T*)this;
		VX_SAFE_DELETE_MSG(ptr, T);
	}
};


/************************************************************************/
/* VxMsgModuleExit
/************************************************************************/
class VxMsgModuleExit : public VxMsgTemplate<VxMsgModuleExit>
{
public:
	VxMsgModuleExit()
		: VxMsgTemplate<VxMsgModuleExit>(VxMsg::MODULE_EXIT)
	{
	}
};


/************************************************************************/
/* VxMsgModuleRegisterMsgCb
/************************************************************************/
class VxMsgModuleRegisterMsgCb : public VxMsgTemplate<VxMsgModuleRegisterMsgCb>
{
public:
	VxMsgModuleRegisterMsgCb(int msgId, VxFuncPtrMsgCb func, void* arg)
		: VxMsgTemplate<VxMsgModuleRegisterMsgCb>(VxMsg::MODULE_REG_MSG_CB), m_msgId(msgId), m_func(func), m_arg(arg)
	{
	}
public:
	int m_msgId;
	VxFuncPtrMsgCb m_func;
	void* m_arg;
};

/************************************************************************/
/* VxMsgModuleUnRegisterMsgCb
/************************************************************************/
class VxMsgModuleUnRegisterMsgCb : public VxMsgTemplate<VxMsgModuleUnRegisterMsgCb>
{
public:
	VxMsgModuleUnRegisterMsgCb(int msgId, VxFuncPtrMsgCb func, void* arg)
		: VxMsgTemplate<VxMsgModuleUnRegisterMsgCb>(VxMsg::MODULE_UNREG_MSG_CB), m_msgId(msgId), m_func(func), m_arg(arg)
	{
	}
public:
	int m_msgId;
	VxFuncPtrMsgCb m_func;
	void* m_arg;
};

/************************************************************************/
/* VxTimerMsg
/************************************************************************/
class VxMsgTimerCb : public VxMsgTemplate<VxMsgTimerCb>
{
public:
	VxMsgTimerCb(VxTimer timer)
		: VxMsgTemplate<VxMsgTimerCb>(VxMsg::TIMER_CB), m_timer(timer)
	{
	}
public:
	VxTimer m_timer;
};

/************************************************************************/
/* VxMsgExecution
/************************************************************************/
class VxMsgExecution : public VxMsgTemplate<VxMsgExecution>
{
public:
	VxMsgExecution(VxFuncPtrA func, void* arg)
		: VxMsgTemplate<VxMsgExecution>(VxMsg::EXECUTION_A), m_func((void*)func), m_arg0(arg)
	{
	}

	VxMsgExecution(VxFuncPtrAA func, void* arg0, void* arg1)
		: VxMsgTemplate<VxMsgExecution>(VxMsg::EXECUTION_AA), m_func((void*)func), m_arg0(arg0), m_arg1(arg1)
	{
	}

	VxMsgExecution(VxFuncPtrAAA func, void* arg0, void* arg1, void* arg2)
		: VxMsgTemplate<VxMsgExecution>(VxMsg::EXECUTION_AAA), m_func((void*)func), m_arg0(arg0), m_arg1(arg1), m_arg2(arg2)
	{
	}

	void exec();

protected:
	void* m_func;
	void* m_arg0;
	void* m_arg1;
	void* m_arg2;
};


/************************************************************************/
/* VxMsgNetSendStream
/************************************************************************/
class VxMsgNetSendStream : public VxMsgTemplate<VxMsgNetSendStream>
{
public:
	enum
	{
		VXSENDSTREAM_TYPE_NORMAL,
	};
public:
	VxMsgNetSendStream(VxStream* stream, VxNetSendCb func = NULL, void* arg = NULL);
	~VxMsgNetSendStream();

	// if success, return the len of copied stream.
	int copyTo(VxStream* stream);

	void runEventCb(int eventId, void* eventArg);

public:
	int m_netStreamType;
	VxStream* m_stream;
	VxNetSendCb m_func;
	void* m_arg;
};



#endif	// __VX_MSG_H__
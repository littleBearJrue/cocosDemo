
#include "VxMsg.h"
#include "VxDef.h"
#include "VxConst.h"
#include "VxStream.h"


/************************************************************************/
/* VxMsgExecution
/************************************************************************/
void VxMsgExecution::exec()
{
	switch(m_nMsgType)
	{
	case VxMsg::EXECUTION_A:
		((VxFuncPtrA)m_func)(m_arg0);
		break;
	case VxMsg::EXECUTION_AA:
		((VxFuncPtrAA)m_func)(m_arg0, m_arg1);
		break;
	case VxMsg::EXECUTION_AAA:
		((VxFuncPtrAAA)m_func)(m_arg0, m_arg1, m_arg2);
		break;
	}
}

/************************************************************************/
/* VxMsgNetSendStream
/************************************************************************/

VxMsgNetSendStream::VxMsgNetSendStream(VxStream* stream, VxNetSendCb func, void* arg)
	: VxMsgTemplate<VxMsgNetSendStream>(VxMsg::NET_SEND_STREAM), m_netStreamType(VXSENDSTREAM_TYPE_NORMAL), m_stream(stream), m_func(func), m_arg(arg)
{
	VX_SAFE_RETAIN(m_stream);
}

VxMsgNetSendStream::~VxMsgNetSendStream()
{
	VX_SAFE_RELEASE_NULL(m_stream);
}

int VxMsgNetSendStream::copyTo(VxStream* stream)
{
	int ret = 0;
	switch(m_netStreamType)
	{
	case VXSENDSTREAM_TYPE_NORMAL:
		{
			ret += m_stream->readCapacity();
			if(!m_stream->read(stream, m_stream->readCapacity()))
			{
				return VXERR_FAILED;
			}
		}
		break;
	default:
		break;
	}
	return ret;
}

void VxMsgNetSendStream::runEventCb(int eventId, void* eventArg)
{
	if(m_func)
	{
		m_func(m_arg, eventId, eventArg);
	}
}


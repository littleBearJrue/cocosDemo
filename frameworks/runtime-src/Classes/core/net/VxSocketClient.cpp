
#include "VxSocketClient.h"
#include "VxStream.h"
#include "VxType.h"
#include <thread>
#include "XGLogicSys.h"

VxSocketClient::VxSocketClient(const char* addr, unsigned short port)
{
	m_addr = addr;
	m_port = port;
	m_state = VXSOCKET_STATE_NOT_OPEN;
	m_recvInternalBufferSize = VXSOCKETCLIENT_INTERNAL_BUFFER_SIZE;
	m_sendInternalBufferSize = VXSOCKETCLIENT_INTERNAL_BUFFER_SIZE;
	m_sendInternalBuffer = NULL;
	m_recvInternalBuffer = NULL;
	m_recvBuffer = NULL;
	m_sendBuffer = NULL;
	m_totalSend = 0;
	m_totalRecv = 0;
}

VxSocketClient::~VxSocketClient()
{
	this->close();
	VX_SAFE_DELETE_ARRAY(m_sendInternalBuffer);
	VX_SAFE_DELETE_ARRAY(m_recvInternalBuffer);
	VX_SAFE_RELEASE_NULL(m_recvBuffer);
	VX_SAFE_RELEASE_NULL(m_sendBuffer);
}

void VxSocketClient::connect()
{
	int ret = VXERR_SUCCESS;

	do 
	{
		if(NULL == m_recvInternalBuffer)
		{
			m_recvInternalBuffer = new char[m_recvInternalBufferSize];
		}
		if(NULL == m_sendInternalBuffer)
		{
			m_sendInternalBuffer = new char[m_sendInternalBufferSize];
		}

		if(!m_sendInternalBuffer || !m_recvInternalBuffer)
		{
			ret = VXERR_FAILED;
			break;
		}

		m_state = VXSOCKET_STATE_CONNECTING;
		_createThreadResource();
		 m_sendThread = new (std::nothrow) std::thread(&VxSocketClient::_sendThreadProc, this);//VxThreadManager::create(&m_sendThread, VxSocketClient::_sendThreadProc, this);
		
		if(m_sendThread == NULL)
		{
			//ret
			break;
		}
		else
		{
			m_sendThread->detach();
		}

		return;

	} while (0);

	_destroyThreadResource();
	VX_SAFE_DELETE_ARRAY(m_sendInternalBuffer);
	VX_SAFE_DELETE_ARRAY(m_recvInternalBuffer);

	m_state = VXSOCKET_STATE_NOT_OPEN;

	notifyEvent(VXSOCKET_EVENT_CONNECT_FAILED, NULL);
}

void* VxSocketClient::_sendThreadProc(void* arg)
{
	VxSocketClient* client = (VxSocketClient*)arg;

	// connect
	if(client->m_state == VXSOCKET_STATE_CONNECTING)
	{
		do 
		{
			char ip[VXSOCKETCLIENT_IP_STRING_SIZE] = { 0 };

			client->notifyEvent(VXSOCKET_EVENT_CONNECT_BEGIN, NULL);
			
			if(!client->m_socket.create()
				|| !VxSocket::parseDns(client->m_addr.c_str(), ip)
				|| !client->m_socket.connect(ip, client->m_port))
			{
				client->_close();
				client->_destroyThreadResource();
				client->notifyEvent(VXSOCKET_EVENT_CONNECT_FAILED, NULL);
				return NULL;
			}
			client->m_state = VXSOCKET_STATE_RUNNING;
			client->notifyEvent(VXSOCKET_EVENT_CONNECT_COMPLETE, NULL);
		} while (0);
	}

	// recv
	client->m_recvThread = new (std::nothrow)std::thread(&VxSocketClient::_recvThreadProc, client);//VxThreadManager::create(&client->m_recvThread, VxSocketClient::_recvThreadProc, client);

	if(NULL == client->m_recvThread)
	{
		client->_close();
		client->notifyEvent(VXSOCKET_EVENT_CLOSED, NULL);
	}
	else
	{
		client->m_recvThread->detach();
		client->m_state = VXSOCKET_STATE_RUNNING;
	}

	// send
	client->sendThreadProc();

	return NULL;
}

void VxSocketClient::sendThreadProc()
{
	int errCode = VXERR_SUCCESS;
	while(m_state == VXSOCKET_STATE_RUNNING
		&& errCode == VXERR_SUCCESS)
	{
		VXLOG("VxSocketClient::sendThreadProc, to VxSemManager::wait");
		//lock_guard<std::mutex> lock(m_sendMutex);
		std::unique_lock<std::mutex> lock(m_sendMutex);

		if (m_sendBuffer->size() == 0)
		{
			m_sendSem.wait(lock);
		}
		//m_sendSem.wait(lock, [&] {return ! m_sendBuffer->size() == 0; });

		//if(VXERR_SUCCESS != VxSemManager::wait(&m_sendSem))
		{
			//errCode = VXERR_SOCKECLIENT_SEND_ERROR;
			//break;
		}
		VXLOG("VxSocketClient::sendThreadProc, get VxSemManager::wait");
		int nReadCapacity = m_sendBuffer->readCapacity();
		int len = nReadCapacity;
		while(0 < len && errCode == VXERR_SUCCESS)
		{
			int onceSize = min(len, m_sendInternalBufferSize);

			VXLOG("VxSocketClient::sendThreadProc, read buffer size = %d", onceSize);
			m_sendBuffer->read(m_sendInternalBuffer, onceSize);
			for(int sentSize = 0; sentSize < onceSize && errCode == VXERR_SUCCESS; )
			{
				int ret = m_socket.send(m_sendInternalBuffer + sentSize, onceSize - sentSize);
				VXLOG("VxSocketClient::sendThreadProc, sock send size = %d", ret);
				if(0 >= ret)
				{
					errCode = VXERR_SOCKECLIENT_SEND_ERROR;
					break;
				}
				sentSize += ret;
			}
			len -= onceSize;
		}
		m_totalSend += nReadCapacity;

		lock.unlock();
		notifyEvent(VXSOCKET_EVENT_SEND, (void*)nReadCapacity);
	}
	VXLOG("VxSocketClient::sendThreadProc, outside loop");
	if(m_state == VXSOCKET_STATE_RUNNING)
	{
		//VxSemManager::destroy(&m_sendSem);
		m_socket.close();
		// let the recv thread to notify the event
	}
	VXLOG("VxSocketClient::sendThreadProc, end");
}

void VxSocketClient::recvThreadProc()
{
	while(m_state == VXSOCKET_STATE_RUNNING)
	{
		VXLOG("VxSocketClient::recvThreadProc, to recv, buffer size = %d", m_recvInternalBufferSize);
		int ret = m_socket.recv(m_recvInternalBuffer, m_recvInternalBufferSize);
		VXLOG("VxSocketClient::recvThreadProc, recv size = %d", ret);
		if(0 >= ret)
		{
			break;
		}
		if(m_recvBuffer->write(m_recvInternalBuffer, ret))
		{
			m_totalRecv += ret;
			//m_recvInternalBuffer[ret]
			VxString sRecvData(m_recvInternalBuffer, ret);
			notifyEvent(VXSOCKET_EVENT_RECV, (void*)&sRecvData);
		}
	}
	if(m_state == VXSOCKET_STATE_RUNNING)
	{
		notifyEvent(VXSOCKET_EVENT_CLOSED, NULL);
	}
}

void* VxSocketClient::_recvThreadProc(void* arg)
{
	VxSocketClient* client = (VxSocketClient*)arg;
	client->recvThreadProc();
	return NULL;
}

void VxSocketClient::close()
{
	VXLOG("VxSocketClient::close, begin");
	if(VXSOCKET_STATE_RUNNING == m_state)
	{
		m_state = VXSOCKET_STATE_CLOSING;
		m_socket.close();
		_destroyThreadResource();
		notifyEvent(VXSOCKET_EVENT_CLOSED, NULL);
		VXLOG("VxSocketClient::close, join send thread, id = %x", m_sendThread);
		//VxThreadManager::join(m_sendThread, NULL);
		VXLOG("VxSocketClient::close, join recv thread, id = %d", m_recvThread);
		//VxThreadManager::join(m_recvThread, NULL);
	}
	else if(VXSOCKET_STATE_CONNECTING == m_state)
	{
		m_state = VXSOCKET_STATE_CLOSING;
		m_socket.close();
		_destroyThreadResource();
		VXLOG("VxSocketClient::close, join send thread, id = %x", m_sendThread);
		//VxThreadManager::join(m_sendThread, NULL);
	}
	VXLOG("VxSocketClient::close, end");
}

bool VxSocketClient::setInternalBufferSize(int size)
{
	if(VXSOCKET_STATE_NOT_OPEN == m_state)
	{
		VX_SAFE_DELETE_ARRAY(m_sendInternalBuffer);
		VX_SAFE_DELETE_ARRAY(m_recvInternalBuffer);
		m_recvInternalBufferSize = size;
		m_sendInternalBufferSize = size;
		return true;
	}
	return false;
}

void VxSocketClient::setSendBuffer(VxStream* sendBuffer)
{
	m_sendBuffer = sendBuffer;
	m_sendBuffer->retain();
}

void VxSocketClient::setRecvBuffer(VxStream* recvBuffer)
{
	m_recvBuffer = recvBuffer;
	m_recvBuffer->retain();
}

VxStream* VxSocketClient::getSendBuffer()
{
	return m_sendBuffer;
}

VxStream* VxSocketClient::getRecvBuffer()
{
	return m_recvBuffer;
}

bool VxSocketClient::send(VxStream* buffer, int len)
{
	lock_guard<std::mutex> lock(m_sendMutex);
	bool ret = m_sendBuffer->write(buffer, len);
	if(ret)
	{
		m_sendBuffer->flush();
		VXLOG("VxSocketClient::send");
		//VxSemManager::post(&m_sendSem);
		m_sendSem.notify_one();
	}
	return ret;
}

bool VxSocketClient::recv(VxStream* buffer, int len)
{
	return m_recvBuffer->read(buffer, len);
}

void VxSocketClient::flush()
{
	//m_sendBuffer->flush();
	//VxSemManager::post(&m_sendSem);
}

void VxSocketClient::registerEventCb(VxSockEventCb eventCb, void* arg)
{
	m_eventCb.add((void*)eventCb, arg);
}

void VxSocketClient::unregisterEventCb(VxSockEventCb eventCb, void* arg)
{
	auto s = VxPriorityFuncion((void*)eventCb, arg);
	m_eventCb.removeFunc(&s);
} 

void VxSocketClient::notifyEvent(int eventId, void* eventArg)
{
	m_eventCb.run(eventId, eventArg);
}

void VxSocketClient::_close()
{
	m_socket.close();
	m_state = VXSOCKET_STATE_NOT_OPEN;
}

void VxSocketClient::_createThreadResource()
{
	//VxSemManager::create(&m_sendSem, 0);
	//VxMutexManager::create(&m_sendMutex);
	//VxMutexManager::create(&m_recvMutex);
}

void VxSocketClient::_destroyThreadResource()
{
	VXLOG("VxSocketClient::_destroyThreadResource, begin");
	//VxSemManager::destroy(&m_sendSem);
	//VxMutexManager::destroy(&m_sendMutex);
	//VxMutexManager::destroy(&m_recvMutex);
	VXLOG("VxSocketClient::_destroyThreadResource, end");
}
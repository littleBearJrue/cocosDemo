
#include "VxIOStream.h"
#include "VxLocalObject.h"


VxIOStream::VxIOStream(VxStream* pBaseStream)
	: VxStream(pBaseStream->rwType())
{
	m_pStream = pBaseStream;
	m_pStream->retain();
	m_nReadPos = m_pStream->pos();
	m_nWritePos = m_pStream->size();
	m_nSize = m_nWritePos - m_nReadPos;
}

VxStream* VxIOStream::GetBaseStream()
{
	return m_pStream;
}

VxIOStream::~VxIOStream()
{
	m_pStream->release();
}

bool VxIOStream::readSkip(int nLen)
{
	if(this->readCapacity() < nLen)
	{
		m_nReadPos = (m_nReadPos + nLen) % this->capacity();
		m_nSize -= nLen;
		this->adjust();
		return false;
	}
	else
	{
		return true;
	}
}

bool VxIOStream::seek(int nPos)
{
	return false;
}

bool VxIOStream::read(char* pBuffer, int nLen)
{
	if(nLen > this->readCapacity())
	{
		m_nErrCode = VXERR_STREAM_READ;
		return false;
	}
	int capacity = m_pStream->capacity();
	if(m_nReadPos + nLen <= capacity)
	{
		m_pStream->seek(m_nReadPos);
		m_pStream->read(pBuffer, nLen);
		m_nReadPos = (m_nReadPos + nLen) % capacity;
		m_nSize -= nLen;
		this->adjust();
		return true;
	}

	VxMemStream other(pBuffer, 0, nLen);
	return this->read(&other, nLen);
}

bool VxIOStream::write(char* pBuffer, int nLen)
{
	if(nLen > this->writeCapacity())
	{
		m_nErrCode = VXERR_STREAM_WRITE;
		return false;
	}
	int capacity = m_pStream->capacity();
	if(m_nWritePos + nLen <= capacity)
	{
		m_pStream->seek(m_nWritePos);
		m_pStream->write(pBuffer, nLen);
		m_nWritePos = (m_nWritePos + nLen) % capacity;
		m_nSize += nLen;
		this->adjust();
		return true;
	}

	VxMemStream other(pBuffer, nLen, nLen);
	return this->write(&other, nLen);
}

bool VxIOStream::write(VxStream* pOther, int nLen)
{
	bool bRet = false;

	do 
	{
		if(this->writeCapacity() < nLen)
		{
			m_nErrCode = VXERR_STREAM_WRITE;
			break;
		}

		if(pOther->readCapacity() < nLen)
		{
			m_nErrCode = VXERR_STREAM_READ;
			break;
		}

		int capacity = m_pStream->capacity();
		int nOnceSize = min(nLen, capacity - m_nWritePos);

		if(0 < nOnceSize)
		{
			m_pStream->seek(m_nWritePos);
			m_pStream->write(pOther, nOnceSize);
		}

		if(nOnceSize < nLen)
		{
			m_pStream->seek(0);
			m_pStream->write(pOther, nLen - nOnceSize);
		}

		m_nErrCode = m_pStream->error();

		if(VXERR_SUCCESS == m_nErrCode)
		{
			m_nSize += nLen;
			m_nWritePos = (m_nWritePos + nLen) % capacity;
			this->adjust();
			bRet = true;
		}

	} while (0);

	return bRet;
}

bool VxIOStream::read(VxStream* pOther, int nLen)
{
	bool bRet = false;

	do 
	{
		if(nLen > this->readCapacity())
		{
			m_nErrCode = VXERR_STREAM_READ;
			break;
		}

		if(nLen > pOther->writeCapacity())
		{
			m_nErrCode = VXERR_STREAM_WRITE;
			break;
		}

		int capacity = m_pStream->capacity();
		int nOnceSize = min(nLen, capacity - m_nReadPos);

		if(0 < nOnceSize)
		{
			m_pStream->seek(m_nReadPos);
			m_pStream->read(pOther, nOnceSize);
		}

		if(nOnceSize < nLen)
		{
			m_pStream->seek(0);
			m_pStream->read(pOther, nLen - nOnceSize);
		}

		m_nErrCode = m_pStream->error();

		if(VXERR_SUCCESS == m_nErrCode)
		{
			m_nSize -= nLen;
			m_nReadPos = (m_nReadPos + nLen) % capacity;
			this->adjust();
			bRet = true;
		}

	} while (0);

	return bRet;
}

int VxIOStream::pos()
{
	return m_pStream->pos();
}

int VxIOStream::size()
{
	return m_nSize;
}

int VxIOStream::capacity()
{
	return m_pStream->capacity();
}

int VxIOStream::readCapacity()
{
	return this->size();
}

int VxIOStream::writeCapacity()
{
	return m_pStream->capacity() - m_nSize;
}

void VxIOStream::adjust()
{
	if(0 == m_nSize)
	{
		m_nReadPos = m_nWritePos = 0;
	}
}

void VxIOStream::reset()
{
	m_pStream->reset();
	m_nReadPos = 0;
	m_nWritePos = 0;
	m_nSize = 0;
}


/************************************************************************/
/* VxMemIOStream
/************************************************************************/
VxMemIOStream::VxMemIOStream(VxMemStream* pBaseStream)
	: VxIOStream(pBaseStream)
{
}

VxMemIOStream::VxMemIOStream(int nCapacity, bool bEnlarge)
	: VxIOStream(new VxMemStream(nCapacity, bEnlarge))
{
	m_pStream->release();
}

VxString VxMemIOStream::readBlockBuffer(int nSize)
{
	VxString sRet;
	if(nSize <= readBlockBufferSize())
	{
		VxMemStream* pMemStream = (VxMemStream*)m_pStream;
		sRet.m_pString = pMemStream->buffer() + m_nReadPos;
		sRet.m_nLength = nSize;
		m_nReadPos = (m_nReadPos + nSize) % m_pStream->capacity();
		m_nSize -= nSize;
		adjust();
	}
	return sRet;
}

int VxMemIOStream::readBlockBufferSize()
{
	return min(m_nSize, m_pStream->capacity() - m_nReadPos);
}

void VxMemIOStream::adjustBuffer()
{
	if(m_nReadPos)
	{
		VxMemStream* pMemStream = (VxMemStream*)m_pStream;
		memcpy(pMemStream->buffer(), pMemStream->buffer() + m_nReadPos, m_nSize);
		m_nReadPos = 0;
		m_nWritePos = m_nSize;
	}
}

/************************************************************************/
/* VxFileIOStream
/************************************************************************/
VxFileIOStream::VxFileIOStream(VxFileStream* pBaseStream)
	: VxIOStream(pBaseStream)
{
}

VxFileIOStream::VxFileIOStream(const char* pFileName, int nMode)
	: VxIOStream(new VxFileStream(pFileName, nMode))
{
	m_pStream->release();
}


/************************************************************************/
/* VxFileIOStreamTS
/************************************************************************/
VxCacheIOStream::VxCacheIOStream(const char* pCacheFileName, int nBufferSize)
	: VxIOStream(new VxFileIOStream(pCacheFileName, VXFILE_OPEN_FLAG_CREATE_ALWAYS))
{
	m_sIOFilePath = pCacheFileName;
	m_pStream->release();
	m_pReadBuffer = new VxMemIOStream(nBufferSize);
	m_pWriteBuffer = new VxMemIOStream(nBufferSize);
	//VxMutexManager::create(&m_sFileMutex);
	m_nRWType = VXSTREAM_RW_CACHE;
}

VxCacheIOStream::VxCacheIOStream(int nInitCapacity, int nBufferSize)
	: VxIOStream(new VxMemIOStream(nInitCapacity, true))
{
	m_sIOFilePath = "";
	m_pStream->release();
	m_pReadBuffer = new VxMemIOStream(nBufferSize);
	m_pWriteBuffer = new VxMemIOStream(nBufferSize);
	//VxMutexManager::create(&m_sFileMutex);
	m_nRWType = VXSTREAM_RW_CACHE;
}

VxCacheIOStream::~VxCacheIOStream()
{
	m_pReadBuffer->release();
	m_pWriteBuffer->release();
	//VxMutexManager::destroy(&m_sFileMutex);
}

bool VxCacheIOStream::seek(int nPos)
{
	return false;
}

bool VxCacheIOStream::read(char* pBuffer, int nLen)
{
	if(m_pReadBuffer->readCapacity() >= nLen)
	{
		return m_pReadBuffer->read(pBuffer, nLen);
	}
	else
	{
		VxMemStream other(pBuffer, 0, nLen);
		return this->read(&other, nLen);
	}
}

bool VxCacheIOStream::write(char* pBuffer, int nLen)
{
	if(m_pWriteBuffer->writeCapacity() >= nLen)
	{
		return m_pWriteBuffer->write(pBuffer, nLen);
	}
	else
	{
		VxMemStream other(pBuffer, nLen, nLen);
		return this->write(&other, nLen);
	}
}

bool VxCacheIOStream::write(VxStream* pOther, int nLen)
{
	bool bRet = false;

	do 
	{
		int nWriteBufferSize = m_pWriteBuffer->writeCapacity();
		int nOnceSize = min(nLen, nWriteBufferSize);
		if(0 < nOnceSize)
		{
			m_pWriteBuffer->write(pOther, nOnceSize);
			nLen -= nOnceSize;
		}
		if(0 < nLen)
		{
			std::lock_guard<std::mutex> lk(m_sFileMutex);
			//VxLocalMutex localMutex(&m_sFileMutex);
			m_pWriteBuffer->read(m_pStream, m_pWriteBuffer->readCapacity());
			if(nLen > m_pWriteBuffer->writeCapacity())
			{
				m_pStream->write(pOther, nLen);
				nLen = 0;
			}
		}
		if(0 < nLen)
		{
			m_pWriteBuffer->write(pOther, nLen);
		}

		bRet = true;
	} while (0);

	return bRet;
}

bool VxCacheIOStream::read(VxStream* pOther, int nLen)
{
	bool bRet = false;

	do 
	{
		int nReadBufferSize = m_pReadBuffer->readCapacity();
		int nOnceSize = min(nLen, nReadBufferSize);
		if(0 < nOnceSize)
		{
			m_pReadBuffer->read(pOther, nOnceSize);
			nLen -= nOnceSize;
		}
		if(0 < nLen)
		{
			std::lock_guard<std::mutex> lk(m_sFileMutex);
			//VxLocalMutex localMutex(&m_sFileMutex);
			if(nLen > m_pReadBuffer->writeCapacity())
			{
				m_pStream->read(pOther, nLen);
				nLen = 0;
			}
			m_pReadBuffer->write(m_pStream, min(m_pReadBuffer->writeCapacity(), m_pStream->readCapacity()));
		}
		if(0 < nLen)
		{
			m_pReadBuffer->read(pOther, nLen);
		}

		bRet = true;
	} while (0);

	return bRet;
}

int VxCacheIOStream::pos()
{
	return 0;
}

int VxCacheIOStream::size()
{
	return m_pStream->size() + m_pReadBuffer->size();
}

int VxCacheIOStream::capacity()
{
	return m_pStream->capacity();
}

int VxCacheIOStream::readCapacity()
{
	return m_pStream->readCapacity() + m_pReadBuffer->readCapacity();
}

int VxCacheIOStream::writeCapacity()
{
	return m_pStream->writeCapacity();
}

bool VxCacheIOStream::readSkip(int nLen)
{
	if(this->readCapacity() < nLen)
	{
		return false;
	}
	int nOnceSize = min(m_pReadBuffer->readCapacity(), nLen);
	if(0 < nOnceSize)
	{
		m_pReadBuffer->readSkip(nOnceSize);
		nLen -= nOnceSize;
	}
	if(0 < nLen)
	{
		std::lock_guard<std::mutex> lk(m_sFileMutex);
		((VxIOStream*)m_pStream)->readSkip(nLen);
	}
	return true;
}

void VxCacheIOStream::flush()
{
	std::lock_guard<std::mutex> lk(m_sFileMutex);
	m_pWriteBuffer->read(m_pStream, m_pWriteBuffer->readCapacity());
}

void VxCacheIOStream::fillReadBuffer()
{
	m_pReadBuffer->adjustBuffer();

	std::lock_guard<std::mutex> lk(m_sFileMutex);
	m_pReadBuffer->write(m_pStream, min(m_pReadBuffer->writeCapacity(), m_pStream->readCapacity()));
}

void VxCacheIOStream::reset()
{
	m_pReadBuffer->reset();
	m_pWriteBuffer->reset();
	std::lock_guard<std::mutex> lk(m_sFileMutex);
	VxIOStream::reset();
}

std::string VxCacheIOStream::getIOFilePath()
{
	return m_sIOFilePath;
}

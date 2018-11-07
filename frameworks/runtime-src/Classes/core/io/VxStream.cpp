
#include "VxStream.h"
#include "VxFile.h"

/************************************************************************/
/* VxStream
/************************************************************************/
VxStream::VxStream(int nRWType)
{
	m_nRWType = nRWType;
	m_nErrCode = VXERR_SUCCESS;
}

int VxStream::error()
{
	return m_nErrCode;
}

void VxStream::clearError()
{
	m_nErrCode = VXERR_SUCCESS;
}

int VxStream::rwType()
{
	return m_nRWType;
}

void VxStream::flush()
{
}

bool VxStream::fillZero(int nLen)
{
	if(nLen <= VXFILE_FILL_ZERO_BUFFER_SIZE_MIN)
	{
		char buffer[VXFILE_FILL_ZERO_BUFFER_SIZE_MIN] = { 0 };
		int writeSize = min(nLen, VXFILE_FILL_ZERO_BUFFER_SIZE_MIN);
		return this->write(buffer, writeSize);
	}
	else
	{
		bool ret = true;
		int bufferSize = min(VXFILE_FILL_ZERO_BUFFER_SIZE_MAX, nLen);
		char* buffer = new char[bufferSize];
		if(!buffer)
		{
			return false;
		}

		memset(buffer, 0, bufferSize);
		while(0 < nLen && ret)
		{
			int onceSize = min(nLen, bufferSize);
			if(!this->write(buffer, onceSize))
			{
				ret = false;
				break;
			}
			nLen -= onceSize;
		}
		VX_SAFE_DELETE_ARRAY(buffer);
		return ret;
	}
}

bool VxStream::read(VxStream* pOther, int nLen)
{
	if(!checkRead(pOther, nLen))
	{
		return false;
	}

	if(this->rwType() > pOther->rwType())
	{
		return pOther->write(this, nLen);
	}

	int nBufferSize = min(VXSTREAM_COPY_BUFFER_SIZE, nLen);
	char* pBuffer = new char[nBufferSize];
	bool bRet = false;
	do 
	{
		VX_BREAK_IF(!pBuffer);
		int nCount = 0;
		while(nCount < nLen)
		{
			int nOnceSize = min(nBufferSize, (nLen - nCount));
			if(!this->read(pBuffer, nOnceSize)
				|| !pOther->write(pBuffer, nOnceSize))
			{
				break;
			}
			nCount += nOnceSize;
		}
		bRet = (nCount == nLen);
	} while (0);

	VX_SAFE_DELETE_ARRAY(pBuffer);
	return bRet;
}

bool VxStream::write(VxStream *pOther, int nLen)
{
	int nOldType = this->rwType();
	if(this->rwType() <= pOther->rwType())
	{
		this->m_nRWType = pOther->rwType();
	}
	bool bRet = pOther->read(this, nLen);
	this->m_nRWType = nOldType;
	return bRet;
}

bool VxStream::checkRead(VxStream *pOther, int nLen)
{
	if(this->readCapacity() < nLen)
	{
		m_nErrCode = VXERR_STREAM_READ;
		return false;
	}
	if(pOther->writeCapacity() < nLen)
	{
		m_nErrCode = VXERR_STREAM_WRITE;
		return false;
	}
	return true;
}

bool VxStream::checkWrite(VxStream *pOther, int nLen)
{
	return pOther->checkRead(this, nLen);
}

int VxStream::readCapacity()
{
	return this->size() - this->pos();
}

int VxStream::writeCapacity()
{
	return this->capacity() - this->size();
}

/************************************************************************/
/* VxMemStream
/************************************************************************/
VxMemStream::VxMemStream(int nCapacity, bool bEnlarge)
	: VxStream(VxStream::VXSTREAM_RW_MEMORY)
{
	char* pBuffer = NULL;
	if(0 < nCapacity)
	{
		pBuffer = new char[nCapacity];
	}
	init(pBuffer, 0, nCapacity);
	m_bManaged = true;
	m_bEnlarge = bEnlarge;
}

VxMemStream::VxMemStream(char* pBuffer, int nSize, int nCapacity)
	: VxStream(VxStream::VXSTREAM_RW_MEMORY)
{
	init(pBuffer, nSize, nCapacity);
}

VxMemStream::~VxMemStream()
{
	if(m_bManaged)
	{
		m_bManaged = false;
		m_bEnlarge = false;
		VX_SAFE_DELETE_ARRAY(m_pBuffer);
	}
}

void VxMemStream::init(char* pBuffer, int nSize, int nCapacity)
{
	m_bManaged = false;
	m_bEnlarge = false;
	m_pBuffer = pBuffer;
	m_nSize = nSize;
	m_nCapacity = nCapacity;
	m_nPos = 0;
}

void VxMemStream::enlarge(bool bEnlarge)
{
	m_bEnlarge = bEnlarge;
}

char* VxMemStream::currPointer()
{
	return this->buffer() + this->pos();
}

void VxMemStream::skip(int nLen)
{
	this->seek(this->pos() + nLen);
}

char* VxMemStream::buffer()
{
	return m_pBuffer;
}

bool VxMemStream::advance(int nLen)
{
	if(m_nPos + nLen > m_nCapacity)
	{
		if(!m_bManaged)
		{
			m_nErrCode = VXERR_STREAM_WRITE;
			return false;
		}
		else
		{
			if(!setCapacity(max(m_nPos + nLen, m_nSize + m_nSize)))
			{
				return false;
			}
		}
	}

	m_nPos += nLen;
	m_nSize = max(m_nSize, m_nPos);
	return true;
}

void VxMemStream::setBufferManaged(bool bManaged)
{
	m_bManaged = bManaged;
}

bool VxMemStream::seek(int nPos)
{
	if(0 > nPos || nPos > m_nSize)
	{
		m_nErrCode = VXERR_STREAM_SEEK;
		return false;
	}
	else
	{
		m_nPos = nPos;
		return true;
	}
}

bool VxMemStream::read(char* pBuffer, int nLen)
{
	if(m_nPos + nLen > m_nSize)
	{
		m_nErrCode = VXERR_STREAM_READ;
		return false;
	}
	else
	{
		memcpy(pBuffer, m_pBuffer + m_nPos, nLen);
		m_nPos += nLen;
		return true;
	}
}

bool VxMemStream::write(char* pBuffer, int nLen)
{
	if(m_nPos + nLen > m_nCapacity)
	{
		if(!m_bManaged)
		{
			m_nErrCode = VXERR_STREAM_WRITE;
			return false;
		}
		else
		{
			if(!setCapacity(max(m_nPos + nLen, m_nSize + m_nSize)))
			{
				return false;
			}
		}
	}

	memcpy(m_pBuffer + m_nPos, pBuffer, nLen);
	m_nPos += nLen;
	m_nSize = max(m_nSize, m_nPos);
	return true;
}

bool VxMemStream::setCapacity(int nCapacity)
{
	if(!m_bEnlarge)
	{
		m_nErrCode = VXERR_STREAM_OPERATION_NOT_ALLOW;
		return false;
	}

	if(nCapacity < m_nSize)
	{
		m_nErrCode = VXERR_STREAM_PARAM_ERROR;
		return false;
	}
	
	char* pBuffer = new char[nCapacity];
	if(!pBuffer)
	{
		m_nErrCode = VXERR_MEMORY_NOT_ENOUGH;
		return false;
	}

	if(m_pBuffer)
	{
		int nOldPos = this->pos();
		this->seek(0);
		this->read(pBuffer, m_nSize);
		if(m_bManaged)
		{
			VX_SAFE_DELETE_ARRAY(m_pBuffer);
		}
		this->seek(nOldPos);
	}
	m_pBuffer = pBuffer;
	m_nCapacity = nCapacity;

	return true;
}

int VxMemStream::pos()
{
	return m_nPos;
}

int VxMemStream::size()
{
	return m_nSize;
}

int VxMemStream::capacity()
{
	if(m_bEnlarge)
	{
		return VXSTREAM_CAPACITY_MAX;
	}
	else
	{
		return m_nCapacity;
	}
}

void VxMemStream::reset()
{
	m_nPos = 0;
	m_nSize = 0;
}

bool VxMemStream::write(VxStream* pOther, int nLen)
{
	if(m_nPos + nLen > m_nCapacity)
	{
		if(!m_bManaged)
		{
			m_nErrCode = VXERR_STREAM_WRITE;
			return false;
		}
		else
		{
			if(!setCapacity(max(m_nPos + nLen, m_nSize + m_nSize)))
			{
				return false;
			}
		}
	}
	bool bRet = pOther->read(m_pBuffer + m_nPos, nLen);
	m_nPos += nLen;
	m_nSize = max(m_nSize, m_nPos);
	return true;
}

bool VxMemStream::read(VxStream *pOther, int nLen)
{
	if(m_nSize - m_nPos < nLen)
	{
		m_nErrCode = VXERR_STREAM_WRITE;
		return false;
	}
	//int nSize = pOther->size() - pOther->pos();
	bool bRet = pOther->write(m_pBuffer + m_nPos, nLen);
	this->seek(this->pos() + nLen);
	return bRet;
}

/************************************************************************/
/* File Stream
/************************************************************************/
VxFileStream::VxFileStream(const char* pFileName, int nMode)
	: VxStream(VxStream::VXSTREAM_RW_FILE)
{
	FILE* phFile = VxFile::open(pFileName, nMode);
	m_hFile = phFile;
	if(m_hFile)
	{
		m_bManaged = true;
		m_nPos = 0;
		fseek(m_hFile, 0, SEEK_END);
		m_nSize = ftell(m_hFile);
		fseek(m_hFile, m_nPos, SEEK_SET);
	}
}

VxFileStream::VxFileStream(FILE* phFile)
	: VxStream(VxStream::VXSTREAM_RW_FILE)
{
	m_hFile = phFile;
	m_bManaged = false;
	m_nPos = ftell(m_hFile);
	fseek(m_hFile, 0, SEEK_END);
	m_nSize = ftell(m_hFile);
	fseek(m_hFile, m_nPos, SEEK_SET);
}

VxFileStream::~VxFileStream()
{
	if(m_bManaged)
	{
		VX_SAFE_CLOSE_FILE(m_hFile);
		m_bManaged = false;
		m_nPos = 0;
		m_nSize = 0;
	}
}

bool VxFileStream::seek(int nPos)
{
	if(nPos == m_nPos)
	{
		return true;
	}
	if (0 == fseek(m_hFile, nPos, SEEK_SET))
	{
		m_nPos = nPos;
		return true;
	}
	return false;
}

bool VxFileStream::read(char* pBuffer, int nLen)
{
	if (nLen == fread(pBuffer, 1, nLen, m_hFile))
	{
		m_nPos += nLen;
		return true;
	}
	else
	{
		m_nErrCode = VXERR_STREAM_READ;
		return false;
	}
}

bool VxFileStream::write(char* pBuffer, int nLen)
{
	if (nLen == fwrite(pBuffer, 1, nLen, m_hFile))
	{
		m_nPos += nLen;
		m_nSize = max(m_nSize, m_nPos);
		return true;
	}
	else
	{
		m_nErrCode = VXERR_STREAM_WRITE;
		return false;
	}
}

int VxFileStream::pos()
{
	return m_nPos;
}

int VxFileStream::size()
{
	return m_nSize;
}

int VxFileStream::capacity()
{
	return VXSTREAM_CAPACITY_MAX;
}

FILE* VxFileStream::getHandle()
{
	return m_hFile;
}

void VxFileStream::reset()
{
	m_nPos = 0;
	m_nSize = 0;
}

void VxFileStream::flush()
{
	fflush(m_hFile);
}

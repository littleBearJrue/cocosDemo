
#include "VxLocalObject.h"


/************************************************************************/
/* VxLocalObject
/************************************************************************/
VxLocalObject::VxLocalObject(cocos2d::Ref* pObject)
	: m_pObject(pObject)
{
}

VxLocalObject::~VxLocalObject()
{
	VX_SAFE_RELEASE(m_pObject);
}


/************************************************************************/
/* VxLocalBuffer
/************************************************************************/
VxLocalBuffer::VxLocalBuffer(void* pBuffer)
{
	m_pBuffer = pBuffer;
}

VxLocalBuffer::~VxLocalBuffer()
{
	VX_SAFE_DELETE_ARRAY(m_pBuffer);
}

/************************************************************************/
/* VxLocalString
/************************************************************************/
VxLocalString::VxLocalString(int nLen)
{
	m_pString = new char[nLen + 1];
	memset(m_pString, 0, nLen + 1);
}

VxLocalString::VxLocalString(char** pDst, int nLen)
{
	m_pString = new char[nLen + 1];
	memset(m_pString, 0, nLen + 1);
	*pDst = m_pString;
}

VxLocalString::VxLocalString(char** pDst, const char* pSrc)
{
	int nLen = strlen(pSrc);
	m_pString = new char[nLen + 1];
	strcpy(m_pString, pSrc);
	*pDst = m_pString;
}

VxLocalString::VxLocalString(char** pDst, const char* pSrc, int nLen)
{
	m_pString = new char[nLen + 1];
	memset(m_pString, 0, nLen + 1);
	memcpy(m_pString, pSrc, nLen);
	m_pString[nLen] = 0;
	*pDst = m_pString;
}

VxLocalString::~VxLocalString()
{
	VX_SAFE_DELETE_ARRAY(m_pString);
}


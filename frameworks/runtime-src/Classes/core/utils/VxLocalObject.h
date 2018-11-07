
#ifndef __VX_LOCAL_OBJECT_H__
#define __VX_LOCAL_OBJECT_H__

#include "VxDef.h"


class VxMutex;

class VxLocalObject
{
public:
	VxLocalObject(cocos2d::Ref* pObject);
	~VxLocalObject();

public:
	cocos2d::Ref* m_pObject;
};


#define VX_LOCAL_OBJECT_VAR(var)		VxLocalObject VxLocalObject_##var(var)


class VxLocalBuffer
{
public:
	VxLocalBuffer(void* pBuffer);
	~VxLocalBuffer();

public:
	void* m_pBuffer;
};

#define VX_LOCAL_BUFFER_VAR(var)		VxLocalBuffer VxLocalBuffer_##var(var)

class VxLocalString
{
public:
	VxLocalString(int nLen);
	VxLocalString(char** pDst, int nLen);
	VxLocalString(char** pDst, const char* pSrc);
	VxLocalString(char** pDst, const char* pSrc, int nLen);
	~VxLocalString();
	inline char* getString()
	{
		return m_pString;
	}
protected:
	char* m_pString;
};


#endif	// __VX_AUTO_OBJECT_H__
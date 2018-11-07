
#ifndef __VX_STREAM_H__
#define __VX_STREAM_H__

#include "VxExternal.h"
#include "VxDef.h"
#include "VxConst.h"
#include "VxType.h"

class VxStream : public cocos2d::Ref
{
public:
	enum
	{
		VXSTREAM_RW_MEMORY,
		VXSTREAM_RW_CACHE,
		VXSTREAM_RW_FILE,
	};
public:
	VxStream(int nRWType);
	virtual bool seek(int nPos) = 0;
	virtual bool read(char* pBuffer, int nLen) = 0;
	virtual bool write(char* pBuffer, int nLen) = 0;
	virtual bool write(VxStream* pOther, int nLen);
	virtual bool read(VxStream* pOther, int nLen);
	virtual int pos() = 0;
	virtual int size() = 0;
	virtual int capacity() = 0;
	virtual void reset() = 0;
	virtual int readCapacity();
	virtual int writeCapacity();
	virtual void flush();
	bool fillZero(int nLen);
	int error();
	int rwType();
	void clearError();
protected:
	virtual bool checkRead(VxStream *pOther, int nLen);
	virtual bool checkWrite(VxStream *pOther, int nLen);
protected:
	int m_nErrCode;
	int m_nRWType;
};


class VxMemStream : public VxStream
{
public:
	VxMemStream(int nCapacity = 0, bool bEnlarge = true);
	VxMemStream(char* pBuffer, int nSize, int nCapacity);
	~VxMemStream();
	void init(char* pBuffer, int nSize, int nCapacity);
	bool seek(int nPos);
	bool read(char* pBuffer, int nLen);
	bool write(char* pBuffer, int nLen);
	bool write(VxStream* pOther, int nLen);
	bool read(VxStream *pOther, int nLen);
	int pos();
	int size();
	int capacity();
	void reset();
	void enlarge(bool bEnlarge);
	char* currPointer();
	void skip(int nLen);
	virtual char* buffer();
	bool advance(int nSize);
	void setBufferManaged(bool bManaged);
protected:
	virtual bool setCapacity(int nCapacity);
protected:
	int m_nPos;
	int m_nSize;
	int m_nCapacity;
	char *m_pBuffer;
	bool m_bManaged;
	bool m_bEnlarge;
};

class VxFileStream : public VxStream
{
public:
	VxFileStream(const char* pFileName, int nMode = VXFILE_OPEN_FLAG_CREATE);
	VxFileStream(FILE* phFile);
	~VxFileStream();
	bool seek(int nPos);
	bool read(char* pBuffer, int nLen);
	bool write(char* pBuffer, int nLen);
	int pos();
	int size();
	int capacity();
	void reset();
	FILE* getHandle();
	void flush();
protected:
	FILE* m_hFile;
	bool m_bManaged;
	int m_nSize;
	int m_nPos;
};


#endif	// __VX_STREAM_H__

#ifndef __VX_IO_STREAM_H__
#define __VX_IO_STREAM_H__


#include "VxStream.h"

class VxIOStream : public VxStream
{
public:
	VxIOStream(VxStream* pBaseStream);
	VxStream* GetBaseStream();
	~VxIOStream();
	bool seek(int nPos);
	bool read(char* pBuffer, int nLen);
	bool write(char* pBuffer, int nLen);
	bool write(VxStream* pOther, int nLen);
	bool read(VxStream* pOther, int nLen);
	int pos();
	int size();
	int capacity();
	void reset();
	int readCapacity();
	int writeCapacity();
	virtual bool readSkip(int nLen);
protected:
	virtual void adjust();
public:
	VxStream* m_pStream;
	int m_nReadPos;
	int m_nWritePos;
	int m_nSize;
};


class VxMemIOStream : public VxIOStream
{
public:
	VxMemIOStream(VxMemStream* pBaseStream);
	VxMemIOStream(int nCapacity, bool bEnlarge = false);
	void adjustBuffer();
	VxString readBlockBuffer(int nSize);
	int readBlockBufferSize();
};

class VxFileIOStream : public VxIOStream
{
public:
	VxFileIOStream(VxFileStream* pBaseStream);
	VxFileIOStream(const char* pFileName, int nMode);
};

class VxCacheIOStream : public VxIOStream
{
public:
	VxCacheIOStream(const char* pCacheFileName, int nBufferSize = VXSTREAM_FILE_BUFFER_DEFAULT_SIZE);
	VxCacheIOStream(int nInitCapacity, int nBufferSize = VXSTREAM_FILE_BUFFER_DEFAULT_SIZE);
	~VxCacheIOStream();
	bool seek(int nPos);
	bool read(char* pBuffer, int nLen);
	bool write(char* pBuffer, int nLen);
	bool write(VxStream* pOther, int nLen);
	bool read(VxStream* pOther, int nLen);
	int pos();
	int size();
	int capacity();
	int readCapacity();
	int writeCapacity();
	bool readSkip(int nLen);
	void flush();
	void fillReadBuffer();
	void reset();
	VxMemIOStream* getReadBuffer() { return m_pReadBuffer; }
	VxMemIOStream* getWriteBuffer() { return m_pWriteBuffer; }
	std::string getIOFilePath();
protected:
	VxMemIOStream* m_pReadBuffer;
	VxMemIOStream* m_pWriteBuffer;
	//std:: m_sFileMutex;
	std::mutex m_sFileMutex;
	std::string m_sIOFilePath;
};

#endif	// __VX_IO_STREAM_H__

#ifndef __VX_FILE_H__
#define __VX_FILE_H__

#include "VxDef.h"
#include "VxConst.h"
//#include "VxObject.h"


/************************************************************************/
/* VxFile
/************************************************************************/
class VxFile
{
public:
	static FILE* open(const char* pFileName, int nMode = VXFILE_OPEN_FLAG_CREATE);
	static void close(FILE* pFileHandle);
	static bool createDir(const char* pDir);
	static bool createDirEx(const char* pDir);			// do not use it.
	static bool isDirExist(const char* pDir);
	static bool isFileExist(const char* pFile);
	static bool fillZeroData(FILE* pFile, int zeroDataSize);
	static bool write(FILE* pFile, const char* pBuffer, int nSize);
	static bool write(FILE* pFile, int nFilePos, const char* pBuffer, int nSize);
	static bool read(FILE* pFile, char* pBuffer, int nSize);
	static bool read(FILE* pFile, int nFilePos, char* pBuffer, int nSize);
	static int getFileSize(const char* pFileName);
	static bool removeFile(const char* pFileName);
	static bool rename(const char* pSrcName, const char* pDstName);
	static bool move(const char* pScrFile, const char* pDstFile);
	static bool copy(const char* pSrcFile, const char* pDstFile);
};



#endif	// __VX_FILE_H__
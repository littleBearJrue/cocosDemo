
#ifndef __VX_MATH_H__
#define __VX_MATH_H__

#include "VxDef.h"
#include "VxConst.h"



class VxNativeUtils
{
public:

	static std::string  callAndroidString(const char* pClass, const char* pMethod, const char* pType);
	static int  callAndroidInteger(const char* pClass, const char* pMethod, const char* pType);


	static void callSystemEvent(int nKey, const char*  sJsonData);

	static void systemCallLuaEvent(int nKey, const char*  sJsonData);
};

#endif	// __VX_MATH_H__



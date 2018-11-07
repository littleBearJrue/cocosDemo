
#ifndef __VX_CONVERT_H__
#define __VX_CONVERT_H__

#include "VxDef.h"

class VxConvert
{
public:
	static int stringToInteger(const char* input);
	static int64 stringToInteger64(const char* input);
	static double stringToDouble(const char* input);
	static float stringToFloat(const char* input);
	static bool stringToBool(const char* input);
	static std::string integerToString(int input);
	static std::string integer64ToString(int64 input);
	static std::string doubleToString(double input);
	static std::string doubleToString2(double input);
	static std::string floatToString(float input);
	static std::string boolToString(bool input);
	static char* integerToChars(int input, char* buffer);
	static char* integer64ToChars(int64 input, char* buffer);
	static char* doubleToChars(double input, char* buffer);
	static char* floatToChars(float input, char* buffer);
	static char* boolToChars(bool input, char* buffer);
	static ccColor3B integerToColor(int nColor);
};

#endif	// __VX_CONVERT_H__
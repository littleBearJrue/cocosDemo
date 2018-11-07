
#include "VxConst.h"
#include "VxConvert.h"

int VxConvert::stringToInteger(const char* input)
{
	return atoi(input);
}

int64 VxConvert::stringToInteger64(const char* input)
{
	int len = strlen(input);
	
	if (len>8) {
		return 0;
	}

	uint64_t n64 = 0;
	for (int i = 0; i<(int)len; i++) {
		n64 |= (uint64_t)input[i] << (i * 8);
	}
	return n64;
}

double VxConvert::stringToDouble(const char* input)
{
	return atof(input);
}

float VxConvert::stringToFloat(const char* input)
{
	return (float)VxConvert::stringToDouble(input);
}

bool VxConvert::stringToBool(const char* input)
{
	return (!strcmp(input, VX_VALUE_STRING_TRUE));
}

std::string VxConvert::integerToString(int input)
{
	char buffer[32] = { 0 };
	VxConvert::integerToChars(input, buffer);
	return buffer;
}

std::string VxConvert::integer64ToString(int64 input)
{
	char buffer[64] = { 0 };
	VxConvert::integer64ToChars(input, buffer);
	return buffer;
}

std::string VxConvert::doubleToString(double input)
{
	char buffer[32] = { 0 };
	VxConvert::doubleToChars(input, buffer);
	return buffer;
}

std::string VxConvert::doubleToString2(double input)
{
	char buffer[32] = { 0 };
	sprintf(buffer, "%.1f", input);
	return buffer;
}

std::string VxConvert::floatToString(float input)
{
	char buffer[32] = { 0 };
	VxConvert::floatToChars(input, buffer);
	return buffer;
}

std::string VxConvert::boolToString(bool input)
{
	if(input)
	{
		return VX_VALUE_STRING_TRUE;
	}
	else
	{
		return VX_VALUE_STRING_FALSE;
	}
}

char* VxConvert::integerToChars(int input, char* buffer)
{
	sprintf(buffer, "%d", input);
	return buffer;
}

char* VxConvert::integer64ToChars(int64 input, char* buffer)
{
	sprintf(buffer, "%lld", input);
	return buffer;
}

char* VxConvert::doubleToChars(double input, char* buffer)
{
	sprintf(buffer, "%f", input);
	return buffer;
}

char* VxConvert::floatToChars(float input, char* buffer)
{
	return VxConvert::doubleToChars(input, buffer);
}

char* VxConvert::boolToChars(bool input, char* buffer)
{
	if(input)
	{
		strcpy(buffer, VX_VALUE_STRING_TRUE);
	}
	else
	{
		strcpy(buffer, VX_VALUE_STRING_FALSE);
	}
	return buffer;
}

ccColor3B VxConvert::integerToColor(int nColor)
{
	ccColor3B sRet;
	sRet.r = (nColor & (0xFF0000)) >> 16;
	sRet.g = (nColor & (0xFF00)) >> 8;
	sRet.b = (nColor & 0xFF);
	return sRet;
}

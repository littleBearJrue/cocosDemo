
#ifndef __VX_OBJECT_H__
#define __VX_OBJECT_H__

#include "VxDef.h"

class VxObject
{
protected:

	// object id
	int		m_uID;

	// count of references
	int		m_uReference;

public:

	VxObject();
	virtual ~VxObject();
	virtual void free();

	void retain();
	void release();
	bool isSingleReference(void);
	int retainCount(void);
	virtual bool isEqual(const VxObject* pObject);

	int getObjectId();
};




class VxStringObject : public VxObject
{
public:
	VxStringObject();
	VxStringObject(std::string& sString);

public:
	std::string m_sString;
};






class VxIntegerObject : public VxObject
{
public:
	VxIntegerObject(int nInteger);
public:
	int m_nInteger;
};

#endif	// __VX_OBJECT_H__
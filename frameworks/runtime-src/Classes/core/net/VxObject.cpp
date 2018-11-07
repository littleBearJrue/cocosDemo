
#include "VxDef.h"
#include "VxObject.h"

/************************************************************************/
/* VxObject
/************************************************************************/
VxObject::VxObject()
{
	static int uObjectCount = 0;

	m_uID = ++uObjectCount;

	m_uReference = 1;
}

VxObject::~VxObject()
{
	
}

void VxObject::retain()
{
	CCASSERT(m_uReference > 0, "reference count should greater than 0");

	++m_uReference;
}

void VxObject::release()
{
	CCASSERT(m_uReference > 0, "reference count should greater than 0");
	--m_uReference;

	if (m_uReference == 0)
	{
		this->free();
	}
}

void VxObject::free()
{
	delete this;
}

bool VxObject::isSingleReference(void)
{
	return m_uReference == 1;
}

int VxObject::retainCount(void)
{
	return m_uReference;
}

bool VxObject::isEqual(const VxObject* pObject)
{
	return this == pObject;
}

int VxObject::getObjectId()
{
	return m_uID;
}


/************************************************************************/
/* VxStringObject
/************************************************************************/
VxStringObject::VxStringObject()
	: m_sString("")
{
}

VxStringObject::VxStringObject(std::string& sString)
	: m_sString(sString)
{

}

/************************************************************************/
/* VxIntegerObject
/************************************************************************/
VxIntegerObject::VxIntegerObject(int nInteger)
	: m_nInteger(nInteger)
{
}
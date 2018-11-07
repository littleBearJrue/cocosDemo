
#include "NxProtocol.h"
#include "VxIOStream.h"
#include "VxMsg.h"
#include "VxLocalObject.h"

#include "VxNetClient.h"
#include "VxDef.h"

#if defined(__NX_NET_USE_FAKE_SERVER__)
#include "NxFakeServer.h"
#endif




/************************************************************************/
/* NxProtocol
/************************************************************************/

#define NXPROTOCOL_FRMAE_METAHEADER_SIZE					((int)sizeof(int))


NxProtocol::NxProtocol()
{

}

NxProtocol::~NxProtocol()
{
}

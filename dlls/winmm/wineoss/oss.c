/* -*- tab-width: 8; c-basic-offset: 4 -*- */
/*
 * Wine Driver for Open Sound System
 *
 * Copyright 	1999 Eric Pouech
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "config.h"

#include <stdarg.h>

#include "windef.h"
#include "winbase.h"
#include "wingdi.h"
#include "winuser.h"
#include "mmddk.h"
#include "oss.h"
#include "wine/debug.h"

WINE_DEFAULT_DEBUG_CHANNEL(wave);

#ifdef HAVE_OSS

/**************************************************************************
 * 				OSS_drvLoad			[internal]
 */
static LRESULT OSS_drvLoad(void)
{
    TRACE("()\n");
    OSS_WaveInit();
    OSS_MidiInit();
    OSS_MixerInit();
    OSS_AuxInit();
    return 1;
}

/**************************************************************************
 * 				OSS_drvFree			[internal]
 */
static LRESULT OSS_drvFree(void)
{
    TRACE("()\n");
    OSS_WaveExit();
    OSS_MidiExit();
    OSS_MixerExit();
    OSS_AuxExit();
    return 1;
}

/**************************************************************************
 * 				OSS_drvOpen			[internal]
 */
static LRESULT OSS_drvOpen(LPSTR str)
{
    TRACE("(%s)\n", str);
    return 1;
}

/**************************************************************************
 * 				OSS_drvClose			[internal]
 */
static LRESULT OSS_drvClose(DWORD_PTR dwDevID)
{
    TRACE("(%08lx)\n", dwDevID);
    return 1;
}

#endif


/**************************************************************************
 * 				DriverProc (WINEOSS.1)
 */
LRESULT CALLBACK OSS_DriverProc(DWORD_PTR dwDevID, HDRVR hDriv, UINT wMsg,
                                LPARAM dwParam1, LPARAM dwParam2)
{
     TRACE("(%08lX, %p, %08X, %08lX, %08lX)\n",
           dwDevID, hDriv, wMsg, dwParam1, dwParam2);

    switch(wMsg) {
#ifdef HAVE_OSS
    case DRV_LOAD:		return OSS_drvLoad();
    case DRV_FREE:		return OSS_drvFree();
    case DRV_OPEN:		return OSS_drvOpen((LPSTR)dwParam1);
    case DRV_CLOSE:		return OSS_drvClose(dwDevID);
    case DRV_ENABLE:		return 1;
    case DRV_DISABLE:		return 1;
    case DRV_QUERYCONFIGURE:	return 1;
    case DRV_CONFIGURE:		MessageBoxA(0, "OSS MultiMedia Driver !", "OSS Driver", MB_OK);	return 1;
    case DRV_INSTALL:		return DRVCNF_RESTART;
    case DRV_REMOVE:		return DRVCNF_RESTART;
#endif
    default:
	return DefDriverProc(dwDevID, hDriv, wMsg, dwParam1, dwParam2);
    }
}

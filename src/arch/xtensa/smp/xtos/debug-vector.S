// debug-vector.S  --  Debug Exception Vector
// $Id: //depot/rel/Eaglenest/Xtensa/OS/xtos/debug-vector.S#2 $

// Copyright (c) 2003-2013 Tensilica Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#include <xtensa/xtensa-versions.h>
#include <xtensa/coreasm.h>
#include <xtensa/config/specreg.h>
#ifdef SIMULATOR
#include <xtensa/simcall.h>
#endif
#include <arch/gdb/xtensa-defs.h>

#if XCHAL_HAVE_DEBUG && XCHAL_HAVE_EXCEPTIONS

	//  This code goes at the debug exception vector

	.begin	literal_prefix	.DebugExceptionVector
	.section		.DebugExceptionVector.text, "ax"
	.align 4
	.global	_DebugExceptionVector
_DebugExceptionVector:

	isync_erratum453
#if ((defined(SIMULATOR) || \
    (XCHAL_HW_MIN_VERSION >= XTENSA_HWVERSION_RE_2013_2)) \
    && !defined(CONFIG_GDB_DEBUG)) /* SIMCALL is NOP in hw? */
	//  In the simulator (ISS), let the debugger (if any is attached)
	//  handle the debug exception, else simply stop the simulation:
	//
	simcall	// have ISS handle the debug exception
# endif
# if (!defined(SIMULATOR) && !defined(CONFIG_GDB_DEBUG))
	//  For hardware, this code does not handle debug exceptions.
	//  To implement a target-side debug monitor, replace this
	//  vector with a real one that uses target-specific facilities
	//  to communicate with the debugger.
	//  
1:
	// unexpected debug exception, loop in low-power mode
	//waiti	XCHAL_DEBUGLEVEL
	j	1b		// infinite loop - unexpected debug exception
# endif /*!SIMULATOR && !CONFIG_GDB_DEBUG*/

#if defined(CONFIG_GDB_DEBUG)
	xsr	a2, DEBUG_EXCSAVE
	jx	a2
#endif

	.end	literal_prefix
	.size	_DebugExceptionVector, . - _DebugExceptionVector

#endif /* XCHAL_HAVE_DEBUG && XCHAL_HAVE_EXCEPTIONS */

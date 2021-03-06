//
// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.
//

#ifndef _JitDebugger
#define _JitDebugger

extern bool breakOnDebugBreakorAV; // It's kind of awful that I'm making this global, but it was kind of awful that it was file-global already.

//
// Functions to support just-in-time debugging.
//

BOOL GetRegistryLongValue(HKEY    hKeyParent,              // Parent key.
                          LPCWSTR szKey,                   // Key name to look at.
                          LPCWSTR szName,                  // Name of value to get.
                          long    *pValue,                 // Put value here, if found.
                          BOOL    fReadNonVirtualizedKey); // Whether to read 64-bit hive on WOW64

HRESULT GetCurrentModuleFileName(__out_ecount(*pcchBuffer) LPWSTR pBuffer, __inout DWORD *pcchBuffer);

#ifndef _WIN64
BOOL RunningInWow64();
#endif

BOOL IsCurrentModuleFileNameInAutoExclusionList();
HRESULT GetDebuggerSettingInfoWorker(__out_ecount_part_opt(*pcchDebuggerString, *pcchDebuggerString) LPWSTR wszDebuggerString, DWORD * pcchDebuggerString, BOOL * pfAuto);
void GetDebuggerSettingInfo(LPWSTR wszDebuggerString, DWORD cchDebuggerString, BOOL *pfAuto);

int DbgBreakCheck(const char* szFile, int iLine, const char* szExpr);

#endif // !_JitDebugger

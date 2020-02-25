@echo off
call "%VS140COMNTOOLS%..\..\VC\vcvarsall.bat" %* >&2

bash -c "declare -p ExtensionSdkDir Framework40Version FrameworkDir FrameworkDIR64 FrameworkVersion FrameworkVersion64 INCLUDE LIB LIBPATH NETFXSDKDir PATH Platform UCRTVersion UniversalCRTSdkDir VCINSTALLDIR VisualStudioVersion VSINSTALLDIR WindowsLibPath WindowsSdkDir WindowsSDKLibVersion WindowsSDKVersion WindowsSDK_ExecutablePath_x64 WindowsSDK_ExecutablePath_x86"

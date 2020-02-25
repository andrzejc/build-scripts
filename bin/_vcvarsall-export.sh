
commands=true
for v in ExtensionSdkDir Framework40Version FrameworkDir FrameworkDIR64 FrameworkVersion FrameworkVersion64 INCLUDE LIB LIBPATH NETFXSDKDir PATH Platform UCRTVersion UniversalCRTSdkDir VCINSTALLDIR VisualStudioVersion VSINSTALLDIR WindowsLibPath WindowsSdkDir WindowsSDKLibVersion WindowsSDKVersion WindowsSDK_ExecutablePath_x64 WindowsSDK_ExecutablePath_x86; do
    if [[ "${!v}" ]]; then
        commands+=" && "
        commands+=$( declare -p "${v}" )
    fi
done

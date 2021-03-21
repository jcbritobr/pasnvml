unit NvmlApi;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  NvLib = 'nvml.dll';

  NvmlInitFlagNoAttach = 2;
  NvmlInitFlagNoGpus = 1;
  NvmlDevicePciBusIdBufferSize = 32;
  NvmlDevicePciBusIdBufferV2Size = 16;

type
  NvHandle = PtrUInt;
  NvDeviceArchitecture = Byte;
  ENvSystemException = class(Exception);

  TNvmlTemperatureSensors = (nvTemperatureGpu = 0, nvTemperatureCount);

  TNvmlTemperatureThresholds = (nvTemperatureThresholdShutdown = 0, nvTemperatureThresholdSlowdown, nvTemperatureThresholdMemMax,
    nvTemperatureThresholdGpuMax, nvTemperatureThresholdCount);

  TNvmlReturn = (nvSuccess = 0, nvErrorUnInitialized = 1, nvErrorInvalidArgument = 2, nvErrorNotSupported =
    3, nvErrorNoPermission = 4, nvErrorAlreadyInitialized = 5,
    nvErrorNotFound = 6, nvErrorInsufficientSize = 7, nvErrorInsufficientPower = 8, nvErrorDriverNotLoaded = 9,
    nvErrorTimeout = 10, nvErrorIrqIssue = 11,
    nvErrorLibraryNotFound = 12, nvErrorFunctionNotFound = 13, nvErrorCorruptedInforom = 14, nvErrorGpuIsLost =
    15, nvErrorResetRequired = 16, nvErrorOperatingSystem = 17,
    nvErrorLibRmVersionMismatch = 18, nvErrorInUse = 19, nvErrorMemory = 20, nvErrorNoData = 21, nvErrorVgpuEccNotSupported =
    22, nvErrorInsufficientResources = 23, nvErrorUnknown = 999);

  TNvmlEnableState = (nvFeatureDisable = 0, nvFeatureEnable);

  TNvmlRestrictedApi = (nvRestrictedApiSetApplicationClock = 0, nvRestrictedApiSetAutoBoostedClocks, nvRestrictedApiCount);

  TNvmlClockType = (nvClockGraphics = 0, nvClockSm, nvClockMem, nvClockVideo, nvClockCount);

  TNvmlDeviceAttributes = record
    MultiprocessorCount: Cardinal;
    SharedCopyEngineCount: Cardinal;
    SharedDecoderCount: Cardinal;
    SharedEncoderCount: Cardinal;
    SharedJpegCount: Cardinal;
    SharedOfaCount: Cardinal;
    GpuInstanceSliceCount: Cardinal;
    ComputeInstanceSliceCount: Cardinal;
    MemorySizeMB: UInt64;
  end;

  TNvmlPciInfo = record
    BusIdLegacy: array [0..NvmlDevicePciBusIdBufferV2Size] of Int8;
    Domain: Cardinal;
    Bus: Cardinal;
    Device: Cardinal;
    PciSubSystemId: Cardinal;
    BusId: array [0..NvmlDevicePciBusIdBufferSize] of Int8;
  end;

procedure NvInitWithFlags(flags: Cardinal);
procedure NvInitV2;
procedure NvShutDown;
function NvCudaDriverVersionMajor(version: Integer): Integer;
function NvSystemGetCudaDriverVersion: Integer;
function NvmlSystemGetCudaDriverVersionV2: Integer;
function NvSystemGetDriverVersion(length: Cardinal = 20): Ansistring;
function NvSystemGetNVMLVersion(Length: Cardinal = 20): Ansistring;
function NvDeviceGetHandleByIndexV2(index: Cardinal): NvHandle;
function NvDeviceGetAPIRestriction(device: NvHandle; apiType: TNvmlRestrictedApi): TNvmlEnableState;
function NvDeviceGetApplicationsClock(device: NvHandle; clockType: TNvmlClockType): Cardinal;
function NvDeviceGetArchitecture(device: NvHandle): NvDeviceArchitecture;
function NvDeviceGetAttributes(device: NvHandle): TNvmlDeviceAttributes;

function NvDeviceGetPciInfoV3(device: NvHandle): TNvmlPciInfo;
function NvDeviceGetName(device: NvHandle; length: Cardinal = 20): String;
function NvDeviceGetCountV2: Cardinal;
function NvDeviceGetTemperature(device: NvHandle; sensorType: TNvmlTemperatureSensors): Cardinal;
function NvDeviceGetTemperatureThreshold(device: NvHandle; thresholdType: TNvmlTemperatureThresholds): Cardinal;
function NvDeviceGetClockInfo(Device: NvHandle; ClockType: TNvmlClockType): Cardinal;


implementation

function nvmlInitWithFlags(flags: Cardinal): TNvmlReturn; cdecl; external NvLib;
function nvmlInit_v2: TNvmlReturn; cdecl; external NvLib;
function nvmlShutdown: TNvmlReturn; cdecl; external NvLib;
function nvmlSystemGetCudaDriverVersion(out cudaDriverVersion: Integer): TNvmlReturn;
  cdecl; external NvLib;
function nvmlSystemGetCudaDriverVersion_v2(out cudaDriverVersion: Integer): TNvmlReturn;
  cdecl; external NvLib;
function nvmlSystemGetDriverVersion(version: PChar; length: Cardinal): TNvmlReturn;
  cdecl; external NvLib;
function nvmlSystemGetNVMLVersion(version: PChar; length: Cardinal): TNvmlReturn;
  cdecl; external NvLib;
function nvmlSystemGetProcessName(pid: Byte; Name: PChar; length: Cardinal): TNvmlReturn;
  cdecl; external NvLib;
function nvmlDeviceGetHandleByIndex_v2(index: Cardinal; out device: NvHandle): TNvmlReturn; cdecl; external NvLib;
function nvmlDeviceGetAPIRestriction(device: NvHandle; apiType: TNvmlRestrictedApi; out isRestricted: TNvmlEnableState): TNvmlReturn;
  cdecl; external NvLib;
function nvmlDeviceGetApplicationsClock(device: NvHandle; clockType: TNvmlClockType; out clockMHz: Cardinal): TNvmlReturn; cdecl; external NvLib;
function nvmlDeviceGetArchitecture(device: NvHandle; out arch: NvDeviceArchitecture): TNvmlReturn; cdecl; external NvLib;
function nvmlDeviceGetAttributes(device: NvHandle; out attributes: TNvmlDeviceAttributes): TNvmlReturn; cdecl; external NvLib;

function nvmlDeviceGetPciInfo_v3(device: NvHandle; out pci: TNvmlPciInfo): TNvmlReturn;
  cdecl; external NvLib;
function nvmlDeviceGetName(device: NvHandle; deviceName: PChar; length: Cardinal): TNvmlReturn; cdecl; external NvLib;
function nvmlDeviceGetCount_v2(out deviceCount: Cardinal): TNvmlReturn;
  cdecl; external NvLib;
function nvmlDeviceGetTemperature(device: NvHandle; sensorType: TNvmlTemperatureSensors; out temp: Cardinal): TNvmlReturn; cdecl; external NvLib;
function nvmlDeviceGetTemperatureThreshold(device: NvHandle; thresholdType: TNvmlTemperatureThresholds; out temp: Cardinal): TNvmlReturn;
  cdecl; external NvLib;
function nvmlDeviceGetClockInfo(Device: NvHandle; ClockType: TNvmlClockType; out clock: Cardinal): TNvmlReturn; cdecl; external NvLib;

procedure NvInitWithFlags(flags: Cardinal);
var
  res: TNvmlReturn;
  ex: String;
begin
  res := nvmlInitWithFlags(flags);
  if nvSuccess <> res then
  begin
    WriteStr(ex, res);
    raise ENvSystemException.Create(ex);
  end;
end;

procedure NvInitV2;
var
  res: TNvmlReturn;
  ex: String;
begin
  res := nvmlInit_v2;
  if nvSuccess <> res then
  begin
    WriteStr(ex, res);
    raise ENvSystemException.Create(ex);
  end;
end;

procedure NvShutDown;
var
  res: TNvmlReturn;
  ex: String;
begin
  res := nvmlShutdown;
  if nvSuccess <> res then
  begin
    WriteStr(ex, res);
    raise ENvSystemException.Create(ex);
  end;
end;

function NvCudaDriverVersionMajor(version: Integer): Integer;
begin
  Result := version div 1000;
end;

function NvmlSystemGetCudaDriverVersionV2: Integer;
var
  version: Integer;
  ex: String;
  res: TNvmlReturn;
begin
  res := nvmlSystemGetCudaDriverVersion(version);
  if nvSuccess <> res then
  begin
    WriteStr(ex, res);
    raise ENvSystemException.Create(ex);
  end;
  Result := version;
end;

function NvSystemGetDriverVersion(length: Cardinal): Ansistring;
var
  version: PChar;
  res: TNvmlReturn;
  ex: String;
begin
  version := StrAlloc(length);
  res := nvmlSystemGetDriverVersion(version, length);
  if nvSuccess <> res then
  begin
    WriteStr(ex, res);
    StrDispose(version);
    raise ENvSystemException.Create(ex);
  end;
  Result := version;
  StrDispose(version);
end;

function NvSystemGetNVMLVersion(Length: Cardinal): Ansistring;
var
  version: PChar;
  res: TNvmlReturn;
  ex: String;
begin
  version := StrAlloc(Length);
  res := nvmlSystemGetNVMLVersion(version, Length);
  if nvSuccess <> res then
  begin
    WriteStr(ex, res);
    StrDispose(version);
    raise ENvSystemException.Create(ex);
  end;
  Result := version;
  StrDispose(version);
end;

function NvDeviceGetHandleByIndexV2(index: Cardinal): NvHandle;
var
  handle: NvHandle;
  res: TNvmlReturn;
  ex: String;
begin
  handle := 0;
  res := nvmlDeviceGetHandleByIndex_v2(index, handle);
  if nvSuccess <> res then
  begin
    WriteStr(ex, res);
    raise ENvSystemException.Create(ex);
  end;
  Result := handle;
end;

function NvDeviceGetAPIRestriction(device: NvHandle; apiType: TNvmlRestrictedApi): TNvmlEnableState;
var
  state: TNvmlEnableState;
  ex: String;
  res: TNvmlReturn;
begin
  res := nvmlDeviceGetAPIRestriction(device, apiType, state);
  if nvSuccess <> res then
  begin
    WriteStr(ex, res);
    raise ENvSystemException.Create(ex);
  end;
  Result := state;
end;

function NvDeviceGetApplicationsClock(device: NvHandle; clockType: TNvmlClockType): Cardinal;
var
  clock: Cardinal;
  res: TNvmlReturn;
  ex: String;
begin
  res := nvmlDeviceGetApplicationsClock(device, clockType, clock);
  if nvSuccess <> res then
  begin
    WriteStr(ex, res);
    raise ENvSystemException.Create(ex);
  end;
  Result := clock;
end;

function NvDeviceGetArchitecture(device: NvHandle): NvDeviceArchitecture;
var
  res: TNvmlReturn;
  arch: NvDeviceArchitecture;
  ex: String;
begin
  res := nvmlDeviceGetArchitecture(device, arch);
  if nvSuccess <> res then
  begin
    WriteStr(ex, res);
    raise ENvSystemException.Create(ex);
  end;
  Result := arch;
end;

function NvDeviceGetAttributes(device: NvHandle): TNvmlDeviceAttributes;
var
  res: TNvmlReturn;
  attributes: TNvmlDeviceAttributes;
  ex: String;
begin
  res := nvmlDeviceGetAttributes(device, attributes);
  if nvSuccess <> res then
  begin
    WriteStr(ex, res);
    raise ENvSystemException.Create(ex);
  end;
  Result := attributes;
end;

function NvDeviceGetPciInfoV3(device: NvHandle): TNvmlPciInfo;
var
  res: TNvmlReturn;
  info: TNvmlPciInfo;
  ex: String;
begin
  res := nvmlDeviceGetPciInfo_v3(device, info);
  if nvSuccess <> res then
  begin
    WriteStr(ex, res);
    raise ENvSystemException.Create(ex);
  end;
  Result := info;
end;

function NvDeviceGetName(device: NvHandle; length: Cardinal): String;
var
  res: TNvmlReturn;
  ex: String;
  deviceName: PChar;
begin
  deviceName := StrAlloc(length);
  res := nvmlDeviceGetName(device, deviceName, length);
  if nvSuccess <> res then
  begin
    WriteStr(ex, res);
    StrDispose(deviceName);
    raise ENvSystemException.Create(ex);
  end;
  Result := deviceName;
  StrDispose(deviceName);
end;

function NvDeviceGetCountV2: Cardinal;
var
  Count: Cardinal;
  ex: String;
  res: TNvmlReturn;
begin
  res := nvmlDeviceGetCount_v2(Count);
  if nvSuccess <> res then
  begin
    WriteStr(ex, res);
    raise ENvSystemException.Create(ex);
  end;
  Result := Count;
end;

function NvDeviceGetTemperature(device: NvHandle; sensorType: TNvmlTemperatureSensors): Cardinal;
var
  temp: Cardinal;
  ex: String;
  res: TNvmlReturn;
begin
  temp := 0;
  res := nvmlDeviceGetTemperature(device, sensorType, temp);
  if nvSuccess <> res then
  begin
    WriteStr(ex, res);
    raise ENvSystemException.Create(ex);
  end;
  Result := temp;
end;

function NvDeviceGetTemperatureThreshold(device: NvHandle; thresholdType: TNvmlTemperatureThresholds): Cardinal;
var
  temp: Cardinal;
  ex: String;
  res: TNvmlReturn;
begin
  temp := 0;
  res := nvmlDeviceGetTemperatureThreshold(device, thresholdType, temp);
  if nvSuccess <> res then
  begin
    WriteStr(ex, res);
    raise ENvSystemException.Create(ex);
  end;
  Result := temp;
end;

function NvDeviceGetClockInfo(Device: NvHandle; ClockType: TNvmlClockType): Cardinal;
var
  Ex: String;
  Res: TNvmlReturn;
  Speed: Cardinal;
begin
  Res := nvmlDeviceGetClockInfo(Device, ClockType, Speed);
  if nvSuccess <> res then
  begin
    WriteStr(Ex, Res);
    raise ENvSystemException.Create(Ex);
  end;
  Result:= Speed;
end;

function NvSystemGetCudaDriverVersion: Integer;
var
  version: Integer;
  ex: String;
  res: TNvmlReturn;
begin
  res := nvmlSystemGetCudaDriverVersion(version);
  if nvSuccess <> res then
  begin
    WriteStr(ex, res);
    raise ENvSystemException.Create(ex);
  end;
  Result := version;
end;

end.

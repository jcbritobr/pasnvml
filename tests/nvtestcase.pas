unit NvTestCase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, NvmlApi, fpcunit, testutils, testregistry;

type

  { TNvTestCase }

  TNvTestCase = class(TTestCase)
  private
    function CheckNotSupported(Exception: String): Boolean;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestInitializationAndCleanUp;
    procedure TestGetCudaDriverVersion;
    procedure TestGetDriverVersion;
    procedure TestGetNVMLVersion;
    procedure TestGetHandleByIndexV2;
    procedure TestDeviceGetAPIRestriction;
    procedure TestDeviceGetApplicationsClock;
    procedure TestDeviceGetArchitecture;
    procedure TestDeviceGetAttributes;
    procedure TestDeviceGetPciInfoV3;
    procedure TestNvDeviceGetName;
    procedure TestNvDeviceGetCountV2;
    procedure TestNvDeviceGetTemperature;
    procedure TestNvDeviceGetTemperatureThreshold;
    procedure TestNvDeviceGetClockInfo;

  end;

implementation

procedure TNvTestCase.TestInitializationAndCleanUp;
begin
  NvInitWithFlags(NvmlInitFlagNoAttach or NvmlInitFlagNoGpus);
  NvShutDown;
  NvInitV2;
  NvShutDown;
end;

procedure TNvTestCase.TestGetCudaDriverVersion;
var
  version, major: Integer;
begin
  try
    NvInitV2;
    version := NvSystemGetCudaDriverVersion();
    major := NvCudaDriverVersionMajor(version);
    version := NvmlSystemGetCudaDriverVersionV2;
    if major = 0 then
    begin
      raise EArgumentException.Create('Something may fail acquiring cuda version. Length is zero');
    end;
    NvShutDown;
  except
    on E: ENvSystemException do
    begin
      NvShutDown;
      Fail(e.Message);
    end;
  end;
end;

procedure TNvTestCase.TestGetDriverVersion;
var
  version: Ansistring;
begin
  try
    NvInitV2;
    version := NvSystemGetDriverVersion;
    if Length(version) = 0 then
    begin
      raise ENvSystemException.Create('Something may fail acquiring driver version. Length is zero');
    end;
    NvShutDown;
  except
    on E: ENvSystemException do
    begin
      NvShutDown;
      Fail(e.Message);
    end;
  end;
end;

procedure TNvTestCase.TestGetNVMLVersion;
var
  version: Ansistring;
begin
  try
    NvInitV2;
    version := NvSystemGetNVMLVersion;
    if Length(version) = 0 then
    begin
      raise ENvSystemException.Create('Something may fail acquiring nvml version. Length is zero');
    end;
    NvShutDown;
  except
    on E: ENvSystemException do
    begin
      NvShutDown;
      Fail(e.Message);
    end;
  end;
end;

procedure TNvTestCase.TestGetHandleByIndexV2;
var
  handle: NvHandle;
begin
  try
    NvInitV2;
    handle := NvDeviceGetHandleByIndexV2(0);
    if handle = 0 then
      raise ENvSystemException.Create('Handle cant be zero');
    NvShutDown;
  except
    on E: ENvSystemException do
    begin
      NvShutDown;
      Fail(e.Message);
    end;
  end;
end;

procedure TNvTestCase.TestDeviceGetAPIRestriction;
var
  handle: NvHandle;
  state: TNvmlEnableState;
begin
  try
    NvInitV2;
    handle := NvDeviceGetHandleByIndexV2(0);
    state := NvDeviceGetAPIRestriction(handle, TNvmlRestrictedApi.nvRestrictedApiSetApplicationClock);
  except
    on E: ENvSystemException do
    begin
      NvShutDown;
      if not CheckNotSupported(e.Message) then
        Fail(e.Message);
    end;
  end;
end;

procedure TNvTestCase.TestDeviceGetApplicationsClock;
var
  handle: NvHandle;
  clock: Cardinal;
begin
  try
    NvInitV2;
    handle := NvDeviceGetHandleByIndexV2(0);
    clock := NvDeviceGetApplicationsClock(handle, TNvmlClockType.nvClockMem);
    NvShutDown;
  except
    on E: ENvSystemException do
    begin
      NvShutDown;
      if not CheckNotSupported(e.Message) then
        Fail(e.Message);
    end;
  end;
end;

procedure TNvTestCase.TestDeviceGetArchitecture;
var
  handle: NvHandle;
  arch: NvDeviceArchitecture;
begin
  try
    NvInitV2;
    handle := NvDeviceGetHandleByIndexV2(0);
    arch := NvDeviceGetArchitecture(handle);
    NvShutDown;
  except
    on E: ENvSystemException do
    begin
      NvShutDown;
      Fail(e.Message);
    end;
  end;
end;

procedure TNvTestCase.TestDeviceGetAttributes;
var
  handle: NvHandle;
  attr: TNvmlDeviceAttributes;
begin
  try
    NvInitV2;
    handle := NvDeviceGetHandleByIndexV2(0);
    attr := NvDeviceGetAttributes(handle);
    NvShutDown;
  except
    on E: ENvSystemException do
    begin
      NvShutDown;
      if not CheckNotSupported(e.Message) then
        Fail(e.Message);
    end;
  end;
end;

procedure TNvTestCase.TestDeviceGetPciInfoV3;
var
  handle: NvHandle;
  info: TNvmlPciInfo;
begin
  try
    NvInitV2;
    handle := NvDeviceGetHandleByIndexV2(0);
    info := NvDeviceGetPciInfoV3(handle);
    NvShutDown;
  except
    on E: ENvSystemException do
    begin
      NvShutDown;
      Fail(e.Message);
    end;
  end;
end;

procedure TNvTestCase.TestNvDeviceGetName;
var
  handle: NvHandle;
  Name: String;
begin
  try
    NvInitV2;
    handle := NvDeviceGetHandleByIndexV2(0);
    Name := NvDeviceGetName(handle);
    NvShutDown;
  except
    on E: ENvSystemException do
    begin
      NvShutDown;
      Fail(e.Message);
    end;
  end;
end;

procedure TNvTestCase.TestNvDeviceGetCountV2;
var
  Count: Cardinal;
begin
  try
    NvInitV2;
    Count := NvDeviceGetCountV2;
    NvShutDown;
  except
    on E: ENvSystemException do
    begin
      NvShutDown;
      Fail(e.Message);
    end;
  end;
end;

procedure TNvTestCase.TestNvDeviceGetTemperature;
var
  device: NvHandle;
  temp: Cardinal;
begin
  try
    NvInitV2;
    device := NvDeviceGetHandleByIndexV2(0);
    temp := NvDeviceGetTemperature(device, nvTemperatureGpu);
    NvShutDown;
  except
    On E: ENvSystemException do
    begin
      NvShutDown;
      Fail(e.Message);
    end;
  end;
end;

procedure TNvTestCase.TestNvDeviceGetTemperatureThreshold;
var
  device: NvHandle;
  temp: Cardinal;
begin
  try
    NvInitV2;
    device := NvDeviceGetHandleByIndexV2(0);
    temp := NvDeviceGetTemperatureThreshold(device, nvTemperatureThresholdGpuMax);
    NvShutDown;
  except
    On E: ENvSystemException do
    begin
      NvShutDown;
      Fail(e.Message);
    end;
  end;
end;

procedure TNvTestCase.TestNvDeviceGetClockInfo;
var
  Device: NvHandle;
  Speed: Cardinal;
begin
  try
    NvInitV2;
    Device := NvDeviceGetHandleByIndexV2(0);
    Speed := NvDeviceGetClockInfo(Device, TNvmlClockType.nvClockGraphics);
    Speed := NvDeviceGetClockInfo(Device, TNvmlClockType.nvClockMem);
    Speed := NvDeviceGetClockInfo(Device, TNvmlClockType.nvClockSm);
    Speed := NvDeviceGetClockInfo(Device, TNvmlClockType.nvClockVideo);
    NvShutDown;
  except
    On E: ENvSystemException do
    begin
      NvShutDown;
      Fail(e.Message);
    end;
  end;
end;

function TNvTestCase.CheckNotSupported(Exception: String): Boolean;
begin
  Result := 'nvErrorNotSupported' = Exception;
end;


procedure TNvTestCase.SetUp;
begin

end;

procedure TNvTestCase.TearDown;
begin

end;

initialization

  RegisterTest(TNvTestCase);
end.

unit NvInfo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, NvmlApi;

type

  { TNvInfoSingleton }

  TNvInfoSingleton = class
  private
    FDevice: NvHandle;
    FDeviceName: String;
    FNvmlVersion: String;
    FDriverVersion: String;
    FCudaDriverVersion: Integer;
    FCudaDriverVersionMajor: Integer;
    FDeviceTemperature: Integer;
    FDeviceTemperatureThreshold: Integer;
    FDeviceClockGraphics: Cardinal;
    FDeviceClockMemory: Cardinal;
  public
    class function NewInstance: TObject; override;
    procedure InitDevice;
    procedure UpdateSystemInfo;
    procedure UpdateCudaInfo;
    procedure UpdateTemperatureInfo;
    procedure UpdateClockInfo;
    property DeviceName: String read FDeviceName write FDeviceName;
    property DriverVersion: String read FDriverVersion write FDriverVersion;
    property NvmlVersion: String read FNvmlVersion write FNvmlVersion;
    property CudaDriverVersionMajor: Integer read FCudaDriverVersionMajor write FCudaDriverVersionMajor;
    property CudaDriverVersion: Integer read FCudaDriverVersion write FCudaDriverVersion;
    property DeviceTemperature: Integer read FDeviceTemperature write FDeviceTemperature;
    property DeviceTemperatureThreshold: Integer read FDeviceTemperatureThreshold write FDeviceTemperatureThreshold;
    property DeviceClockGraphics: Cardinal read FDeviceClockGraphics write FDeviceClockGraphics;
    property DeviceClockMemory: Cardinal read FDeviceClockMemory write FDeviceClockMemory;
  end;

implementation

var
  Instance: TObject = nil;

{ TNvInfoSingleton }

class function TNvInfoSingleton.NewInstance: TObject;
begin
  if not Assigned(Instance) then
  begin
    Instance := inherited NewInstance;
    (Instance as TNvInfoSingleton).InitDevice;
  end;
  Result := Instance;
end;

procedure TNvInfoSingleton.InitDevice;
begin
  FDevice := NvDeviceGetHandleByIndexV2(0);
end;

procedure TNvInfoSingleton.UpdateSystemInfo;
begin
  try
    FDeviceName := NvDeviceGetName(FDevice);
    FDriverVersion := NvSystemGetDriverVersion;
    FNvmlVersion := NvSystemGetNVMLVersion;
  except
    On E: ENvSystemException do
      raise ENvSystemException.Create(E.Message);
  end;
end;

procedure TNvInfoSingleton.UpdateCudaInfo;
begin
  try
    FCudaDriverVersion := NvSystemGetCudaDriverVersion;
    FCudaDriverVersionMajor := NvCudaDriverVersionMajor(FCudaDriverVersion);
  except
    On E: ENvSystemException do
      raise ENvSystemException.Create(E.Message);
  end;
end;

procedure TNvInfoSingleton.UpdateTemperatureInfo;
begin
  try
    FDeviceTemperature := NvDeviceGetTemperature(FDevice, nvTemperatureGpu);
    FDeviceTemperatureThreshold := NvDeviceGetTemperatureThreshold(FDevice, nvTemperatureThresholdGpuMax);
  except
    On E: ENvSystemException do
      raise ENvSystemException.Create(E.Message);
  end;
end;

procedure TNvInfoSingleton.UpdateClockInfo;
begin
  try
    FDeviceClockGraphics:= NvDeviceGetClockInfo(FDevice, nvClockGraphics);
    FDeviceClockMemory:= NvDeviceGetClockInfo(FDevice, nvClockMem);
  except
    raise;
  end;
end;

initialization
  NvInitV2;

finalization
  NvShutDown;
  FreeAndNil(Instance);

end.

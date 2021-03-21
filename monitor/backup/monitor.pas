unit Monitor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, NvInfo, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Spin;

type

  { TFrmMonitor }

  TFrmMonitor = class(TForm)
    BtnUpdateTimer: TButton;
    BtnStartTimer: TButton;
    BtnStopTimer: TButton;
    GrClock: TGroupBox;
    GrGpuTemperature: TGroupBox;
    GrCuda: TGroupBox;
    GrRefreshRate: TGroupBox;
    ImgLogo: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LblClockGraphics: TLabel;
    LblClockMemory: TLabel;
    LblClockGraphicsData: TLabel;
    LblClockMemData: TLabel;
    LblCudaDriverVersionData: TLabel;
    LblCudaDriverVersionMajorData: TLabel;
    LblCudaDriverVersionMjor: TLabel;
    LblCudaDriverVersion: TLabel;
    LblThresholdData: TLabel;
    LblTemperatureData: TLabel;
    LblTemperature: TLabel;
    LblDeviceNameData: TLabel;
    LblNvmlVersionData: TLabel;
    LblDriverVersionData: TLabel;
    LblDeviceIndex: TLabel;
    LblDriverVersion: TLabel;
    LblDevice: TLabel;
    Panel1: TPanel;
    ShStatus: TShape;
    SpnRefreshRate: TSpinEdit;
    TmrUpdater: TTimer;
    procedure BtnStartTimerClick(Sender: TObject);
    procedure BtnStopTimerClick(Sender: TObject);
    procedure BtnUpdateTimerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TmrUpdaterTimer(Sender: TObject);
  private

  public
    procedure UpdateSystemInfo;
    procedure UpdateCudaInfo;
    procedure UpdateTemperatureInfo;
    procedure UpdateClockInfo;
  end;

var
  FrmMonitor: TFrmMonitor;
  Status: Boolean = False;

implementation

{$R *.lfm}

{ TFrmMonitor }

procedure TFrmMonitor.TmrUpdaterTimer(Sender: TObject);
begin
  TThread.Queue(nil, @UpdateTemperatureInfo);
  TThread.Queue(nil, @UpdateClockInfo);
  if Status then
    ShStatus.Brush.Color := clLime
  else
    ShStatus.Brush.Color := clGray;

  Status := not Status;
end;

procedure TFrmMonitor.FormCreate(Sender: TObject);
begin
  TThread.Queue(nil, @UpdateSystemInfo);
  TThread.Queue(nil, @UpdateCudaInfo);
end;

procedure TFrmMonitor.BtnStartTimerClick(Sender: TObject);
begin
  if not TmrUpdater.Enabled then
    TmrUpdater.Enabled := True;
end;

procedure TFrmMonitor.BtnStopTimerClick(Sender: TObject);
begin
  if TmrUpdater.Enabled then
    TmrUpdater.Enabled := False;
end;

procedure TFrmMonitor.BtnUpdateTimerClick(Sender: TObject);
begin
  TmrUpdater.Interval := SpnRefreshRate.Value;
end;

procedure TFrmMonitor.UpdateSystemInfo;
var
  info: TObject;
begin
  info := TNvInfoSingleton.NewInstance;
  try
    (info as TNvInfoSingleton).UpdateSystemInfo;
    LblDriverVersionData.Caption := (info as TNvInfoSingleton).DriverVersion;
    LblDeviceNameData.Caption := (info as TNvInfoSingleton).DeviceName;
    LblNvmlVersionData.Caption := (info as TNvInfoSingleton).NvmlVersion;
  except
    LblDriverVersionData.Caption := '';
    LblDeviceNameData.Caption := '';
    LblNvmlVersionData.Caption := '';
  end;
end;

procedure TFrmMonitor.UpdateCudaInfo;
var
  info: TObject;
begin
  info := TNvInfoSingleton.NewInstance;
  try
    (info as TNvInfoSingleton).UpdateCudaInfo;
    LblCudaDriverVersionData.Caption :=
      (info as TNvInfoSingleton).CudaDriverVersion.ToString;
    LblCudaDriverVersionMajorData.Caption :=
      (info as TNvInfoSingleton).CudaDriverVersionMajor.ToString;
  except
    LblCudaDriverVersion.Caption := '';
    LblCudaDriverVersionMajorData.Caption := '';
  end;
end;

procedure TFrmMonitor.UpdateTemperatureInfo;
var
  info: TObject;
begin
  info := TNvInfoSingleton.NewInstance;
  try
    (info as TNvInfoSingleton).UpdateTemperatureInfo;
    LblTemperatureData.Caption :=
      (info as TNvInfoSingleton).DeviceTemperature.ToString;
    LblThresholdData.Caption :=
      (info as TNvInfoSingleton).DeviceTemperatureThreshold.ToString;
  except
    LblTemperatureData.Caption := '';
    LblThresholdData.Caption := '';
  end;
end;

procedure TFrmMonitor.UpdateClockInfo;
var
  info: TObject;
begin
  info := TNvInfoSingleton.NewInstance;
  try
    (info as TNvInfoSingleton).UpdateClockInfo;
    LblClockGraphicsData.Caption :=
      (info as TNvInfoSingleton).DeviceClockGraphics.ToString;
    LblClockMemData.Caption :=
      (info as TNvInfoSingleton).DeviceClockMemory.ToString;
  except
    LblClockGraphicsData.Caption := '';
    LblClockMemData.Caption := '';
  end;
end;

end.

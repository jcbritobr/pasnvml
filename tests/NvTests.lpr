program NvTests;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, NvTestCase;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.


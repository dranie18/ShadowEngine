unit uEasyDevice;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Edit, FMX.Ani, FMX.Controls3D, FMX.Layers3D,
  FMX.Effects, System.IOUtils, FMX.Platform, FMX.VirtualKeyboard;

  function getDisplaySizeInPx: tPointF;
  function getScreenScale: single;
  function getMinLength: single;
  function getDisplaySizeInDp: tPointF;
  function MousePos: TPointF;
  function LoadImageFromFile(AFileName: String): TBitmap; // ��������� ������ �� ���� �������������� �� ��������
  function UniPath(const AFileName: String): String; // ��� ������������� ���� ��� ����������� �� ���������
  function ReturnPressed(var AKey: Word): Boolean;
  procedure StrStartEnd(const AString: String; var AStart, AEnd: Integer);
  procedure StopApplication;

implementation

function MousePos: TPointF;
var
  MouseService: IFMXMouseService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXMouseService, IInterface(MouseService)) then
    Exit(MouseService.GetMousePos);
  Result := PointF(0, 0);
end;

procedure StopApplication;
begin
  Application.Terminate;
end;

function ReturnPressed(var AKey: Word): Boolean;
begin
  {$IFDEF ANDROID}
  if (AKey = vkHardwareBack) or (AKey = vkReturn) then
 { begin
    TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService, IInterface(FService));
    if (FService <> nil) and
      (TVirtualKeyboardState.Visible in FService.VirtualKeyBoardState)
    then }begin
      Exit(True);
    end;
  {$ENDIF}
  {$IFDEF WIN32}
   if AKey = 27 then
     Exit(True);
  {$ENDIF}
  Result := False;
end;

// � ��������� ������� ���������� � 0, � �� � 1 ��� � �����
procedure StrStartEnd(const AString: String; var AStart, AEnd: Integer);
begin
 {$IFDEF WIN32}
 AStart := 1;
 AEnd := Length(AString);
{$ENDIF WIN32}
{$IFDEF ANDROID}
 AStart := 0;
 AEnd := Length(AString) - 1;
{$ENDIF ANDROID}
end;

function getDisplaySizeInDp: tPointF;
var
  ScreenSvc: IFMXScreenService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService,
    IInterface(ScreenSvc)) then
    Result := ScreenSvc.GetScreenSize;
end;

function getDisplaySizeInPx: tPointF;
var
  res: tPointF;
  screenSizeInDp: tPointF;
  ScreenSvc: IFMXScreenService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService,
    IInterface(ScreenSvc)) then
  begin
    screenSizeInDp := ScreenSvc.GetScreenSize;
    res.X := screenSizeInDp.X * ScreenSvc.getScreenScale;
    res.Y := screenSizeInDp.Y * ScreenSvc.getScreenScale;
  end;

  result := res;
end;

function UniPath(const AFileName: String): String;
var
  vS: String;
begin
  vS := AFileName;
  {$IFDEF WIN32}
    vS := 'art\'+AFileName;
  {$ENDIF WIN32}
  {$IFDEF ANDROID}
//    vS := TPath.Combine(TPath.GetSharedDocumentsPath, AFileName); { ������� ������ }
    vS := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, AFileName); { ���������� ������ }

  {$ENDIF ANDROID}
  Result := vS;
end;

function LoadImageFromFile(AFileName: String): TBitmap;
var
  vBMP: TBitmap;
  {$IFDEF ANDROID}
  vs: String;
  {$ENDIF ANDROID}
begin
  vBMP := tBitmap.Create;
  {$IFDEF WIN32}
    vBMP.LoadFromFile(AFileName);
  {$ENDIF WIN32}
  {$IFDEF ANDROID}
    vS := TPath.Combine(TPath.GetDocumentsPath, AFileName); { ���������� ������}
    vBMP.LoadFromFile(vS);
  {$ENDIF ANDROID}
  Result := vBMP;
end;

function getScreenScale: single;
var
//  screenSizeInDp: tPointF;
  ScreenSvc: IFMXScreenService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService,
    IInterface(ScreenSvc)) then
  begin
    result := ScreenSvc.getScreenScale;
  end else
    Result := 1;
end;

function getMinLength: single;
var
  screenSizeInPx: tPointF;
begin
  screenSizeInPx := getDisplaySizeInPx;

  if screenSizeInPx.X > screenSizeInPx.Y then
    result:=screenSizeInPx.Y
  else
    result:=screenSizeInPx.X;

end;

end.

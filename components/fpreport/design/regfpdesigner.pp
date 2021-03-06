{
    This file is part of the Free Component Library.
    Copyright (c) 2017 Michael Van Canneyt, member of the Free Pascal development team

    Report data component property editor for object inspector.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
unit regfpdesigner;

{$mode objfpc}{$H+}

interface

uses
  fpttf, Graphics, GraphPropEdits, Classes, SysUtils, dialogs, fpreport, ideintf, propedits, ObjInspStrConsts, frmfpreportmemoedit;

Type

  { TReportFontPropertyEditor }

  TReportFontPropertyEditor = class(TClassPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  { TFPreportColorPropertyEditor }

  TFPreportColorPropertyEditor = Class(TColorPropertyEditor)
  public
    function OrdValueToVisualValue(OrdValue: longint): string; override;
    procedure SetValue(const NewValue: ansistring); override;
  end;
  { TReportFontNamePropertyEditor }

  TReportFontNamePropertyEditor = class(TFontNamePropertyEditor)
  public
    procedure SetValue(const NewValue: ansistring); override;
  end;

  { TPaperNamePropertyEditor }

  TPaperNamePropertyEditor = class(TStringPropertyEditor)
  Public
    procedure GetValues(Proc: TGetStrProc); override;
    Function GetAttributes: TPropertyAttributes; override;
  end;


  { TReportComponentPropertyEditor }

  TReportComponentPropertyEditor = class(TComponentPropertyEditor)
  Protected
    Function GetReport : TFPCustomReport;
    Function GetPage : TFPReportCustomPage;
  end;

  { TDataComponentPropertyEditor }

  TDataComponentPropertyEditor = class(TReportComponentPropertyEditor)
  Public
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const NewValue: ansistring); override;
  end;

  { TReportBandPropertyEditor }

  TReportBandPropertyEditor = class(TReportComponentPropertyEditor)
  protected
    function BandAllowed(B: TFPReportCustomBand): Boolean; virtual;
  Public
    Function BandTypes : TFPReportBandTypes; virtual;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const NewValue: ansistring); override;
  end;

  { TChildBandPropertyEditor }

  TChildBandPropertyEditor = Class(TReportBandPropertyEditor)
  Public
    function BandAllowed(B: TFPReportCustomBand): Boolean; override;
    Function BandTypes : TFPReportBandTypes; override;
  end;

  { TDataFooterBandPropertyEditor }

  TDataFooterBandPropertyEditor = Class(TReportBandPropertyEditor)
  Public
    Function BandTypes : TFPReportBandTypes; override;
  end;

  { TDataHeaderBandPropertyEditor }

  TDataHeaderBandPropertyEditor = Class(TReportBandPropertyEditor)
  Public
    Function BandTypes : TFPReportBandTypes; override;
  end;

  { TDataBandPropertyEditor }

  TDataBandPropertyEditor = Class(TReportBandPropertyEditor)
  Public
    Function BandTypes : TFPReportBandTypes; override;
  end;

  { TGroupHeaderBandPropertyEditor }

  TGroupHeaderBandPropertyEditor = Class(TReportBandPropertyEditor)
  Public
    Function BandTypes : TFPReportBandTypes; override;
  end;

  { TGroupFooterBandPropertyEditor }

  TGroupFooterBandPropertyEditor = Class(TReportBandPropertyEditor)
  Public
    Function BandTypes : TFPReportBandTypes; override;
  end;

  { TParentGroupHeaderBandPropertyEditor }

  TParentGroupHeaderBandPropertyEditor = Class(TGroupHeaderBandPropertyEditor)
  Public
    function BandAllowed(B: TFPReportCustomBand): Boolean; override;
  end;

Procedure RegisterFPReportPropEditors;

implementation

uses fpreportlclexport;

Procedure RegisterFPReportPropEditors;

begin
  RegisterPropertyEditor(TypeInfo(TFPReportData), TFPreportElement, 'Data', TDataComponentPropertyEditor);
  RegisterPropertyEditor(TypeInfo(TFPReportCustomChildBand), TFPReportCustomBand, 'ChildBand', TChildBandPropertyEditor);
  RegisterPropertyEditor(TypeInfo(TFPReportCustomDataFooterBand), TFPReportCustomBand, 'FooterBand', TDataFooterBandPropertyEditor);
  RegisterPropertyEditor(TypeInfo(TFPReportCustomDataHeaderBand), TFPReportCustomBand, 'HeaderBand', TDataHeaderBandPropertyEditor);
  RegisterPropertyEditor(TypeInfo(TFPReportCustomDataBand), TFPReportCustomBand, 'MasterBand', TDataBandPropertyEditor);
  RegisterPropertyEditor(TypeInfo(TFPReportCustomGroupHeaderBand),TFPReportCustomGroupHeaderBand, 'ParentGroupHeader', TParentGroupHeaderBandPropertyEditor);
  RegisterPropertyEditor(TypeInfo(TFPReportCustomGroupHeaderBand),TFPReportCustomGroupFooterBand, 'GroupHeader', TGroupHeaderBandPropertyEditor);

  RegisterPropertyEditor(TypeInfo(TFPReportColor),TFPReportComponent,'Color',TFPreportColorPropertyEditor);
  RegisterPropertyEditor(TypeInfo(TFPReportColor),TFPReportComponent,'BackgroundColor',TFPreportColorPropertyEditor);
  RegisterPropertyEditor(TypeInfo(TFPReportColor),TFPReportFrame,'Color',TFPreportColorPropertyEditor);
  RegisterPropertyEditor(TypeInfo(TFPReportColor),TFPReportFrame,'BackgroundColor',TFPreportColorPropertyEditor);
  RegisterPropertyEditor(TypeInfo(TFPReportColor),TFPReportFont,'Color',TFPreportColorPropertyEditor);
  RegisterPropertyEditor(ClassTypeInfo(TFPReportFont), nil,'',TReportFontPropertyEditor);
  RegisterPropertyEditor(TypeInfo(String),TFPReportFont,'Name',TReportFontNamePropertyEditor);
end;

{ TReportFontPropertyEditor }

Function PostScriptNameToFontName(N : String) : String;

Var
  F : TFPFontCacheItem;

begin
  if (N='default') then
    N:=ReportDefaultFont;
  F:=gTTFontCache.Find(N);
  if Assigned(F) then
    N:=F.FamilyName;
  Result:=N;
end;

Function FontNameToPostScriptName(N : String; ABold,AItalic : Boolean) : String;

Var
  F : TFPFontCacheItem;

begin
  if (N='default') then
    N:=ReportDefaultFont;
  F:=gTTFontCache.Find(N,aBold,aItalic);
  if Assigned(F) then
    N:=F.PostScriptName;
  Result:=N;
end;

{ TParentGroupHeaderBandPropertyEditor }

function TParentGroupHeaderBandPropertyEditor.BandAllowed(B: TFPReportCustomBand): Boolean;

Var
  G,P : TFPReportCustomGroupHeaderBand;

begin
  Result:=inherited BandAllowed(B);
  if Result then
    begin
    P:=B as TFPReportCustomGroupHeaderBand;
    G:=GetComponent(0) as TFPReportCustomGroupHeaderBand;
    While Result and (P<>Nil) do
      begin
      Result:=P<>G;
      P:=TFPReportGroupHeaderBand(P).ParentGroupHeader;
      end;
    end;
end;


{ TFPreportColorPropertyEditor }

function TFPreportColorPropertyEditor.OrdValueToVisualValue(OrdValue: longint): string;

Var
  lclColor : TColor;

begin
  lclColor:=TFPReportExportCanvas.RGBtoBGR(UInt32(OrdValue));
  Result:=inherited OrdValueToVisualValue(lclColor);
end;

procedure TFPreportColorPropertyEditor.SetValue(const NewValue: ansistring);

var
  CValue: Longint;

begin
  if IdentToColor(NewValue, CValue) then
    SetOrdValue(Longint(TFPReportExportCanvas.BGRToRGB(TColor(CValue))))
  else
    inherited SetValue(NewValue);
end;

{ TReportFontNamePropertyEditor }


procedure TReportFontNamePropertyEditor.SetValue(const NewValue: ansistring);
begin
  inherited SetValue(FontNameToPostScriptName(NewValue,False,False));
end;

procedure TReportFontPropertyEditor.Edit;

var
  FontDialog: TFontDialog;
  R : TFPReportFont;

begin
  FontDialog := TFontDialog.Create(nil);
  try
    R:=TFPReportFont(GetObjectValue(TFPReportFont));
    FontDialog.Font.Name := PostScriptNameToFontName(R.Name);
    FontDialog.Font.Size:=R.Size;
    FontDialog.Font.Color:=TFPReportExportCanvas.RGBtoBGR(R.Color);
    FontDialog.Options := FontDialog.Options + [fdShowHelp, fdForceFontExist];
    if FontDialog.Execute then
      begin
      R.Name:=FontNameToPostScriptName(FontDialog.Font.Name,FontDialog.Font.Bold,FontDialog.Font.Italic);
      R.Size:=FontDialog.Font.Size;
      R.Color:=TFPReportExportCanvas.BGRToRGB(FontDialog.Font.Color);
      end;
  finally
    FontDialog.Free;
  end;
end;

function TReportFontPropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paMultiSelect, paSubProperties, paDialog, paReadOnly];
end;



{ TPaperNamePropertyEditor }

procedure TPaperNamePropertyEditor.GetValues(Proc: TGetStrProc);

Var
  I : integer;

begin
  for I:=0 to PaperManager.PaperCount-1 do
    Proc(PaperManager.PaperNames[i]);
end;

function TPaperNamePropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result:=[paValueList, paPickList, paAutoUpdate, paSortList];
end;


{ TGroupFooterBandPropertyEditor }

function TGroupFooterBandPropertyEditor.BandTypes: TFPReportBandTypes;
begin
  Result:=[btGroupFooter];
end;

{ TGroupHeaderBandPropertyEditor }

function TGroupHeaderBandPropertyEditor.BandTypes: TFPReportBandTypes;
begin
  Result:=[btGroupHeader];
end;

{ TDataBandPropertyEditor }

function TDataBandPropertyEditor.BandTypes: TFPReportBandTypes;
begin
  Result:=[btDataband];
end;

{ TDataHeaderBandPropertyEditor }

function TDataHeaderBandPropertyEditor.BandTypes: TFPReportBandTypes;
begin
  Result:=[btDataHeader];
end;

{ TDataFooterBandPropertyEditor }

function TDataFooterBandPropertyEditor.BandTypes: TFPReportBandTypes;
begin
  Result:=[btDataFooter];
end;

{ TChildBandPropertyEditor }

function TChildBandPropertyEditor.BandAllowed(B: TFPReportCustomBand): Boolean;

Var
  P : TFPReportCustomPage;
  CB : TFPReportCustomBand;
  I : Integer;

begin
  Result:=inherited BandAllowed(B);
  CB:=TFPReportCustomBand(GetComponent(0));
  If Result then
    begin
    P:=GetPage;
    I:=P.BandCount-1;
    While Result and (I>=0) do
      begin
      Result:=(P.Bands[i]=CB) or (P.Bands[i].ChildBand<>B);
      Dec(I)
      end;

    end;
end;

function TChildBandPropertyEditor.BandTypes: TFPReportBandTypes;
begin
  Result:=[btChild];
end;

{ TReportBandPropertyEditor }

function TReportBandPropertyEditor.BandTypes: TFPReportBandTypes;
begin
  Result:=[]
end;

Function TReportBandPropertyEditor.BandAllowed(B : TFPReportCustomBand) : Boolean;

Var
  BT : TFPReportBandTypes;

begin
  BT:=BandTypes;
  Result:=(B.Name<>'') and (B<>GetComponent(0));
  if Result and (BT<>[]) then
    Result:=B.ReportBandType in BT;
end;

procedure TReportBandPropertyEditor.GetValues(Proc: TGetStrProc);

Var
  P : TFPReportCustomPage;
  I : Integer;


begin
  P:=GetPage;
  proc(oisNone);
  if Assigned(P) then
    For I:=0 to P.BandCount-1 do
      if BandAllowed(P.Bands[i]) then
        Proc(P.Bands[i].Name);
end;

procedure TReportBandPropertyEditor.SetValue(const NewValue: ansistring);

Var
  P : TFPReportCustomPage;
  B : TFPReportCustomBand;
  I : integer;

begin
  B:=nil;
  if (NewValue<>oisNone) then
    begin
    P:=GetPage;
    I:=0;
    if Assigned(P) then
      While (B=Nil) and (I<P.BandCount) do
        begin
        if SameText(NewValue,P.Bands[I].Name) then
          B:=P.Bands[I];
        Inc(I);
        end;
    end;
  if Assigned(PropertyHook) then
    PropertyHook.ObjectReferenceChanged(Self,B);
  SetPtrValue(B);
end;

{ TReportComponentPropertyEditor }

Function TReportComponentPropertyEditor.GetPage : TFPReportCustomPage;

Var
  C : TPersistent;
begin
  Result:=Nil;
  C:=GetComponent(0);
  // Latest SVN has page
  if C is TFPReportCustomPage then
    Result:=C as TFPReportCustomPage
  else if C is TFPReportCustomBand then
    Result:=TFPReportCustomBand(C).Page
  else if C is TFPReportElement then
    Result:=TFPReportElement(C).Page;
end;

function TReportComponentPropertyEditor.GetReport: TFPCustomReport;
Var
  C : TPersistent;
begin
  Result:=Nil;
  C:=GetComponent(0);
  if C is TFPCustomReport then
    Result:=C as TFPCustomReport
  else if C is TFPReportElement then
    Result:=TFPReportElement(C).Report;
end;

{ TDataComponentPropertyEditor }

procedure TDataComponentPropertyEditor.GetValues(Proc: TGetStrProc);

Var
  Report : TFPCustomReport;
  I : Integer;

begin
  Report:=GetReport;
  proc(oisNone);
  if Assigned(Report) then
    For I:=0 to Report.ReportData.Count-1 do
      Proc(Report.ReportData[i].Data.Name);
end;

procedure TDataComponentPropertyEditor.SetValue(const NewValue: ansistring);

Var
  Report:TFPCustomReport;
  RD : TFPReportData;

begin
  RD:=nil;
  if (NewValue<>oisNone) then
    begin
    Report:=GetReport;
    if Assigned(Report) then
      RD:=Report.ReportData.FindReportData(NewValue);
    end;
  if Assigned(PropertyHook) then
    PropertyHook.ObjectReferenceChanged(Self,RD);
  SetPtrValue(RD);
end;

end.


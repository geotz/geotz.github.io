{ GEORGE TZOUMAS

     split large files

This program is distributed in the hope that it will be useful, 
but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
Use this software AT YOUR OWN RISK.

}

{Copyright 1999, by George M. Tzoumas}

{$M 65520, 0, 655360}
{$S-}

program FileSplit;

uses Dos;

function BlockCopy(var FromF, ToF: File; size: Longint): Boolean;
var
  NumRead, NumWritten: Word;
  Buf: array[1..16384] of Char;
  w, r, i: Longint;
  fault: boolean;
begin
  w := size div 16384;
  r := size mod 16384;
  i := 0;
  fault := False;
  while (i < w) and (not fault) do
  begin
    BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
    BlockWrite(ToF, Buf, NumRead, NumWritten);
    Inc(i);
    fault := (NumRead = 0) or (NumRead <> NumWritten);
  end;
  if fault then Exit;
  BlockRead(FromF, Buf, r, NumRead);
  BlockWrite(ToF, Buf, NumRead, NumWritten);
  fault := fault or (NumRead = 0) or (NumRead <> NumWritten);
  BlockCopy := fault;
end;

function IntToStrExt(I: Longint): String;
var
 S: string[11];
begin
 Str(I, S);
 if s[0]=#1 then Insert('00', S, 1);
 if s[0]=#2 then Insert('0', S, 1);
 IntToStrExt := S;
end;

var
  f1, f2: File;
  fn1, fn2: String;
  size, bsize: Longint;
  i, ns: Longint;
  c: Integer;
  w, r: Longint;
  v: Boolean;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  Writeln('File Splitter, v1.22, (c) 1999 by George M. Tzoumas');
  if ParamCount < 1 then
  begin
    Writeln('usage: fsplit <filename> [blocksize]');
    Writeln('default blocksize is 1433600 bytes');
    Halt(1);
  end;
  fn1 := ParamStr(1);
  bsize := 0;
  if ParamCount = 2 then Val(ParamStr(2), bsize, c);
  if bsize = 0 then bsize := 1433600;
  FSplit(fn1, D, N, E);
  Assign(f1, fn1);
{$I-}
  Reset(f1, 1);
{$I+}
  if IOResult <> 0 then
  begin
    Writeln('ERROR: Could not open ', fn1);
    Halt(3);
  end;
  size := FileSize(f1);
  w := size div bsize;
  r := size mod bsize;
  i := 0;
  v := false;
  ns := w + Byte(r>0);
  Write('File: ', fn1, ', Size: ', size, ' = ', w, ' x ', bsize);
  if r > 0 then Write(' + ', r);
  Writeln;
  if ns > 999 then
  begin
    Writeln('ERROR: Too many splits');
    Halt(4);
  end;
  while (i<w) and (not v) do
  begin
    Assign(f2, N+'.'+IntToStrExt(Succ(i)));
    Rewrite(f2, 1);
    v := BlockCopy(f1, f2, bsize);
    if v then
    begin
      Writeln('I/O Error');
      Halt(2);
    end;
    Close(f2);
    Inc(i);
    if v then Break;
  end;
  if (r>0) and (not v) then
  begin
    Assign(f2, N+'.'+IntToStrExt(Succ(i)));
    Rewrite(f2, 1);
    v := BlockCopy(f1, f2, r);
    if v then
    begin
      Writeln('I/O Error');
      Halt(2);
    end;
    Close(f2);
  end;
  Close(f1);
end.


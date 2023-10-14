{ GEORGE TZOUMAS

     Master Mind

This program is distributed in the hope that it will be useful, 
but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
Use this software AT YOUR OWN RISK.

}

{$S-}
program Master_Mind;

uses Crt;

const
  colors: array[0..7] of Byte = (8, 9, 2, 4, 5, 6, 10, 11);

type
  pbuf = ^tbuf;
  tbuf = array[0..16383] of Word;

var
  buf: array[0..1] of pbuf;
  ans: string;
  i, j: Word;
  c: Char;

function GetPerm(i: Word): Word;
begin
  GetPerm := buf[i shr 14]^[i and $3FFF];
end;

procedure SetPerm(i, v: Word);
begin
  buf[i shr 14]^[i and $3FFF] := v;
end;

procedure MarkPerm(i: Word);
begin
  buf[i shr 14]^[i and $3FFF] := buf[i shr 14]^[i and $3FFF] or $8000;
end;

function IsMarked(i: Word): Boolean;
begin
  IsMarked := buf[i shr 14]^[i and $3FFF] and $8000 = $8000;
end;

function PermName(v: Word): string;
var
  s: string;
  j: Byte;
begin
  s[0] := #5;
  s[5] := Char(v and $07);
  v := v shr 3;
  s[4] := Char(v and $07);
  v := v shr 3;
  s[3] := Char(v and $07);
  v := v shr 3;
  s[2] := Char(v and $07);
  v := v shr 3;
  s[1] := Char(v and $07);
  for j := 1 to 5 do s[j] := Char(Ord(s[j]) + Ord('0'));
  PermName := s;
end;

function AnsName(a: Word): string;
var
  s: string;
  j: Byte;
begin
  s[0] := #5;
  s[5] := Char(a mod 3);
  a := a div 3;
  s[4] := Char(a mod 3);
  a := a div 3;
  s[3] := Char(a mod 3);
  a := a div 3;
  s[2] := Char(a mod 3);
  a := a div 3;
  s[1] := Char(a mod 3);
  for j := 1 to 5 do s[j] := Char(Ord(s[j]) + Ord('0'));
  AnsName := s;
end;

function PermVal(p: string): Word;
begin
  PermVal := (Ord(p[1])-48)*4096+(Ord(p[2])-48)*512+(Ord(p[3])-48)*64+
            (Ord(p[4])-48)*8+(Ord(p[5])-48);
end;

function AnsVal(a: string): Word;
begin
  AnsVal := (Ord(a[1])-48)*81+(Ord(a[2])-48)*27+(Ord(a[3])-48)*9+
            (Ord(a[4])-48)*3+(Ord(a[5])-48);
end;

function QPerm(s, d: Word): string;
var
  sc, ss, sd: string;
  j, k: Byte;
begin
  sc := '00000';
  ss := PermName(s);
  sd := PermName(d);
  for j := 1 to 5 do if ss[j] = sd[j] then
  begin
    sc[j] := '2';
    ss[j] := '@';
    sd[j] := '*';
  end;
  for j := 1 to 5 do if ss[j] in ['0'..'9'] then
  begin
    k := Pos(ss[j], sd);
    if k > 0 then
    begin
      sc[j] := '1';
      sd[k] := '*';
    end;
  end;
  QPerm := sc;
end;

function RankOf(v: Word): Byte;
var
  s: string;
  j, k: Byte;
  t: set of Char;
begin
  s := PermName(v);
  t := [];
  k := 0;
  for j := 1 to 5 do if not (s[j] in t) then
  begin
    Include(t, s[j]);
    Inc(k);
  end;
  RankOf := k;
end;

procedure QuickSort;

procedure Sort(l, r: Word);
var
  i, j, x, y: Word;
  ra: Byte;
begin
  i := l; j := r; x := GetPerm((l+r) shr 1);
  repeat
    ra := RankOf(x);
    while RankOf(buf[i shr 14]^[i and $3FFF]) > ra do Inc(i);
    while ra > RankOf(buf[j shr 14]^[j and $3FFF]) do Dec(j);
    if i <= j then
    begin
      y := buf[i shr 14]^[i and $3FFF];
      buf[i shr 14]^[i and $3FFF] := buf[j shr 14]^[j and $3FFF];
      buf[j shr 14]^[j and $3FFF] := y;
      Inc(i); Dec(j);
    end;
  until i > j;
  if l < j then Sort(l, j);
  if i < r then Sort(i, r);
end;

begin {QuickSort};
  Sort(0, 32767);
end;

procedure WritePerm(s: String);
var j: Byte;
begin
  for j := 1 to Length(s) do
  begin
    TextAttr := colors[Ord(s[j])-48];
    Write(s[j]);
  end;
  TextAttr := 7;
end;

procedure ReadPerm(var s: String);
var
  j, ox, oy: Byte;
  ch: Char;
begin
  s := '';
  j := 0;
  ox := Wherex;
  oy := Wherey;
  repeat
    GotoXY(ox, oy);
    ClrEol;
    WritePerm(s);
    ch := ReadKey;
    if not (ch in [#8, #13, #27, '0'..'7']) then Continue;
    if ch = #8 then
      if s[0] <> #0 then Dec(s[0]) else
    else if ch in ['0'..'7'] then
      if Length(s) < 5 then s := s + ch else
    else if ch = #13 then
      if Length(s) = 5 then Break else
    else begin
           Writeln;
           Halt(0);
         end;
  until False;
  Writeln;
end;

procedure HumanGuess;
var
  g: Word;
  s, ans: string;
  j: Byte;
begin
  Randomize;
  g := Random(32768);
{  Writeln('-- Debug (', PermName(g), ') --');}
  j := 0;
  repeat
    Write('Guess (',Succ(j),') > ');
    ReadPerm(s);
    Inc(j);
    ans := QPerm(PermVal(s), g);
    Writeln('      ans = ', ans);
  until (ans = '22222') or (j = 10);
  if (ans = '22222') then Writeln('-- Perfect --') else Writeln('-- Sorry (', PermName(g), ') --');
end;

procedure ComputerGuess;
var
  ans, gs: string;
  i, g, tr, left: Word;
begin
  GetMem(buf[0], SizeOf(tbuf));
  GetMem(buf[1], SizeOf(tbuf));
  for i := 0 to 32767 do SetPerm(i, i);
  Write('Initializing... ');
  QuickSort;
  Writeln('Done.');
  tr := 0;
  left := 32768;
  repeat
    i := 0;
    while (i<32768) do
    begin
      if not IsMarked(i) then break;
      Inc(i);
    end;
    if i = 32768 then Break;
    g := GetPerm(i);
    gs := PermName(g);
    MarkPerm(i);
{    Writeln('choosing between ', left, ' ...');}
    Dec(left);
    Write('(',Succ(tr),') = ');
    WritePerm(gs);
    Writeln;
    if left = 0 then Break;
    Write(' ?    ');
    Readln(ans);
    Inc(tr);
    if ans = '22222' then Break;
    for i := 0 to 32767 do if not IsMarked(i) then if QPerm(g, GetPerm(i)) <> ans then begin MarkPerm(i); Dec(left); end;
    if left = 0 then
    begin
      Writeln('-- CHEATER, CHEATER, CHEATER !!! --');
      Break;
    end;
  until False;
end;

{function FindPerm(v: Word): Integer;
var j: Word;
begin
  j := 0;
  while True do
  begin
    if (j=32768) or (GetPerm(j) = v) then Break;
    Inc(j);
  end;
  FindPerm := j;
end;}

begin
  Writeln('Master Mind, Version 1.2, Copyright 1999 by George M. Tzoumas');
  Write('Do you want to guess my number (y/n) ? ');
  c := Readkey;
  Writeln;
  if UpCase(c) = 'Y' then HumanGuess;
  if UpCase(c) = 'N' then ComputerGuess;
end.
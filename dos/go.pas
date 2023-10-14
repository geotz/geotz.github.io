{ GEORGE TZOUMAS

     bfs search directory tree

This program is distributed in the hope that it will be useful, 
but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
Use this software AT YOUR OWN RISK.

}

program Go;

uses Dos, Crt, StrHan;

const maxP = 800;

type
  Queue = array[0..maxP] of PathStr;

var
  s: Queue;
  head, tail: Integer;

function PartOf(p, w: String): boolean;
begin
  PartOf := (Length(p) > 0) and (Length(p) <= Length(w)) and (Copy(p, 1, Length(p)) = Copy(w, 1, Length(p)));
end;

procedure put(as: PathStr);
begin
  s[tail] := as;
  Inc(tail);
  if tail > maxP then tail := 0;
end;

procedure get(var as: PathStr);
begin
  as := s[head];
  Inc(head);
  if head > maxP then head := 0;
end;

var
  n: SearchRec;
  t, d, c, tmp: PathStr;
  Passed, UsePassed: Boolean;

begin
  head := 0;
  tail := 0;
  d := ParamStr(1);
  d := UpStr(d);
  if d = '' then Halt;
  if d[1] = '\' then begin Chdir('\'); Delete(d, 1, 1) end;
  GetDir(0, c);
  put('\');
  Passed := False;
  tmp := c;
  while Pos('\', tmp) > 0 do Delete(tmp, 1, Pos('\', tmp));
  UsePassed := PartOf(d, tmp);
  while (head <> tail) and not KeyPressed do
  begin
    get(t);
    ChDir(t);
    Write('Searching ', t);
    ClrEol;
    Write(#13);
    FindFirst('*.*', AnyFile, n);
    while (DosError = 0) and not KeyPressed do
    begin
      if (n.Attr and Directory = Directory) and (n.Name[1] <> '.') then
      begin
        if ((UsePassed and Passed) or (not UsePassed)) and PartOf(d, n.Name) then
        begin
          Chdir(n.name);
          Halt;
        end;
        if UsePassed then if not Passed then Passed := c = FExpand(n.Name);
        put(FExpand(n.Name));
      end;
      FindNext(n);
    end;
  end;
  ChDir(c);
  ClrEol;
  while Keypressed do Readkey;
end.

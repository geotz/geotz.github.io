{ GEORGE TZOUMAS

     crazy keys

This program is distributed in the hope that it will be useful, 
but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
Use this software AT YOUR OWN RISK.

}

{$M 4096, 0, 0}
{$S-,I-}
program MadKeys;

uses Dos, Crt;

var OldInt9: Procedure;

{$F+}
procedure NewInt9; interrupt;
begin
  inline ($9C);
  OldInt9;
  if (Port[$60] in [72, 75, 77, 80]) and (Random(20) = 0) then while keypressed do readkey;
end;
{$F-}
begin
  GetIntVec($9, @OldInt9);
  SetIntVec($9, @NewInt9);
{  writeln('By GT');}
  Keep(0);
end.
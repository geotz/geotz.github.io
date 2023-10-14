{ GEORGE TZOUMAS

     bios alarm

This program is distributed in the hope that it will be useful, 
but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
Use this software AT YOUR OWN RISK.

}

{$M 1024, 0, 0}
program Alarm;

uses Dos;

procedure AlarmProc; interrupt; assembler;
asm {@@1: jmp @@1} end;

procedure IncMin; assembler;
asm
        inc cl
        mov al, cl
        shl al, 4
        cmp al, $a0
        jne @@1
        add cl, 6
        cmp al, $60
        jne @@1
        xor cl, cl
@@1 :
end;
{
procedure IncHour; assembler;
asm
        inc ch
        mov al, ch
        shl al, 4
        cmp al, $a0
        jne @@1
        add ch, 6
        cmp al, $24
        jne @@1
        xor ch, ch
@@1 :
end;
}
begin
  SetIntVec($4A, @AlarmProc);
  asm
        mov ah, 2
        int $1a
        call IncMin
        mov ah, 6
        int $1a
@@1:
  end;
{  writeln('By GT');}
  Keep(0);
end.
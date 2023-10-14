{ GEORGE TZOUMAS & VASSILIS VASAITIS

     time the execution of a program

This program is distributed in the hope that it will be useful, 
but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
Use this software AT YOUR OWN RISK.

}

{$M 4096,0,0}
{$S-,G+,D-,L-,Y-,N+,E-}
program Timer;

uses Dos;

const lim_msg: string = 'WARNING: program exceeded time limit';

var
  oldint: procedure;
  cursx: byte absolute $40:$50;
  cursy: byte absolute $40:$51;
  ticks: word;
  lim, tlim: word;
  rtct1, rtct2: longint;
  dif1, dif2, exec_time: integer;
  Code: Integer;
  lim_flag: Boolean;

function min(x, y: integer): integer;
begin
  if x < y then min := x else min := y;
end;

function max(x, y: integer): integer;
begin
  if x > y then max := x else max := y;
end;

function get_rtc_time: longint;
var
  sec, min, hour: longint;
begin
  port[$70] := 0; sec := port[$71];
  port[$70] := 2; min := port[$71];
  port[$70] := 4; hour := port[$71];
  sec := (sec shr 4) * 10 + (sec and $0F);
  min := (min shr 4) * 10 + (min and $0F);
  hour := (hour shr 4) * 10 + (hour and $0F);
  get_rtc_time := hour * 3600 + min * 60 + sec;
end;

{$F+}
procedure print_mem(var str: string; y, x: word; attr: byte); assembler;
asm
        pusha
        cld
        mov     ax, $B800
        mov     es, ax
        mov     ax, y
        mov     di, ax
        shl     di, 7
        shl     ax, 5
        add     di, ax
        mov     ax, x
        shl     ax, 1
        add     di, ax
        mov     ah, attr
        lds     si, str
        lodsb
        mov     cl, al
        xor     ch, ch
@loop:
        lodsb
        stosw
        loop    @loop
        popa
end;

procedure myint; interrupt;
begin
  asm cli end;
  inc(ticks);
  if (ticks > tlim) and lim_flag then
  begin
    lim_flag := False;
    print_mem(lim_msg, cursy, cursx, 7);
  end;
  asm sti; pushf end;
  oldint;
end;
{$F-}

begin
  if ParamCount = 0 then
  begin
    writeln('usage: timer progfile [timelimit]');
    halt;
  end;

  Val(paramstr(2), lim, Code);
  if Code <> 0 then
  begin
    tlim := $FFFF;
    lim := $FFFF;
  end
  else tlim := Round(lim * 18.2);

  lim_flag := True;

  getintvec($1C, @oldint);
  setintvec($1C, @myint);

  writeln('Running ', paramstr(1), ' ...');

  rtct1 := get_rtc_time;
  ticks := 0;

  Exec(ParamStr(1), '');
  if doserror <> 0 then
  begin
    setintvec($1C, @oldint);
    writeln('FATAL: failed to run program.');
    halt;
  end;

  setintvec($1C, @oldint);

  rtct2 := get_rtc_time;

  dif1 := Round(ticks/18.2);
  dif2 := rtct2 - rtct1;

  if not lim_flag then Writeln;
  if Abs(dif2-dif1) <= 2 then
  begin
    exec_time := min(dif1, dif2);
  end
  else
  begin
    exec_time := max(dif1, dif2);
    writeln('WARNING: program may have tried to mess with the timer');
  end;
  if exec_time <= lim then write('PROGRAM FINISHED IN TIME')
  else write('PROGRAM FAILED TO FINISH IN TIME!');
  writeln(' (execution time: ', exec_time, ' sec, time limit: ', lim, ' sec)');
end.

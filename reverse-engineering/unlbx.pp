Program unlbx;
{ Unpacks Microprose's LBX files }

const
   bufsize = 16384 ;
   
var
   inf,       { Input file }
   ouf: file; { Output file }
   fc: Word;             { File Count }
   pos, len: Longint; { Position and lengthof File }
   fn: String; { Output filename }

   i: Word;
   
   first, last, which, error: Integer;
   buf: Array[1..bufsize] of byte;
   
Procedure ShowUsage;
{ Show program usage and exit }
Begin
   WriteLn ('UnLBX 1.1 - (C) 2001 by Daniel F Moisset under the GPL');
   WriteLn;
   WriteLn ('Usage: unlbx filename [index [output]]');
   Halt (1)
End;

Begin
   If ParamCount < 1 then ShowUsage; 
   If ParamCount >= 2 then begin
       Val (ParamStr (2), which, error) ;
       if error<>0 then begin
           WriteLn ('Invalid number: ',ParamStr(2));
           ShowUsage
       end;
   end;

   Assign (inf, ParamStr(1));
   filemode := 0 ;
   Reset (inf, 1);
   
   { Get file count }
   BlockRead (inf, fc, sizeof(fc) );
   If ParamCount <2 then begin
       first := 1 ;
       last := fc ;
   end else begin
       first := which;
       last := which;
       if (which<1) or (which>fc) then begin
           WriteLn ('Index out of bounds: ', which, ' (max ',fc,')');
           ShowUsage;
       end;
   end;
   
   for i := first to last do
   Begin
      Seek (inf, 4+4*i) ;
      BlockRead (inf, pos, sizeof(pos) );
      BlockRead (inf, len, sizeof(len) );
      len := len - pos;
      
      { Construct file name }
      If ParamCount < 3 then begin
          Str (i, fn);
          while Length(fn)<4 do fn:='0'+fn;
      end else
          fn := ParamStr (3) ;
      
      Assign (ouf, fn);
      filemode := 2; 
      Rewrite (ouf, 1);
      { Dump data }
      Seek (inf, pos);
      while len > bufsize do
      Begin
         BlockRead (inf, buf, bufsize);
         BlockWrite (ouf, buf, bufsize);
         len := len - bufsize
      End ;
      BlockRead (inf, buf, len);
      BlockWrite (ouf, buf, len);
      Close (ouf)
   End;
   
   Close (inf)
End.
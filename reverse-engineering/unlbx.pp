Program unlbx;
{ Unpacks Microprose's LBX files }

const
   bufsize = 16384 ;
   
var
   inf,       { Input file }
   ouf: file; { Output file }
   fc,             { File Count }
   pos, len: Longint; { Position and lengthof File }
   fn: String; { Output filename }

   i, r: Word;
   
   buf: Array[1..bufsize] of byte;
   
Procedure ShowUsage;
{ Show program usage and exit }
Begin
   WriteLn ('UnLBX 1.0 - (C) 2001 by Daniel F Moisset under the GPL');
   WriteLn;
   WriteLn ('Usage: unlbx filename');
   Halt (1)
End;

Begin
   If ParamCount < 1 then ShowUsage; 
   Assign (inf, ParamStr(1));
   Reset (inf, 1);
   
   { Get file count }
   BlockRead (inf, fc, sizeof(fc) );
   for i := 1 to fc do
   Begin
      Seek (inf, 4+4*i) ;
      BlockRead (inf, pos, sizeof(pos) );
      BlockRead (inf, len, sizeof(len) );
      len := len - pos;
      
      { Construct file name }
      Str (i, fn);
      while Length(fn)<4 do fn:='0'+fn;
      
      Assign (ouf, fn);
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
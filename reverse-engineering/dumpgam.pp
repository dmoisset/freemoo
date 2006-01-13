Program dump_game;
{ Dumps MOO2 GAM files }
{ Statistics about star colors }

{$PACKRECORDS 1}

const
   maxstars=255;
   colors:Array[0..6] of char = 'BWYORGK';
   
   offset=96977;

   
type
   Star=record
      Name: array[0..14] of Char;
      dummy1: Array[1..7] of Byte;
      color: Byte;
      dummy2: Array[1..90] of Byte;
   end;
   
var
   inf: file; { Input file }
   stcount: Word;
   stars: Array[0..maxstars] of Star;
   
   i: Integer;
   
Procedure ShowUsage;
{ Show program usage and exit }
Begin
   WriteLn ('DumpGAM 1.0 - (C) 2002 by Daniel F Moisset under the GPL');
   WriteLn;
   WriteLn ('Usage: dumpgam filename');
   Halt (1)
End;

Begin
   If ParamCount < 1 then ShowUsage; 
   Assign (inf, ParamStr(1));
   Reset (inf, 1);
   
   { Get file count }
   Seek (inf, offset);
   BlockRead (inf, stcount, 2 );
   WriteLn (stcount, ' stars');
   BlockRead (inf, stars, stcount*sizeof(star));
   for i := 0 to stcount-1 do
   Begin
       Write (stars[i].name, ', ');
       Write (colors[stars[i].color]);
       WriteLn;
   End;
   
   Close (inf)
End.
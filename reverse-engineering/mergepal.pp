Program mergepal;

const
   maxoffsets=1024;
   maxline=640;
   maxsize=640*480;

type
   TMPImage=record
               width, height: Word;
	       u1: Word; {?} {0?}
	       imgcount, loopstart: Word;
	       u2: Word; {?} {indicador de formato? flags?}
            end;
   TOffsets=array[0..maxoffsets-1] of LongInt;
   TColor=record
             z, r, g, b: Byte;
          end;
   TPalette=Array[Byte] of TColor;
   TSDLPalette=Array[Byte] of Word;

var
   inf: file; { Input Image File }
   pal: File; { Palette file }
   
   { File data }
   header: TMPImage;
   offsets: TOffsets;
   
   realpal: TSDLPalette;    { Table of 16 bit entries, matching display }
   fpal: TPalette;          { VGA Palette inside file }
   palstart, palsize: Word; { dimensions of vga palette }

   i: Integer;

Procedure ShowUsage;
{ Show program usage and exit }
Begin
   WriteLn ('Usage: mergepal palette image');
   Halt (1)
End;

Procedure SavePalette;
var
   f: file;
Begin
   Assign (f, ParamStr(1));
   filemode := 2; 
   Rewrite (f, 1);
   BlockWrite (f, realpal, sizeof(realpal));
   Close(f)
End;

Begin
   If ParamCount < 2 then ShowUsage ;
   {$I-}
   Assign (pal, ParamStr(1));
   filemode := 0 ;
   Reset (pal, 1);
   if ioresult=0 then
   begin
      BlockRead (pal, realpal, sizeof(realpal));
      Close(pal)
   end;
   {$I+}
   Assign (inf, ParamStr (2));
   filemode := 0 ;
   Reset (inf, 1);
   
   { Read Header }
   BlockRead (inf, header, sizeof(header) );
   BlockRead (inf, offsets, sizeof(LongInt)*(header.imgcount+1));
   
   { Read Palette }
   palstart := 0;
   palsize := 0;
   If FilePos (inf)<offsets[0] then
   Begin
      BlockRead (inf, palstart, sizeof(palstart) );
      BlockRead (inf, palsize, sizeof(palsize) );
      BlockRead (inf, fpal[palstart], palsize*sizeof(TColor))
   End ;
   { Convert Palette}
   for i := palstart to palstart+palsize-1 do
      with fpal[i] do
         realpal[i] := (r div 2) shl 11+g shl 5+b shr 1;

   SavePalette;
End.
Program MPview;

Uses SDL, SDL_video, getopts, crt, SDL_events;

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
   TLineDesc=record
                count, offset: Word;
             end;
   TColor=record
             z, r, g, b: Byte;
          end;
   TPalette=Array[Byte] of TColor;
   TSDLPalette=Array[Byte] of Word;

   TFrameBuffer=Array[0..maxsize-1] of Word;

var
   inname: String;      { Input filename }
   savepalfile: String; { saved palette filename }
   framedel: Integer;

   inf: file; { Input File }
   
   screen: PSDL_Surface; { Screen display surface }

   { File data }
   header: TMPImage;
   offsets: TOffsets;
   dsc: TLineDesc;
   
   realpal: TSDLPalette;    { Table of 16 bit entries, matching display }
   fpal: TPalette;          { VGA Palette inside file }
   palstart, palsize: Word; { dimensions of vga palette }

   i, j: Integer;
   
   y, p: LongInt;
   lbuf: Array[0..maxline-1] of Byte ;

   e: SDL_Event;
   
Procedure ShowUsage;
{ Show program usage and exit }
Begin
   WriteLn ('Usage: mpview [options] filename');
   WriteLn (' Options:');
   WriteLn ('   -p palette: Load palette before using image palette');
   WriteLn ('   -w palette: Save used palette to this file');
   WriteLn ('   -d delay: Animate with delay ms between frames (default=50)');
   WriteLn ('   -h: This help message');
   Halt (1)
End;

Procedure ParseArgs;
const
   optionspec='p:w:d:h';
var
   o: Char ; { Option }
   p: file ;
Begin
   savepalfile := '';
   framedel := 50 ;
   If ParamCount < 1 then ShowUsage; 
   repeat 
      o := Getopt (optionspec);
      case o of
         'h':ShowUsage;
         'p':Begin
                {$I-}
                Assign (p, OptArg);
                filemode := 0 ;
                Reset (p, 1);
                if ioresult=0 then
                begin
                    BlockRead (p, realpal, sizeof(realpal));
                    Close(p)
                end
                {$I+}
             End ;
         'w':savepalfile:= OptArg;
         'd':Val (Optarg, framedel);
         EndOfOptions:{ nothing };
      else
         WriteLn ('Unrecognized option: -',o);
         ShowUsage;
      end
   until o=EndOfOptions;

   If optind <= paramcount then
      inname := ParamStr(optind)
   else
   Begin
      WriteLn ('Missing filename');
      ShowUsage
   End
End ;

Procedure SavePalette;
var
   f: file;
Begin
   If savepalfile<>'' then
   Begin
      Assign (f, savepalfile);
      filemode := 2 ;
      Rewrite (f, 1);
      BlockWrite (f, realpal, sizeof(realpal));
      Close(f)
   End;
End;

Begin
   WriteLn ('MPView 1.0 - (C) 2001 by Daniel F Moisset under the GPL');
   WriteLn;
   { Default palette, grayscale }
   for i := 0 to 255 do
      realpal[i] := (i shr 3)*$0801+(i shr 2) shl 5 ;
   ParseArgs;
   Assign (inf, inname);
   filemode := 0 ;
   Reset (inf, 1);
   
   { Read Header }
   BlockRead (inf, header, sizeof(header) );
   BlockRead (inf, offsets, sizeof(LongInt)*(header.imgcount+1));
   
   SDL_Init (SDL_INIT_VIDEO);
   screen := SDL_SetVideoMode (header.width, header.height, 16, 0);

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
         realpal[i] := SDL_MapRGB (screen^.format, r*4+3, g*4+3, b*4+3);

   i := 0;
   Repeat
      Seek (inf, offsets[i]); 
      { Image start }
      BlockRead (inf, dsc, sizeof(dsc));
      y := dsc.offset;
      p := (screen^.pitch div 2)*y;
      while y<header.height do
      Begin
         BlockRead (inf, dsc, sizeof(dsc));
         If dsc.count = 0 then
         Begin
            y := y + dsc.offset ;
            p := y*(screen^.pitch div 2)
         end else
         Begin
            p := p+dsc.offset;
            blockread (inf, lbuf, ((dsc.count+1) shr 1) shl 1); {word aligned data}
            for j:=0 to dsc.count-1 do
            Begin
               TFramebuffer(screen^.pixels^)[p] := realpal[lbuf[j]];
               p := p+1
            end
         End
      End ; 
      SDL_UpdateRect (screen, 0, 0, 0, 0);
      Delay (framedel);
      i := i + 1;
      if i=header.imgcount then
      Begin
         { If no loop, exit }
         if i-1=header.loopstart then 
            i := -1
         else
            i := header.loopstart
      end;
      SDL_PumpEvents
   Until (SDL_PeepEvents(e, 1, SDL_PEEKEVENT, SDL_KEYDOWNMASK) = 1) or (i = -1);

   while SDL_PeepEvents(e, 1, SDL_PEEKEVENT, SDL_KEYDOWNMASK or SDL_QUITMASK) = 0 do
   Begin
      SDL_PumpEvents;
      Delay(10);
   End;
   while SDL_PeepEvents(e, 1, SDL_PEEKEVENT, SDL_KEYUPMASK or SDL_QUITMASK) = 0 do
   Begin
      SDL_PumpEvents;
      Delay(10);
   End;
   SavePalette;
   SDL_FreeSurface (screen);
   SDL_Quit
End.
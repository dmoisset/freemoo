Program PalView;

Uses SDL, SDL_video, crt, SDL_events;

const
   maxoffsets=1024;
   maxline=640;
   maxsize=640*480;

type
   TSDLPalette=Array[Byte] of Word;

var
   screen: PSDL_Surface; { Screen display surface }
   realpal: TSDLPalette;    { Table of 16 bit entries, matching display }
   i: Integer;
   e: SDL_Event;
   r: SDL_Rect;

Procedure ParseArgs;
var
    p: file ;
Begin
   If ParamCount < 1 then Halt (1); 
   {$I-}
   Assign (p, ParamStr (1));
   filemode := 0 ;
   Reset (p, 1);
   if ioresult=0 then
   begin
       BlockRead (p, realpal, sizeof(realpal));
       Close(p)
   end
   {$I+}
End ;

Begin
   WriteLn;
   { Default palette, grayscale }
   for i := 0 to 255 do
      realpal[i] := (i shr 3)*$0801+(i shr 2) shl 5 ;
   ParseArgs;
   
   SDL_Init (SDL_INIT_VIDEO);
   screen := SDL_SetVideoMode (768, 40, 16, 0);

   r.x := 0;
   r.y := 0;
   r.w := 3;
   r.h := 40;
   for i := 0 to 255 do begin
       SDL_FillRect (screen, @r, realpal[i]) ;
       r.x := r.x+3;
   end ;
   SDL_UpdateRect (screen, 0,0,0,0) ;
   
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
   SDL_FreeSurface (screen);
   SDL_Quit
End.
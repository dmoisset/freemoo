Program datagam;
{ Dumps MOO2 GAM files }

const
   maxstars=255;
   maxplanets = 1300;
   colors:Array[0..6] of String[20] = ('Blue-White', 'White', 'Yellow', 'Orange',
   'Red', 'Brown', 'Black Hole');
   size:Array[0..4] of String[10] = ('Tiny', 'Small', 'Medium', 'Large', 'Huge');
   stsize: Array[0..2] of String[10] = ('Big', 'Medium', 'Small');
   climate:Array[0..9] of String[15] = ('Toxic', 'Radiated', 'Barren', 'Desert', 
   'Tundra', 'Ocean', 'Swamp', 'Arid', 'Terran', 'Gaia');
   rich:Array[0..4] of String[15] = ('Ultra Poor', 'Poor', 'Abundant', 'Rich', 'Ultra Rich');
   ptype: Array[0..3] of String[15] = ('Sun', 'Asteroid', 'Gas Giant', 'Planet');
   grav: Array[0..2] of String[10] = ('Low G', 'Normal G', 'High G');
   specials: Array[0..11] of String[20] = ('No Special', 'Stable Worm Hole',
   'Space Debris', 'Pirate Cache', 'Gold Deposits', 'Gem Deposits', 'Natives',
   'Spliter Colony', 'Hero', 'Monster', 'Ancient Artifacts', 'Orion Special');
   
   ploffset=90855;
   stoffset=96977;

type
   Star=record
      Name: array[0..14] of Char;
      dummy0: array[15..18] of Byte;
      size: Byte;
      dummy1: Array[20..21] of Byte;
      color: Byte;
      dummy2: array[1..17] of Byte;
      special: Byte;
      dummy3: Array[1..72] of Byte;
   end;

{bit 0..1: No sé
 bit 2: Estrella a la que pertenece, indexando stars
 bit 4: Tipo (planeta, asteroides, Gigante de gas...)
 bit 5: Tamaño
 bit 6: Gravedad
 bit 8: Clima
 bit 10: Recursos
 bit 13: Special
}

   Data = record
      Size: array[0..4] of Word;
      Climate: array[0..9] of Word;
      Mineral: array[0..4] of Word;
      grav: array[0..2] of Word;
      pType: array[0..3] of Word;
      special: array[0..11] of Word;
      samples: Word;
      stars: Word;
   end;
      

   Planet=record
      dummy1: array[0..1] of Byte;
      Star: Byte;
      dummy2: Byte;
      pType: Byte;
      Size: Byte;
      G:Byte;
      dummy4: Byte;
      Climate: Byte;
      dummy3: Byte;
      Mineral: Byte;
      dummy5: array[11..12] of Byte;
      Special2: Byte;
      dummy7: Byte;
      Special: Byte;
      dummy6: Byte;
   end;
   
var
   inf: file; { Input file }
   stcount: Word;
   pcount: Word;
   stars: Array[0..maxstars] of Star;
   stSizes: Array[0..2] of Word= (0,0,0);
   planets: Array[0..maxplanets] of Planet;
   datii: array[0..5] of Data;
   i: Integer;
   j: Integer;
   
Procedure ShowUsage;
{ Show program usage and exit }
Begin
   WriteLn ('DumpGAM 1.0 - (C) 2002 by Daniel F Moisset under the GPL');
   WriteLn;
   WriteLn ('Usage: dumpgam filename');
   Halt (1)
End;

Begin
   if ParamCount < 1 then ShowUsage; 

   for j := 0 to 5 do
   begin
      for i := 0 to 4 do
      begin
         datii[j].size[i] := 0;
	     datii[j].mineral[i] := 0;
      end;
      for i := 0 to 9 do
         datii[j].climate[i] := 0;
      for i := 0 to 2 do
         datii[j].grav[i] := 0;
      for i := 0 to 3 do
         datii[j].pType[i] := 0;
      for i := 0 to 11 do
         datii[j].Special[i] := 0;
      datii[j].samples := 0;
      datii[j].stars := 0;
   end;

   for j := 1 to ParamCount do
   begin
      Assign (inf, ParamStr(j));
      Reset (inf, 1);
   
   { Get file count }
      Seek (inf, ploffset);
      BlockRead (inf, pcount, 2 );
      BlockRead (inf, planets, pcount*sizeof(planet));
   
      Seek (inf, stoffset);
      BlockRead (inf, stcount, 2 );
      BlockRead (inf, stars, stcount*sizeof(star));
      for i := 0 to stcount-1 do
      begin
         if stars[i].special = 0 then
          datii[stars[i].color].stars := datii[stars[i].color].stars + 1;
	 stSizes [stars [i].size] := stSizes [stars [i].size] + 1;
      end;

      for i := 0 to pcount-1 do
         if stars[planets[i].star].special = 0 then
         Begin
             datii[stars[planets[i].star].color].size[planets[i].size] := datii[stars[planets[i].star].color].size[planets[i].size] + 1;
             datii[stars[planets[i].star].color].climate[planets[i].climate] := datii[stars[planets[i].star].color].climate[planets[i].climate] + 1;
             datii[stars[planets[i].star].color].mineral[planets[i].mineral] := datii[stars[planets[i].star].color].mineral[planets[i].mineral] + 1;
             datii[stars[planets[i].star].color].grav[planets[i].G] := datii[stars[planets[i].star].color].grav[planets[i].G] + 1;
             datii[stars[planets[i].star].color].pType[planets[i].pType] := datii[stars[planets[i].star].color].pType[planets[i].pType] + 1;
             datii[stars[planets[i].star].color].special[planets[i].special] := datii[stars[planets[i].star].color].special[planets[i].special] + 1;
             datii[stars[planets[i].star].color].samples := datii[stars[planets[i].star].color].samples + 1;
         End;
      Close (inf)
   end;   

   for j := 0 to 5 do
   begin
	WriteLn (colors[j], ' - ', datii[j].samples, ' samples out of ', datii[j].stars, ' stars:');
{	for i := 0 to 4 do
	    WriteLn (datii[j].size[i], ' ', size[i]);
	WriteLn;
	for i := 0 to 9 do
	    WriteLn (datii[j].climate[i], ' ', climate[i]);
	WriteLn;
	for i := 0 to 4 do
	    WriteLn (datii[j].mineral[i], ' ', rich[i]);
	WriteLn;
	for i := 0 to 2 do
	    WriteLn (datii[j].grav[i], ' ', grav[i]);
	WriteLn;
	for i := 0 to 3 do
	    WriteLn (datii[j].pType[i], ' ', pType[i]);
	WriteLn;
	for i := 0 to 11 do
	    WriteLn (datii[j].special[i], ' ', specials[i]);
	WriteLn;
	WriteLn;
	WriteLn;
}


    end;
    for i := 0 to 2 do
        WriteLn (stSizes [i])

End.
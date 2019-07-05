
void lesFil_FiltrerTil_gCodeArrayOnlyLinesOfG01(String gCodeFileInName)
{
  String[] gFanuc = loadStrings(gCodeFileInName);
  println("Lest: " + gFanuc.length + " lines of raw Fanuc G code fra fil: " + gCodeFileInName);

  String[] gPure = new String[gFanuc.length];

  int antG023 = 0;
  int indexPure = 0;
  for (int i=0; i<gFanuc.length; i++)
  {
    if ( (gFanuc[i].indexOf("G90")>-1) || (gFanuc[i].indexOf("%")>-1) || (gFanuc[i].indexOf("(")>-1) ||
      (gFanuc[i].indexOf("O")>-1) || (gFanuc[i].indexOf("G21")>-1) ||
      (gFanuc[i].indexOf("G54")>-1) || (gFanuc[i].indexOf("G28")>-1) || (gFanuc[i].indexOf("M")>-1) ||
      (gFanuc[i].indexOf("G49")>-1) || (gFanuc[i].indexOf("G43")>-1) || (gFanuc[i].length()<2) )
      ; // Ikke G00/G01 bevegelse linje - overfører ikke linjen
    else 
    {   // G00/G01 bevegelse linje - overfører linjen
      gPure[indexPure] = gFanuc[i];
      indexPure++;
    }

    if ( (gFanuc[i].indexOf("G02")>-1) || (gFanuc[i].indexOf("G03")>-1) )
    {
      println("****************** ERROR G02/3 found");
      antG023++;
    }
  }
  println("   Antall G02/G03 linjer funnet: " + antG023 + " (0 er nødvendig)");

  int numbOfmotionLines = indexPure;

  println("   Antall  G00/G01 linjer funnet (G00 er konvertert til G01): " + numbOfmotionLines);        

  // Making new short String array with empty tailing indexes removed from gPure for å kunne bruke "saveStrings"
  gCodeArrayOnlyLinesOfG01 = new String[numbOfmotionLines];
  for (int i=0; i<numbOfmotionLines; i++)
    gCodeArrayOnlyLinesOfG01[i] = gPure[i];

  double x=0;
  double y=0;
  double z=0;
  double f=1;

  double maxF = 0; // vil finne maxF

  for (int i=0; i<gCodeArrayOnlyLinesOfG01.length; i++)
  {
    if (gCodeArrayOnlyLinesOfG01[i].indexOf("X")>-1)
      x = finnTallVerdiFraLinjeRaaFil("X", gCodeArrayOnlyLinesOfG01[i]);

    if (gCodeArrayOnlyLinesOfG01[i].indexOf("Y")>-1)
      y = finnTallVerdiFraLinjeRaaFil("Y", gCodeArrayOnlyLinesOfG01[i]);

    if (gCodeArrayOnlyLinesOfG01[i].indexOf("Z")>-1)
      z = finnTallVerdiFraLinjeRaaFil("Z", gCodeArrayOnlyLinesOfG01[i]);

    if (gCodeArrayOnlyLinesOfG01[i].indexOf("F")>-1)
      f = finnTallVerdiFraLinjeRaaFil("F", gCodeArrayOnlyLinesOfG01[i]) * speedScale;

    if (f<0.01)
      f=1;

    if ( f > maxF)
      maxF = f;

    gCodeArrayOnlyLinesOfG01[i] = "G01 X" + x + " Y" + y + " Z" + z + " F" + r(f); // denne kan evt. lagres til fil
  }
  System.out.printf("   Max F (skalert) som skal kjores =  %.2f mm/sec \n", maxF);
}

//****************************************************************

void parse_gCodeArrayOnlyLinesOfG01_til_lineArrayXYZT()
{
  lineArrayXYZT = new double[gCodeArrayOnlyLinesOfG01.length][4];

  double lineLengthMM; // line length for each G01 line in mm

  for (int L=0; L < gCodeArrayOnlyLinesOfG01.length; L++) // løper alle linjer i "1.nc"
  {
    lineArrayXYZT[L][0] = (finnTallVerdiFraLinje("X", gCodeArrayOnlyLinesOfG01[L]) ); // setter inn X verdi
    lineArrayXYZT[L][1] = (finnTallVerdiFraLinje("Y", gCodeArrayOnlyLinesOfG01[L]) ); // setter inn Y verdi
    lineArrayXYZT[L][2] = (finnTallVerdiFraLinje("Z", gCodeArrayOnlyLinesOfG01[L]) ); // setter inn Z verdi

    double F = finnTallVerdiFraLinje("F", gCodeArrayOnlyLinesOfG01[L]); // hastighet i mm/sec

    if (L == 0) // maskin står i 0,0,0  forst
    {
      lineLengthMM = Math.sqrt( (lineArrayXYZT[L][0] - 0) * (lineArrayXYZT[L][0] - 0) +
        (lineArrayXYZT[L][1] - 0) * (lineArrayXYZT[L][1] - 0) +
        (lineArrayXYZT[L][2] - 0) * (lineArrayXYZT[L][2] - 0) );

      lineArrayXYZT[L][3] = lineLengthMM / F; // setter inn slutt tid
    } else
    {
      lineLengthMM = Math.sqrt(
        (lineArrayXYZT[L][0] - lineArrayXYZT[L-1][0]) * (lineArrayXYZT[L][0] - lineArrayXYZT[L-1][0]) +
        (lineArrayXYZT[L][1] - lineArrayXYZT[L-1][1]) * (lineArrayXYZT[L][1] - lineArrayXYZT[L-1][1]) +
        (lineArrayXYZT[L][2] - lineArrayXYZT[L-1][2]) * (lineArrayXYZT[L][2] - lineArrayXYZT[L-1][2]) );

      lineArrayXYZT[L][3] = (lineLengthMM / F) + lineArrayXYZT[L-1][3]; // setter inn slutt tid
    }
  }
  
  println("G01 code overført til format XYZT), antall linjer = " + lineArrayXYZT.length); 
  System.out.printf("   Total run time = %.2f sec / %.2f min \n", lineArrayXYZT[lineArrayXYZT.length-1][3], lineArrayXYZT[lineArrayXYZT.length-1][3]/60.0);
}

//****************************************************************

void parse_lineArrayXYZT_to_interpolPointArray()
{
  // parsing from lineArrayXYZT (short array) to interpolPointArray (long array)
  
  totalNoOfSteps = (int)( lineArrayXYZT[lineArrayXYZT.length-1][3] * stepFrequency ); 
  interpolPointArray = new double[totalNoOfSteps][3];

  int gCodeLineNo = 0; // (første linjesegment)

  // running over each index in interpolPointArray (long array)
  for (int index=0; index<interpolPointArray.length; index++)
  {
    double currentTime = index * (1.0/stepFrequency);

    if (gCodeLineNo == 0) // (første linjesegment)
    {
      double[] startCoord = {(double)0, (double)0, (double)0};
      interpolPointArray[index] = interpolateSinglePoint(currentTime, 
        startCoord, 0, 
        lineArrayXYZT[gCodeLineNo], lineArrayXYZT[gCodeLineNo][3]);
    } else // (gjeldende linjesegment current punkt ligger på underveis)
    {
      interpolPointArray[index] = interpolateSinglePoint(currentTime, 
        lineArrayXYZT[gCodeLineNo-1], lineArrayXYZT[gCodeLineNo-1][3], 
        lineArrayXYZT[gCodeLineNo], lineArrayXYZT[gCodeLineNo][3]);
    }

    while (currentTime > lineArrayXYZT[gCodeLineNo][3]) // laster inn ny gCodeLinje (linjesegment)
      gCodeLineNo++;
  }
  
  println("XYZT er interpolert til " + totalNoOfSteps + " ant XYZ steps" ); 
  println("   Step size = " + stepSizeInMM + " (mm)");
  println("   Valgt mikrostep frekvens = " + stepFrequency + " (Hz) - pulslengde = " + r(1.0*1000/(2.0*stepFrequency)) + " mSec");
  println("   Max mulige hastighet med valgt step frekvens = " + (stepFrequency * stepSizeInMM) + " (mm/sec)");
}

//****************************************************************

double[] interpolateSinglePoint(double currentTime, double[] startCoord, double startTime, double[] endCoord, double endTime)
{
  // equation for y axis: y = a*t + b
  // a = ( endCoord[y] - startCoord[y] ) / (endTime - startTime)
  // b = startCoord[y] - a*startTime

  double p[] = {0, 0, 0};

  // X axis
  double a = ( endCoord[0] - startCoord[0] ) / (endTime - startTime);
  double b = startCoord[0] - a*startTime;
  p[0] = a * currentTime + b;

  // Y axis
  a = ( endCoord[1] - startCoord[1] ) / (endTime - startTime);
  b = startCoord[1] - a*startTime;
  p[1] = a * currentTime + b;

  // Z axis
  a = ( endCoord[2] - startCoord[2] ) / (endTime - startTime);
  b = startCoord[2] - a*startTime;
  p[2] = a * currentTime + b;   

  return p;
}

//****************************************************************

void parse_interpolPointArray_to_motorByteArray()
{
  // parsing from interpolPointArray to motorByteArray, 
  // Koder bare rett fram over til bits, men må finne ut om det trengs et nytt stepp/dir osv
  // Arduino nuller ut bittene slik at man får pulser

  motorByteArray = new byte[interpolPointArray.length];

  // current number of steps
  int x, y, z;

  // machine is starting in step no 0,0,0
  int xOld = 0;
  int yOld = 0;
  int zOld = 0;

  for (int index=0; index<interpolPointArray.length; index++)
  {
    motorByteArray[index] = 0;

    x = (int)(interpolPointArray[index][0] / stepSizeInMM);
    if ( x > xOld )
      motorByteArray[index] = (byte)(motorByteArray[index] + 3); // X step, dir=1
    else if ( x < xOld )
      motorByteArray[index] = (byte)(motorByteArray[index] + 1); // X step, dir=0

    y = (int)(interpolPointArray[index][1] / stepSizeInMM);
    if ( y > yOld )
      motorByteArray[index] = (byte)(motorByteArray[index] + 12); // Y step, dir=1
    else if ( y < yOld )
      motorByteArray[index] = (byte)(motorByteArray[index] + 4); // Y step, dir=0

    z = (int)(interpolPointArray[index][2] / stepSizeInMM);
    if ( z > zOld )
      motorByteArray[index] = (byte)(motorByteArray[index] + 48); // Z step, dir=1
    else if ( z < zOld )
      motorByteArray[index] = (byte)(motorByteArray[index] + 16); // Z step, dir=0

    if ( (x>xOld+1) || (x<xOld-1) || (y>yOld+1) || (y<yOld-1) || (z>zOld+1) || (z<zOld-1))
      println("ERROR: speed to high for stepsize - line no: " + index);    

    xOld = x;
    yOld = y;
    zOld = z;
  }
  
  println("Alle interpolerte XYZsteps er overført til motorsteps (bytes)");  
  saveBytes(motorByteArrayFileName, motorByteArray);
  println("Motorsteps er lagret til fil: " + motorByteArrayFileName);
}

//****************************************************************
//****************************************************************
//****************************************************************

double finnTallVerdiFraLinje(String parameterNavn, String linje)
{
  int parameterNavnIndex = linje.indexOf(parameterNavn);

  if (parameterNavn == "F") // siste parameter på linjen
    return Double.parseDouble(linje.substring(parameterNavnIndex + 1, linje.length()));
  else
  {
    int spaceIndex = linje.indexOf(" ", parameterNavnIndex); // finner avslutning paa tallverdi
    return Double.parseDouble(linje.substring(parameterNavnIndex + 1, spaceIndex));
  }
}

//****************************************************************

double finnTallVerdiFraLinjeRaaFil(String parameterNavn, String linje)
{
  int parameterNavnIndex = linje.indexOf(parameterNavn);

  if (parameterNavn == "F") // siste parameter pÃ¥ linjen
    return Double.parseDouble(linje.substring(parameterNavnIndex + 1, linje.length()));
  else
  {       
    int spaceIndex = linje.indexOf(" ", parameterNavnIndex); // finner avslutning paa tallverdi

    if (spaceIndex == -1)
      return Double.parseDouble(linje.substring(parameterNavnIndex + 1, linje.length()));

    return Double.parseDouble(linje.substring(parameterNavnIndex + 1, spaceIndex));
  }
}

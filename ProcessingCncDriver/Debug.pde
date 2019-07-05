
void print_gCodeArrayOnlyLinesOfG01(int star, int end)
{
  println("");
  println("gCodeArrayOnlyLinesOfG01");

  if (end > gCodeArrayOnlyLinesOfG01.length)
    end = gCodeArrayOnlyLinesOfG01.length;

  for (int i=star; i<end; i++)
    println( "  " + gCodeArrayOnlyLinesOfG01[i] );

  println(" ");
}


//****************************************************************

void print_lineArrayXYZT(int star, int end)
{
  println("");
  println("lineArrayXYZT");

  if (end > lineArrayXYZT.length)
    end = lineArrayXYZT.length;

  for (int i=star; i<end; i++)
  {
    print( r(lineArrayXYZT[i][0]) + " ");
    print( r(lineArrayXYZT[i][1]) + " ");
    print( r(lineArrayXYZT[i][2]) + "  ");
    println( r(lineArrayXYZT[i][3]) );
  }
  println(" ");
}

//****************************************************************

void print_interpolPointArray(int star, int end)
{
  println("");
  println("interpolPointArray");

  if (end > interpolPointArray.length)
    end = interpolPointArray.length;

  for (int i=star; i<end; i++)
  {
    print( "  " + r(interpolPointArray[i][0]) + " " );
    print( "  " + r(interpolPointArray[i][1]) + " " );
    println( "  " + r(interpolPointArray[i][2]) );
  }

  println(" ");
}

//****************************************************************

void print_motorByteArray(int star, int end)
{
  println("");
  println("interpolPointArray");

  if (end > motorByteArray.length)
    end = motorByteArray.length;

  for (int i=star; i<end; i++)
  {
    print( "  " + binary(motorByteArray[i]) + " " );
    print( "  " + binary(motorByteArray[i]) + " " );
    println( "  " + binary(motorByteArray[i]) );
  }

  println(" ");
}

//****************************************************************

void printEtc1(int star, int end)
{
  if (end > gCodeArrayOnlyLinesOfG01.length)
    end = gCodeArrayOnlyLinesOfG01.length;

  println("gCodeArrayOnlyLinesOfG01 - lineArrayXYZT");
  println("Etc1");
  for (int i=star; i<end; i++)
  {
    print( "  " + gCodeArrayOnlyLinesOfG01[i] + " / ");
    print( r(lineArrayXYZT[i][0]) + " ");
    print( r(lineArrayXYZT[i][1]) + " ");
    print( r(lineArrayXYZT[i][2]) + "  ");
    println( r(lineArrayXYZT[i][3]) );
  }
  println(" ");
}

//****************************************************************

void printEtc2(int star, int end)
{
  if (end > interpolPointArray.length)
    end = interpolPointArray.length;  

  println("");
  println("interpolPointArray - motorByteArray");
  for (int i=star; i<end; i++)
  {
    print( "  " + r(interpolPointArray[i][0]) );
    print( " " + r(interpolPointArray[i][1]) );
    print( " " + r(interpolPointArray[i][2]) );
    println( "  " + binary(motorByteArray[i]) );
  }
  println(" ");
}

//****************************************************************

void printAll(float starT, float endT)
{

  println("");
  println("gCodeArrayOnlyLinesOfG01 - lineArrayXYZT - interpolPointArray - motorByteArray");

  int gCodeTeller = 0;
  for (int i=0; i<interpolPointArray.length; i++)
  {
    double currentTime = i * (1.0/stepFrequency);

    while (currentTime > lineArrayXYZT[gCodeTeller][3]) 
    {
      //println( " ");
      gCodeTeller++;
    }

    if (currentTime > starT &&  currentTime < endT)  
    {
      print( "t:" + r(currentTime) + " sec     ");
      
      print(gCodeArrayOnlyLinesOfG01[gCodeTeller] + "    ");
      
      print( r(lineArrayXYZT[gCodeTeller][0]) + " ");
      print( r(lineArrayXYZT[gCodeTeller][1]) + " ");
      print( r(lineArrayXYZT[gCodeTeller][2]) + " ");
      print( r(lineArrayXYZT[gCodeTeller][3]) + "    ");

      print( "  " + r(interpolPointArray[i][0]) );
      print( " " + r(interpolPointArray[i][1]) );
      print( " " + r(interpolPointArray[i][2]) );
      println( "  " + binary(motorByteArray[i]) );
    }
  }
  println(" ");
}

//****************************************************************

String r(double d)
{
  String s = "" + d + "                          ";
  return s.substring(0, 6);
}

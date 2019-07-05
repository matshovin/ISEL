/*


1)    Filtrer fra fil inn i gCodeArrayOnlyLinesOfG01, G01 kode String array
2)    Parse the string array gCodeArrayOnlyLinesOfG01 to "lineArrayXYZT", format: X Y Z T, 
      line endpositions (mm) and line endtime (sec)
3)    Calculate numb of CNC steps from max T
4)    Declare "interpolPointArray" (interpolated XYZ values (mm)), format: X Y Z 
5)    Iterate all CNC steps and find corresponding G line, generate line equation and interpolation point
6)    Declare "motorByteArray" and generate motor control bytes from all interpolation points in "interpolPointArray"
7)    Save motorByteArray to file "1.stp"

G.code file format for all lines:  
G01 X1.232 Y100.0 Z-33.12 F15  (X,Y,Z in mm, F in mm/sec)

Tool tip is manually located i 0,0,0 (WCS) first
Første G00/G01 i fil må være forskjellig fra endpunkt 0,0,0





*/

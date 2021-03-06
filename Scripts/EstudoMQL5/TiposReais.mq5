//+------------------------------------------------------------------+
//|                                                   TiposReais.mq5 |
//|                              Copyright 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool EqualDoubles(double d1,double d2,double epsilon)
  {
   if(epsilon<0)
      epsilon=-epsilon;
//--- 
   if(d1-d2>epsilon)
      return false;
   if(d1-d2<-epsilon)
      return false;
//--- 
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2)
  {
   if(NormalizeDouble(number1-number2,8)==0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
/*
   double a=12.111; 
   double b=-956.1007; 
   float  c =0.0001; 
   float  d =16;
*/
/*
   double c1=1.12123515e-25; 
   double c2=0.000000000000000000000000112123515; // 24 zeros após o ponto decimal 
    
   Print("1. c1 =",DoubleToString(c1,16)); 
   // Resultado: 1. c1 = 0.0000000000000000 
    
   Print("2. c1 =",DoubleToString(c1,-16)); 
   // Resultado: 2. c1 = 1.1212351499999999e-025 
  
   Print("3. c2 =",DoubleToString(c2,-16)); 
   // Resultado: 3. c2 = 1.1212351499999999e-025  
   */
//--- 
/*
   double three=3.0; 
   double x,y,z; 
   x=1/three; 
   y=4/three; 
   z=5/three; 
   if(x+y==z)  
      Print("1/3 + 4/3 == 5/3"); 
   else  
      Print("1/3 + 4/3 != 5/3"); 
// Resultado: 1/3 + 4/3 != 5/3 
*/
/*
   double d_val=0.7;
   float  f_val=0.7;
   if(EqualDoubles(d_val,f_val,0.000000000000001))
      Print(d_val," equals ",f_val);
   else
      Print("Diferente: d_val = ",DoubleToString(d_val,16),"  f_val = ",DoubleToString(f_val,16));
// Resultado: Diferente: d_val= 0.7000000000000000   f_val= 0.6999999880790710 
//+------------------------------------------------------------------+
*/
   double d_val=0.3; 
   //float  f_val=0.3; 
   double f_val = 0.3;
   if(CompareDoubles(d_val,f_val))  
      Print(d_val," iguais ",f_val); 
   else  
      Print("Diferente: d_val = ",DoubleToString(d_val,16),"  f_val = ",DoubleToString(f_val,16)); 
// Resultado: Diferente: d_val= 0.3000000000000000   f_val= 0.3000000119209290 

  }
//+------------------------------------------------------------------+

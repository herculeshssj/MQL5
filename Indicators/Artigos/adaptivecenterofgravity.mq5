//+------------------------------------------------------------------+
//|                                      AdaptiveCenterOfGravity.mq5 |
//|                                      Copyright 2011, Investeo.pl |
//|                                               http://Investeo.pl |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, Investeo.pl"
#property link      "http://Investeo.pl"
#property version   "1.00"
#property indicator_separate_window

#property description "Adaptive CG indicator - described by John F. Ehlers"
#property description "in \"Cybernetic Analysis for Stocks and Futures\""
#property description "This indicator is available for free download."
#property description "Article: https://www.mql5.com/pt/articles/288"

#property indicator_buffers 2
#property indicator_plots 2
#property indicator_width1 1
#property indicator_width2 1
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_color1  Green
#property indicator_color2  Red
#property indicator_label1  "Cycle"
#property indicator_label2  "Trigger Line"

#define Price(i) ((high[i]+low[i])/2.0)

double Smooth[];
double Cycle[];
double Trigger[];

int hCyclePeriod;

input double InpAlpha=0.07; // alpha
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping 
   ArraySetAsSeries(Cycle,true);
   ArraySetAsSeries(Trigger,true);
   ArraySetAsSeries(Smooth,true);

   SetIndexBuffer(0,Cycle,INDICATOR_DATA);
   SetIndexBuffer(1,Trigger,INDICATOR_DATA);

   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

   hCyclePeriod=iCustom(NULL,0,"Artigos\\CyclePeriod",InpAlpha);
   if(hCyclePeriod==INVALID_HANDLE)
     {
      Print("CyclePeriod indicator not available!");
      return(-1);
     }

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---   
   long tickCnt[1];
   int i, copied;
   double Num,Denom; // Numerator and Denominator for CG
   double CG_len;
   int ticks=CopyTickVolume(Symbol(), 0, 0, 1, tickCnt);
   if(ticks!=1) return(rates_total);
   double CyclePeriod[1];

   Comment(tickCnt[0]);

   if(prev_calculated==0 || tickCnt[0]==1)
     {
      //--- last counted bar will be recounted
      int nLimit=rates_total-prev_calculated-1; // start index for calculations

      ArraySetAsSeries(high,true);
      ArraySetAsSeries(low,true);

      ArrayResize(Smooth,Bars(_Symbol,_Period));
      ArrayResize(Cycle,Bars(_Symbol,_Period));
      
      copied=CopyBuffer(hCyclePeriod,0,0,1,CyclePeriod);

      if(copied<=0)
        {
         Print("FAILURE: Could not get values from CyclePeriod indicator.");
         return -1;
        }

      if(nLimit>rates_total-int(CyclePeriod[0])-2) // adjust for last bars
         nLimit=rates_total-int(CyclePeriod[0])-2;


      for(i=nLimit;i>=0 && !IsStopped();i--)
        {
         copied=CopyBuffer(hCyclePeriod,0,i,1,CyclePeriod);

         if(copied<=0)
           {
            Print("FAILURE: Could not get values from CyclePeriod indicator.");
            return -1;
           }
         CG_len = floor(CyclePeriod[0]/2.0);
         //Print("CG_len="+DoubleToString(CG_len));
         
         Num=0.0;
         Denom=0.0;
         for(int count=0; count<int(CG_len); count++)
           {
            Num+=(1.0+count)*Price(i+count);
            Denom+=Price(i+count);
           }
         if(Denom!=0.0)
            Cycle[i]=-Num/Denom+(CG_len+1.0)/2.0;
         else
            Cycle[i]=0.0;

         //Print(__FILE__+__FUNCTION__+" received values: ",rCnt);
         Trigger[i]=Cycle[i+1];
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

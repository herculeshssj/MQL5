//+------------------------------------------------------------------+
//|                                                 Adaptive RVI.mq5 |
//|                        Based on RVI by MetaQuotes Software Corp. |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009, MetaQuotes Software Corp."
#property copyright   "2011, Adaptive version Investeo.pl"
#property link        "http://www.mql5.com"
#property description "Adaptive Relative Vigor Index"
#property description "Article: https://www.mql5.com/pt/articles/288"

//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_color1  Green
#property indicator_color2  Red
#property indicator_label1  "AdaptiveRVI"
#property indicator_label2  "Signal"

#define Price(i) ((high[i]+low[i])/2.0)

//--- input parameters
input int InpRVIPeriod=10; // Initial RVI Period
//--- indicator buffers
double    ExtRVIBuffer[];
double    ExtSignalBuffer[];
//---
int hCyclePeriod; 
input double InpAlpha=0.07; // alpha for Cycle Period
int AdaptiveRVIPeriod;

#define TRIANGLE_PERIOD  3
#define AVERAGE_PERIOD   (TRIANGLE_PERIOD*2)
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtRVIBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtSignalBuffer,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,3);
   hCyclePeriod=iCustom(NULL,0,"Artigos\\CyclePeriod",InpAlpha);
   if(hCyclePeriod==INVALID_HANDLE)
     {
      Print("CyclePeriod indicator not available!");
      return(-1);
     }
   
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,(InpRVIPeriod-1)+TRIANGLE_PERIOD);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,(InpRVIPeriod-1)+AVERAGE_PERIOD);
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"AdaptiveRVI");
   PlotIndexSetString(0,PLOT_LABEL,"AdaptiveRVI");
   PlotIndexSetString(1,PLOT_LABEL,"Signal");
//--- initialization done
  return 0;
  }
//+------------------------------------------------------------------+
//| Relative Vigor Index                                             |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
   int    i,j,nLimit;
   double dValueUp,dValueDown,dNum,dDeNum;
   double CyclePeriod[4];
   int copied;
   
   copied=CopyBuffer(hCyclePeriod,0,0,4,CyclePeriod);

         if(copied<=0)
           {
            Print("FAILURE: Could not get values from CyclePeriod indicator.");
            return -1;
           }
   AdaptiveRVIPeriod = int(floor((4*CyclePeriod[0]+3*CyclePeriod[1]+2*CyclePeriod[2]+CyclePeriod[3])/20.0));
//--- check for bars count
   if(rates_total<=AdaptiveRVIPeriod+AVERAGE_PERIOD+2) return(0); // exit with zero result
//--- check for possible errors
   if(prev_calculated<0) return(0); // exit with zero result
//--- last counted bar will be recounted
   nLimit=AdaptiveRVIPeriod+2;
   if(prev_calculated>AdaptiveRVIPeriod+TRIANGLE_PERIOD+2)
      nLimit=prev_calculated-1;
//--- set empty value for uncalculated bars
   if(prev_calculated==0)
     {
      for(i=0;i<AdaptiveRVIPeriod+TRIANGLE_PERIOD;i++) ExtRVIBuffer[i]=0.0;
      for(i=0;i<AdaptiveRVIPeriod+AVERAGE_PERIOD;i++)  ExtSignalBuffer[i]=0.0;
     }
//--- RVI counted in the 1-st buffer
   for(i=nLimit;i<rates_total && !IsStopped();i++)
     {
      copied=CopyBuffer(hCyclePeriod,0,rates_total-i-1,4,CyclePeriod);

         if(copied<=0)
           {
            Print("FAILURE: Could not get values from CyclePeriod indicator.");
            return -1;
           }
      AdaptiveRVIPeriod = int(floor((4*CyclePeriod[0]+3*CyclePeriod[1]+2*CyclePeriod[2]+CyclePeriod[3])/20.0));
      dNum=0.0;
      dDeNum=0.0;
      for(j=i;j>MathMax(i-AdaptiveRVIPeriod, 3);j--)
        {
         //Print("rates_total="+IntegerToString(rates_total)+" nLimit="+IntegerToString(nLimit)+
         //      " AdaptiveRVIPeriod="+IntegerToString(AdaptiveRVIPeriod)+" j="+IntegerToString(j));
         dValueUp=Close[j]-Open[j]+2*(Close[j-1]-Open[j-1])+2*(Close[j-2]-Open[j-2])+Close[j-3]-Open[j-3];
         dValueDown=High[j]-Low[j]+2*(High[j-1]-Low[j-1])+2*(High[j-2]-Low[j-2])+High[j-3]-Low[j-3];
         dNum+=dValueUp;
         dDeNum+=dValueDown;
        }
      if(dDeNum!=0.0)
         ExtRVIBuffer[i]=dNum/dDeNum;
      else
         ExtRVIBuffer[i]=dNum;
     }
//--- signal line counted in the 2-nd buffer
   nLimit=AdaptiveRVIPeriod+TRIANGLE_PERIOD+2;
   if(prev_calculated>AdaptiveRVIPeriod+AVERAGE_PERIOD+2)
      nLimit=prev_calculated-1;
   for(i=nLimit;i<rates_total && !IsStopped();i++) ExtSignalBuffer[i]=(ExtRVIBuffer[i]+2*ExtRVIBuffer[i-1]+2*ExtRVIBuffer[i-2]+ExtRVIBuffer[i-3])/AVERAGE_PERIOD;

//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+

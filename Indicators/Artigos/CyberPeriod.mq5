//+------------------------------------------------------------------+
//|                                                  CyclePeriod.mq5 |
//|                                      Copyright 2011, Investeo.pl |
//|                                               http://Investeo.pl |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, Investeo.pl"
#property link      "http://Investeo.pl"
#property version   "1.00"
#property indicator_separate_window

#property description "CyclePeriod indicator - described by John F. Ehlers"
#property description "in \"Cybernetic Analysis for Stocks and Futures\""
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
//double Price[];
double Q1[]; // Quadrature component
double I1[]; // InPhase component
double DeltaPhase[];
double InstPeriod[];
double CyclePeriod[];


input double InpAlpha=0.07; // alpha
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping 
   ArraySetAsSeries(Cycle,true);
   ArraySetAsSeries(CyclePeriod,true);
   ArraySetAsSeries(Trigger,true); 
   ArraySetAsSeries(Smooth,true);
   //ArraySetAsSeries(Price,true);
   
   SetIndexBuffer(0,CyclePeriod,INDICATOR_DATA);
   SetIndexBuffer(1,Trigger,INDICATOR_DATA);
   
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

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
   int i;
   int ticks=CopyTickVolume(Symbol(), 0, 0, 1, tickCnt);
   if(ticks!=1) return(rates_total);
   double DC, MedianDelta;

   Comment(tickCnt[0]);

   if(prev_calculated==0 || tickCnt[0]==1)
     {
      //--- last counted bar will be recounted
      int nLimit=rates_total-prev_calculated-1; // start index for calculations

      ArraySetAsSeries(high,true);
      ArraySetAsSeries(low,true);
      
      ArrayResize(Smooth,Bars(_Symbol,_Period));
      ArrayResize(Cycle,Bars(_Symbol,_Period));
      //ArrayResize(Price,Bars(_Symbol,_Period));
      ArrayResize(CyclePeriod,Bars(_Symbol,_Period));
      ArrayResize(InstPeriod,Bars(_Symbol,_Period));
      ArrayResize(Q1,Bars(_Symbol,_Period));
      ArrayResize(I1,Bars(_Symbol,_Period));
      ArrayResize(DeltaPhase,Bars(_Symbol,_Period));
      
      //for(i=int(MathMax(nLimit,5.0));i>=0 && !IsStopped();i--)
      //   Price[i] = (high[i]+low[i])/2.0;
      
      if (nLimit>rates_total-7) // adjust for last bars
         nLimit=rates_total-7;   
      
      for(i=nLimit;i>=0 && !IsStopped();i--)   
      {
         Smooth[i] = (Price(i)+2*Price(i+1)+2*Price(i+2)+Price(i+3))/6.0;
   
         if (i<rates_total-7)
         {
            Cycle[i] = (1.0-0.5*InpAlpha) * (1.0-0.5*InpAlpha) * (Smooth[i]-2.0*Smooth[i+1]+Smooth[i+2])
                      +2.0*(1.0-InpAlpha)*Cycle[i+1]-(1.0-InpAlpha)*(1.0-InpAlpha)*Cycle[i+2];
                   
            // Print("Smooth["+IntegerToString(i)+"]="+DoubleToString(Smooth[i])+" Cycle["+IntegerToString(i)+"]="+DoubleToString(Cycle[i]));
         } else         
         {
            Cycle[i]=(Price(i)-2.0*Price(i+1)+Price(i+2))/4.0;
         }
         
         Q1[i] = (0.0962*Cycle[i]+0.5769*Cycle[i+2]-0.5769*Cycle[i+4]-0.0962*Cycle[i+6])*(0.5+0.08*InstPeriod[i+1]);
         I1[i] = Cycle[i+3];
         
         if (Q1[i]!=0.0 && Q1[i+1]!=0.0) 
            DeltaPhase[i] = (I1[i]/Q1[i]-I1[i+1]/Q1[i+1])/(1.0+I1[i]*I1[i+1]/(Q1[i]*Q1[i+1]));
         if (DeltaPhase[i] < 0.1)
            DeltaPhase[i] = 0.1;
         if (DeltaPhase[i] > 0.9)
            DeltaPhase[i] = 0.9;
        
         MedianDelta = Median(DeltaPhase, i, 5);
         
         if (MedianDelta == 0.0)
            DC = 15.0;
         else
            DC = (6.28318/MedianDelta) + 0.5;
        
         InstPeriod[i] = 0.33 * DC + 0.67 * InstPeriod[i+1];
         CyclePeriod[i] = 0.15 * InstPeriod[i] + 0.85 * CyclePeriod[i+1];
         Trigger[i] = CyclePeriod[i+1];
      }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

double Median(double& arr[], int idx, int m_len)
{
   double MedianArr[];
   int copied;
   double result = 0.0;
   
   ArraySetAsSeries(MedianArr, true);
   ArrayResize(MedianArr, m_len);
   
   copied = ArrayCopy(MedianArr, arr, 0, idx, m_len);
   if (copied == m_len)
   {
      ArraySort(MedianArr);
      if (m_len %2 == 0) 
            result = (MedianArr[m_len/2] + MedianArr[(m_len/2)+1])/2.0;
      else
            result = MedianArr[m_len / 2];
      
   }
   else Print(__FILE__+__FUNCTION__+"median error - wrong number of elements copied."); 
   return result; 
}
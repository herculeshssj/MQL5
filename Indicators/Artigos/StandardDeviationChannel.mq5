//+------------------------------------------------------------------+
//|                                     StandardDeviationChannel.mq5 |
//|                                                   Sergey Greecie |
//|                                               sergey1294@list.ru |
//+------------------------------------------------------------------+
#property copyright "Sergey Greecie"
#property link      "sergey1294@list.ru"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_color1  DodgerBlue
#property indicator_color2  DodgerBlue
#property indicator_color3  Blue
#property indicator_style3  STYLE_DOT
//---- input parameters
input int                InpMAPeriod=14;              // Period
input ENUM_MA_METHOD     InpMAMethod=MODE_SMA;        // Method
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_CLOSE; // Applied price
input double             InpDeviation=2.0;            // Deviation
//--- indicator buffers
double                   ExtUpBuffer[];
double                   ExtDownBuffer[];
double                   ExtMiddBuffer[];
double                   ExtMABuffer[];
double                   ExtStdDevBuffer[];
//--- indicator handle
int                      ExtMAHandle;
int                      ExtStdDevMAHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtUpBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtDownBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtMiddBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtMABuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,ExtStdDevBuffer,INDICATOR_CALCULATIONS);
//--- set first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpMAPeriod-1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,InpMAPeriod-1);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,InpMAPeriod-1);
//--- get handles
   ExtMAHandle=iMA(NULL,0,InpMAPeriod,0,InpMAMethod,InpAppliedPrice);
   ExtStdDevMAHandle=iStdDev(NULL,0,InpMAPeriod,0,InpMAMethod,InpAppliedPrice);
   return(0);
  }
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
//--- return value of prev_calculated for next call
   if(rates_total<InpMAPeriod)
      return(0);
//--- not all data may be calculated
   int calculated=BarsCalculated(ExtMAHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtMAHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
   calculated=BarsCalculated(ExtStdDevMAHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtStdDevMAHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
//--- we can copy not all data
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
//--- get MA buffer
   if(CopyBuffer(ExtMAHandle,0,0,to_copy,ExtMABuffer)<=0)
     {
      Print("Getting fast MA is failed! Error",GetLastError());
      return(0);
     }
//--- get StdDev buffer
   if(CopyBuffer(ExtStdDevMAHandle,0,0,to_copy,ExtStdDevBuffer)<=0)
     {
      Print("Getting slow StdDev is failed! Error",GetLastError());
      return(0);
     }
//---
   int limit;
   if(prev_calculated==0)
      limit=0;
   else limit=prev_calculated-1;
//--- the main loop of calculations
   for(int i=limit;i<rates_total;i++)
     {
      ExtMiddBuffer[i]=ExtMABuffer[i];
      ExtUpBuffer[i]=ExtMABuffer[i]+(InpDeviation*ExtStdDevBuffer[i]);
      ExtDownBuffer[i]=ExtMABuffer[i]-(InpDeviation*ExtStdDevBuffer[i]);
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+

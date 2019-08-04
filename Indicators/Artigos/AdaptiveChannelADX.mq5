//+------------------------------------------------------------------+
//|                                           AdaptiveChannelADX.mq5 |
//|                                                   Sergey Greecie |
//|                                               sergey1294@list.ru |
//+------------------------------------------------------------------+
#property copyright "Sergey Greecie"
#property link      "sergey1294@list.ru"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_color1  DodgerBlue
#property indicator_color2  DodgerBlue
#property indicator_color3  Blue
#property indicator_style3  STYLE_DOT
//--- input parameters
input int ADX_period=14; // Period
//---- buffers
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtMiddBuffer[];
double adxBuffer[];
//--- handles for ADX
int h_adx;
//--- bars minimum for calculation
#define DATA_LIMIT 60
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtMiddBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,adxBuffer,INDICATOR_CALCULATIONS);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,DATA_LIMIT);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,DATA_LIMIT);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,DATA_LIMIT);
//---- line shifts when drawing
   PlotIndexSetInteger(0,PLOT_SHIFT,1);
   PlotIndexSetInteger(1,PLOT_SHIFT,1);
   PlotIndexSetInteger(2,PLOT_SHIFT,1);
//--- get handles
   h_adx=iADX(Symbol(),0,ADX_period);
//--- initialization done
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

   if(rates_total<DATA_LIMIT)
      return(0);

   int calculated=BarsCalculated(h_adx);
   if(calculated<rates_total)
     {
      return(0);
     }

   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }

   if(CopyBuffer(h_adx,0,0,to_copy,adxBuffer)<=0)
     {
      return(0);
     }

   int i,limit;
   if(prev_calculated<=DATA_LIMIT)
      limit=DATA_LIMIT;
   else limit=prev_calculated-1;

   for(i=limit;i<rates_total;i++)
     {
      int InpChannelPeriod=(int)floor(150/adxBuffer[i]);
      ExtHighBuffer[i]=Highest(high,InpChannelPeriod,i);
      ExtLowBuffer[i]=Lowest(low,InpChannelPeriod,i);
      ExtMiddBuffer[i]=(ExtHighBuffer[i]+ExtLowBuffer[i])/2.0;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| get highest value for range                                      |
//+------------------------------------------------------------------+
double Highest(const double &array[],int range,int fromIndex)
  {
   double res;
   int i;
//---
   res=array[fromIndex];
   for(i=fromIndex;i>fromIndex-range && i>=0;i--)
     {
      if(res<array[i]) res=array[i];
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| get lowest value for range                                       |
//+------------------------------------------------------------------+
double Lowest(const double &array[],int range,int fromIndex)
  {
   double res;
   int i;
//---
   res=array[fromIndex];
   for(i=fromIndex;i>fromIndex-range && i>=0;i--)
     {
      if(res>array[i]) res=array[i];
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
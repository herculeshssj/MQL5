//+------------------------------------------------------------------+
//|                                                Price Channel.mq5 |
//|                                                   Sergey Greecie |
//|                                               sergey1294@list.ru |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_color1  DodgerBlue
#property indicator_color2  DodgerBlue
#property indicator_color3  Blue
#property indicator_style3  STYLE_DOT
//--- input parameters
input int InpChannelPeriod=22; // Period
//--- indicator buffers
double    ExtHighBuffer[];
double    ExtLowBuffer[];
double    ExtMiddBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtMiddBuffer,INDICATOR_DATA);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- set first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpChannelPeriod);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,InpChannelPeriod);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,InpChannelPeriod);
//---- line shifts when drawing
   PlotIndexSetInteger(0,PLOT_SHIFT,1);
   PlotIndexSetInteger(1,PLOT_SHIFT,1);
   PlotIndexSetInteger(2,PLOT_SHIFT,1);
//--- set drawing line empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//--- initialization done
  }
//+------------------------------------------------------------------+
//| Price Channell                                                   |
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
   int i,limit;
//--- check for rates
   if(rates_total<InpChannelPeriod)
      return(0);
//--- preliminary calculations
   if(prev_calculated==0)
      limit=InpChannelPeriod;
   else limit=prev_calculated-1;
//--- the main loop of calculations
   for(i=limit;i<rates_total;i++)
     {
      ExtHighBuffer[i]=Highest(High,InpChannelPeriod,i);
      ExtLowBuffer[i]=Lowest(Low,InpChannelPeriod,i);
      ExtMiddBuffer[i]=(ExtHighBuffer[i]+ExtLowBuffer[i])/2.0;
     }
//--- OnCalculate done. Return new prev_calculated.
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

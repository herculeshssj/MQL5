//+------------------------------------------------------------------+
//|                                          PriceChannelGalaher.mq5 |
//|                                                   Sergey Greecie |
//|                                               sergey1294@list.ru |
//+------------------------------------------------------------------+
#property copyright "Sergey Greecie"
#property link      "sergey1294@list.ru"
#property version   "1.00"
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
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,period(_Period));
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,period(_Period));
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,period(_Period));
//---- line shifts when drawing
   PlotIndexSetInteger(0,PLOT_SHIFT,1);
   PlotIndexSetInteger(1,PLOT_SHIFT,1);
   PlotIndexSetInteger(2,PLOT_SHIFT,1);

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
   if(rates_total<period(_Period))
      return(0);
//--- preliminary calculations
   if(prev_calculated==0)
      limit=period(_Period);
   else limit=prev_calculated-1;
//--- the main loop of calculations
   for(i=limit;i<rates_total;i++)
     {
      ExtHighBuffer[i]=Highest(High,period(_Period),i);
      ExtLowBuffer[i]=Lowest(Low,period(_Period),i);
      ExtMiddBuffer[i]=(ExtHighBuffer[i]+ExtLowBuffer[i])/2.0;;
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
int period(ENUM_TIMEFRAMES tf)
  {
   switch(tf)
     {
      case PERIOD_M1:     return(14400);
      case PERIOD_M2:     return(7200);
      case PERIOD_M3:     return(4800);
      case PERIOD_M4:     return(3600);
      case PERIOD_M5:     return(2880);
      case PERIOD_M6:     return(2400);
      case PERIOD_M10:     return(1440);
      case PERIOD_M12:     return(1200);
      case PERIOD_M15:     return(960);
      case PERIOD_M20:     return(720);
      case PERIOD_M30:     return(480);
      case PERIOD_H1:     return(240);
      case PERIOD_H2:     return(120);
      case PERIOD_H3:     return(80);
      case PERIOD_H4:     return(60);
      case PERIOD_H6:     return(40);
      case PERIOD_H8:     return(30);
      case PERIOD_H12:     return(20);
      case PERIOD_D1:     return(10);
      case PERIOD_W1:     return(1);
      case PERIOD_MN1:     return(1);
     }
     return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                            Donchian Channels.mq5 |
//|                                                   Sergey Greecie |
//|                                               sergey1294@list.ru |
//+------------------------------------------------------------------+
#property copyright "Sergey Greecie"
#property link      "sergey1294@list.ru"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_color1  SteelBlue
#property indicator_color2  Magenta
#property indicator_color3  Blue
#property indicator_style3  STYLE_DOT

//---- input parameters
input int       Periods=24;
input int       Extremes=3;
input int       Margins=-2;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMiddBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ExtMapBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,ExtMiddBuffer,INDICATOR_DATA);

//--- set first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Periods);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,Periods);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,Periods);

//--- set drawing line empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
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
   int i,limit;
//--- check for rates
   if(rates_total<Periods)
      return(0);
//--- preliminary calculations
   if(prev_calculated==0)
      limit=Periods;
   else limit=prev_calculated-1;

   double smin=0,smax=0,SsMax=0,SsMin=0;

   for(i=limit;i<rates_total;i++)
     {
      if(Extremes==1)
        {
         SsMax = Highest(high,Periods,i);
         SsMin = Lowest(low,Periods,i);
        }
      else if(Extremes==3)
        {
         SsMax = (Highest(open,Periods,i)+Highest(high,Periods,i))/2;
         SsMin = (Lowest(open,Periods,i)+Lowest(low,Periods,i))/2;
        }
      else
        {
         SsMax = Highest(open,Periods,i);
         SsMin = Lowest(open,Periods,i);
        }
      smin = SsMin+(SsMax-SsMin)*Margins/100;
      smax = SsMax-(SsMax-SsMin)*Margins/100;
      ExtMapBuffer1[i]=smax;
      ExtMapBuffer2[i]=smin;
      ExtMiddBuffer[i]=(ExtMapBuffer1[i]+ExtMapBuffer2[i])/2.0;
     }

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

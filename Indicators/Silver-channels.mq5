//+------------------------------------------------------------------+
//|                                              Silver-channels.mq5 |
//|                                                   Sergey Greecie |
//|                                               sergey1294@list.ru |
//+------------------------------------------------------------------+
#property copyright "Sergey Greecie"
#property link      "sergey1294@list.ru"
#property version   "1.00"
#property indicator_chart_window

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   8

#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type8   DRAW_LINE

#property indicator_color1 Silver
#property indicator_color2 Silver
#property indicator_color3 SkyBlue
#property indicator_color4 SkyBlue
#property indicator_color5 YellowGreen
#property indicator_color6 YellowGreen
#property indicator_color7 Magenta
#property indicator_color8 Magenta

#property indicator_label1  "Silver-channel High"
#property indicator_label2  "Silver-channel Low"
#property indicator_label3  "Sky-channel High"
#property indicator_label4  "Sky-channel Low"
#property indicator_label5  "Zen-channel High"
#property indicator_label6  "Zen-channel Low"
#property indicator_label7  "Future-channel Low"
#property indicator_label8  "Future-channel High"
//---- input parameters
input int    SSP=26;
input double SilvCh=38.2;
input double SkyCh=23.6;
input double FutCh=61.8;
//---- buffers
double SCH_BufferH[];
double SCH_BufferL[];
double Sky_BufferH[];
double Sky_BufferL[];
double Zen_BufferH[];
double Zen_BufferL[];
double Fut_BufferL[];
double Fut_BufferH[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,SCH_BufferH,INDICATOR_DATA);
   SetIndexBuffer(1,SCH_BufferL,INDICATOR_DATA);
   SetIndexBuffer(2,Sky_BufferH,INDICATOR_DATA);
   SetIndexBuffer(3,Sky_BufferL,INDICATOR_DATA);
   SetIndexBuffer(4,Zen_BufferH,INDICATOR_DATA);
   SetIndexBuffer(5,Zen_BufferL,INDICATOR_DATA);
   SetIndexBuffer(6,Fut_BufferL,INDICATOR_DATA);
   SetIndexBuffer(7,Fut_BufferH,INDICATOR_DATA);
//--- set first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,SSP);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,SSP);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,SSP);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,SSP);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,SSP);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,SSP);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,SSP);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,SSP);

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
   double High,Low;
//--- check for rates
   if(rates_total<SSP)
      return(0);
//--- preliminary calculations
   if(prev_calculated==0)
      limit=SSP;
   else limit=prev_calculated-1;

   for(i=limit;i<rates_total;i++)
     {
      High=Highest(high,SSP,i);
      Low = Lowest(low,SSP,i);

      SCH_BufferL[i]=Low+(High-Low)*SilvCh/100;
      SCH_BufferH[i]=High-(High-Low)*SilvCh/100;
      Sky_BufferL[i]=Low+(High-Low)*SkyCh/100;
      Sky_BufferH[i]=High-(High-Low)*SkyCh/100;
      Zen_BufferL[i]=Low;
      Zen_BufferH[i]=High;
      Fut_BufferL[i]=Low-(High-Low)*FutCh/100;
      Fut_BufferH[i]=High+(High-Low)*FutCh/100;
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

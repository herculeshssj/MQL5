//+------------------------------------------------------------------+
//|                                                  SignalTrade.mq5 |
//|                                                   Sergey Greecie |
//|                                               sergey1294@list.ru |
//+------------------------------------------------------------------+
#property copyright "Sergey Greecie"
#property link      "sergey1294@list.ru"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- Connect necessary libraries of functions
#include <SignalTrade.mqh>
//--- Import functions from the LibFunctions library
#import "LibFunctions.ex5"
void SetLabel(string nm,string tx,ENUM_BASE_CORNER cn,ENUM_ANCHOR_POINT cr,int xd,int yd,string fn,int fs,double yg,color ct);
string arrow(int sig);
color Colorarrow(int sig);
#import
//+------------------------------------------------------------------+
//| Declare variables for storing the signals of indicators          |
//+------------------------------------------------------------------+
int SignalMA;
int SignalMACD;
int SignalPC;
int SignalACADX;
int SignalST;
int SignalRSI;
int SignalCCI;
int SignalWPR;
int SignalBB;
int SignalSDC;
int SignalPC2;
int SignalENV;
int SignalDC;
int SignalSC;
int SignalGC;
int SignalNRTR;
int SignalAL;
int SignalAMA;
int SignalAO;
int SignalICH;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Create indicator handles
   h_ma1=iMA(Symbol(),Period(),8,0,MODE_SMA,PRICE_CLOSE);
   h_ma2=iMA(Symbol(),Period(),16,0,MODE_SMA,PRICE_CLOSE);
   h_macd=iMACD(Symbol(),Period(),12,26,9,PRICE_CLOSE);
   h_pc=iCustom(Symbol(),Period(),"Price Channel",22);
   h_acadx=iCustom(Symbol(),Period(),"AdaptiveChannelADX",14);
   h_stoh=iStochastic(Symbol(),Period(),5,3,3,MODE_SMA,STO_LOWHIGH);
   h_rsi=iRSI(Symbol(),Period(),14,PRICE_CLOSE);
   h_cci=iCCI(Symbol(),Period(),14,PRICE_TYPICAL);
   h_wpr=iWPR(Symbol(),Period(),14);
   h_bb=iBands(Symbol(),Period(),20,0,2,PRICE_CLOSE);
   h_sdc=iCustom(Symbol(),Period(),"StandardDeviationChannel",14,MODE_SMA,PRICE_CLOSE,2.0);
   h_env=iEnvelopes(Symbol(),Period(),28,0,MODE_SMA,PRICE_CLOSE,0.1);
   h_dc=iCustom(Symbol(),Period(),"Donchian Channels",24,3,-2);
   h_sc=iCustom(Symbol(),Period(),"Silver-channels",26,38.2,23.6,61.8);
   h_gc=iCustom(Symbol(),Period(),"PriceChannelGalaher");
   h_nrtr=iCustom(Symbol(),Period(),"NRTR",40,2.0);
   h_al=iAlligator(Symbol(),Period(),13,0,8,0,5,0,MODE_SMMA,PRICE_MEDIAN);
   h_ama=iAMA(Symbol(),Period(),9,2,30,0,PRICE_CLOSE);
   h_ao=iAO(Symbol(),Period());
   h_ich=iIchimoku(Symbol(),Period(),9,26,52);
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete graphical objects created during working of the indicator
//--- as the indicator is deleted from the chart
   int total=ObjectsTotal(0,-1,OBJ_LABEL);
   for(int i=total-1; i>=0; i--)
     {
      ObjectDelete(0,"lebel"+(string)i);
      ObjectDelete(0,"arrow"+(string)i);
     }
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
//---Assign the value of signal to the variable
   SignalMA    = TradeSignal_01();
   SignalMACD  = TradeSignal_02();
   SignalPC    = TradeSignal_03();
   SignalACADX = TradeSignal_04();
   SignalST    = TradeSignal_05();
   SignalRSI   = TradeSignal_06();
   SignalCCI   = TradeSignal_07();
   SignalWPR   = TradeSignal_08();
   SignalBB    = TradeSignal_09();
   SignalSDC   = TradeSignal_10();
   SignalPC2   = TradeSignal_11();
   SignalENV   = TradeSignal_12();
   SignalDC    = TradeSignal_13();
   SignalSC    = TradeSignal_14();
   SignalGC    = TradeSignal_15();
   SignalNRTR  = TradeSignal_16();
   SignalAL    = TradeSignal_17();
   SignalAMA   = TradeSignal_18();
   SignalAO    = TradeSignal_19();
   SignalICH   = TradeSignal_20();

//--- draw graphical objects on the upper right corner of the chart
   int size=((int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)/22);
   int i=0;
   int x=10;
   int y=0;
   int fz=size-4;

   y+=size;
   SetLabel("arrow"+(string)i,arrow(SignalMA),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalMA));
   x+=size;
   SetLabel("lebel"+(string)i,"Moving Average",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);
   i++;y+=size;x=10;
   SetLabel("arrow"+(string)i,arrow(SignalMACD),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalMACD));
   x+=size;
   SetLabel("lebel"+(string)i,"MACD",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);
   i++;y+=size;x=10;
   SetLabel("arrow"+(string)i,arrow(SignalPC),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalPC));
   x+=size;
   SetLabel("lebel"+(string)i,"Price Channell",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);
   i++;y+=size;x=10;
   SetLabel("arrow"+(string)i,arrow(SignalACADX),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalACADX));
   x+=size;
   SetLabel("lebel"+(string)i,"Adaptive Channel ADX",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);
   i++;y+=size;x=10;
   SetLabel("arrow"+(string)i,arrow(SignalST),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalST));
   x+=size;
   SetLabel("lebel"+(string)i,"Stochastic Oscillator",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);
   i++;y+=size;x=10;
   SetLabel("arrow"+(string)i,arrow(SignalRSI),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalRSI));
   x+=size;
   SetLabel("lebel"+(string)i,"RSI",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);
   i++;y+=size;x=10;
   SetLabel("arrow"+(string)i,arrow(SignalCCI),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalCCI));
   x+=size;
   SetLabel("lebel"+(string)i,"CCI",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);
   i++;y+=size;x=10;
   SetLabel("arrow"+(string)i,arrow(SignalWPR),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalWPR));
   x+=size;
   SetLabel("lebel"+(string)i,"WPR",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);
   i++;y+=size;x=10;
   SetLabel("arrow"+(string)i,arrow(SignalBB),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalBB));
   x+=size;
   SetLabel("lebel"+(string)i,"Bollinger Bands",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);
   i++;y+=size;x=10;
   SetLabel("arrow"+(string)i,arrow(SignalSDC),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalSDC));
   x+=size;
   SetLabel("lebel"+(string)i,"StDevChannel",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);
   i++;y+=size;x=10;
   SetLabel("arrow"+(string)i,arrow(SignalPC2),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalPC2));
   x+=size;
   SetLabel("lebel"+(string)i,"Price Channell 2",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);
   i++;y+=size;x=10;
   SetLabel("arrow"+(string)i,arrow(SignalENV),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalENV));
   x+=size;
   SetLabel("lebel"+(string)i,"Envelopes",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);
   i++;y+=size;x=10;
   SetLabel("arrow"+(string)i,arrow(SignalDC),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalDC));
   x+=size;
   SetLabel("lebel"+(string)i,"Donchian Channels",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);
   i++;y+=size;x=10;
   SetLabel("arrow"+(string)i,arrow(SignalSC),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalSC));
   x+=size;
   SetLabel("lebel"+(string)i,"Silver-channels",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);
   i++;y+=size;x=10;
   SetLabel("arrow"+(string)i,arrow(SignalGC),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalGC));
   x+=size;
   SetLabel("lebel"+(string)i,"Galaher Channel",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);
   i++;y+=size;x=10;
   SetLabel("arrow"+(string)i,arrow(SignalNRTR),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalNRTR));
   x+=size;
   SetLabel("lebel"+(string)i,"NRTR",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);
   i++;y+=size;x=10;
   SetLabel("arrow"+(string)i,arrow(SignalAL),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalAL));
   x+=size;
   SetLabel("lebel"+(string)i,"Alligator",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);
   i++;y+=size;x=10;
   SetLabel("arrow"+(string)i,arrow(SignalAMA),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalAMA));
   x+=size;
   SetLabel("lebel"+(string)i,"AMA",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);
   i++;y+=size;x=10;
   SetLabel("arrow"+(string)i,arrow(SignalAO),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalAO));
   x+=size;
   SetLabel("lebel"+(string)i,"Awesome oscillator",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);
   i++;y+=size;x=10;
   SetLabel("arrow"+(string)i,arrow(SignalICH),CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y+4,"Wingdings",fz-2,0,Colorarrow(SignalICH));
   x+=size;
   SetLabel("lebel"+(string)i,"Ichimoku Kinko Hyo",CORNER_RIGHT_UPPER,ANCHOR_RIGHT_UPPER,x,y,"Arial",fz,0,BlueViolet);

   return(rates_total);
  }
//+------------------------------------------------------------------+

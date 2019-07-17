//+------------------------------------------------------------------+
//|                                               ExpSignalTrade.mq5 |
//|                                                   Sergey Greecie |
//|                                               sergey1294@list.ru |
//+------------------------------------------------------------------+
#property copyright "Sergey Greecie"
#property link      "sergey1294@list.ru"
#property version   "1.00"
//--- Connect necessary libraries of functions
#include <SignalTradeExp.mqh>
//--- Import functions from the LibFunctions library
#import "LibFunctions.ex5"
void SetLabel(string nm,string tx,ENUM_BASE_CORNER cn,ENUM_ANCHOR_POINT cr,int xd,int yd,string fn,int fs,double yg,color ct);
string arrow(int sig);
color Colorarrow(int sig);
#import
//--- inputs
input color TextColor=White;
input color BGColor=SteelBlue;
//+------------------------------------------------------------------+
//| Declare variables for storing the states of buttons              |
//+------------------------------------------------------------------+
int showMA=0;
int showMACD=0;
int showPC=0;
int showADX=0;
int showSO=0;
int showRSI=0;
int showCCI=0;
int showWPR=0;
int showBB=0;
int showSDC=0;
int showPC2=0;
int showENV=0;
int showDC=0;
int showSC=0;
int showNRTR=0;
int showAL=0;
int showAMA=0;
int showIKH=0;
int showdates=0;

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
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   PIPCreate();
   PIPSetParams();
//--- Create indicator handles
   h_ma1=iMA(Symbol(),Period(),periodma1,0,MAmethod,MAprice);
   h_ma2=iMA(Symbol(),Period(),periodma2,0,MAmethod,MAprice);
   h_macd=iMACD(Symbol(),Period(),FastMACD,SlowMACD,MACDSMA,MACDprice);
   h_pc=iCustom(Symbol(),Period(),"Price Channel",PCPeriod);
   h_acadx=iCustom(Symbol(),Period(),"AdaptiveChannelADX",ADXPeriod);
   h_stoh=iStochastic(Symbol(),Period(),SOPeriodK,SOPeriodD,SOslowing,SOmethod,SOpricefield);
   h_rsi=iRSI(Symbol(),Period(),RSIPeriod,RSIprice);
   h_cci=iCCI(Symbol(),Period(),CCIPeriod,CCIprice);
   h_wpr=iWPR(Symbol(),Period(),WPRPeriod);
   h_bb=iBands(Symbol(),Period(),BBPeriod,0,BBdeviation,BBprice);
   h_sdc=iCustom(Symbol(),Period(),"StandardDeviationChannel",SDCPeriod,SDCmethod,SDCprice,SDCdeviation);
   h_pc2=iCustom(Symbol(),Period(),"Price Channel",PC2Period);
   h_env=iEnvelopes(Symbol(),Period(),ENVPeriod,0,ENVmethod,ENVprice,ENVdeviation);
   h_dc=iCustom(Symbol(),Period(),"Donchian Channels",DCPeriod,DCExtremes,DCMargins);
   h_sc=iCustom(Symbol(),Period(),"Silver-channels",SCPeriod,SCSilvCh,SCSkyCh,SCFutCh);
   h_gc=iCustom(Symbol(),Period(),"PriceChannelGalaher");
   h_nrtr=iCustom(Symbol(),Period(),"NRTR",NRTRPeriod,NRTRK);
   h_al=iAlligator(Symbol(),Period(),ALjawperiod,0,ALteethperiod,0,ALlipsperiod,0,ALmethod,ALprice);
   h_ama=iAMA(Symbol(),Period(),AMAperiod,AMAfastperiod,AMAslowperiod,0,AMAprice);
   h_ao=iAO(Symbol(),Period());
   h_ich=iIchimoku(Symbol(),Period(),IKHtenkansen,IKHkijunsen,IKHsenkouspanb);
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Delete graphical objects created during working of the Expert Advisor
//--- as the EA is removed from the chart
   PIPDelete();

   int total=ObjectsTotal(0,-1,OBJ_LABEL);
   for(int i=total-1; i>=0; i--)
     {
      ObjectDelete(0,"lebel"+(string)i);
      ObjectDelete(0,"arrow"+(string)i);
     }
   ChartRedraw();

  }
//+------------------------------------------------------------------+
//| Process chart events                                             |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditMA1")
     {
      periodma1=(int)ObjectGetString(0,"PIPSetEditMA1",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditMA1",OBJPROP_TEXT,(string)periodma1);
      IndicatorRelease(h_ma1);
      h_ma1=iMA(Symbol(),Period(),periodma1,0,MAmethod,MAprice);
      ChartRedraw();
     }

   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditMA2")
     {
      periodma2=(int)ObjectGetString(0,"PIPSetEditMA2",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditMA2",OBJPROP_TEXT,(string)periodma2);
      //--- unload the old copy of the indicator
      IndicatorRelease(h_ma2);
      //--- create a new copy of the indicator
      h_ma2=iMA(Symbol(),Period(),periodma2,0,MAmethod,MAprice);
      ChartRedraw();
     }

   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditMAmethod")
     {
      MAmethod=(ENUM_MA_METHOD)ObjectGetString(0,"PIPSetEditMAmethod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditMAmethod",OBJPROP_TEXT,(string)MAmethod);
      IndicatorRelease(h_ma1);
      h_ma1=iMA(Symbol(),Period(),periodma1,0,MAmethod,MAprice);
      IndicatorRelease(h_ma2);
      h_ma2=iMA(Symbol(),Period(),periodma2,0,MAmethod,MAprice);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditMAprice")
     {
      MAprice=(ENUM_APPLIED_PRICE)ObjectGetString(0,"PIPSetEditMAprice",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditMAprice",OBJPROP_TEXT,(string)MAprice);
      IndicatorRelease(h_ma1);
      h_ma1=iMA(Symbol(),Period(),periodma1,0,MAmethod,MAprice);
      IndicatorRelease(h_ma2);
      h_ma2=iMA(Symbol(),Period(),periodma2,0,MAmethod,MAprice);
      ChartRedraw();
     }

   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditFastMACD")
     {
      FastMACD=(int)ObjectGetString(0,"PIPSetEditFastMACD",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditFastMACD",OBJPROP_TEXT,(string)FastMACD);
      IndicatorRelease(h_macd);
      h_macd=iMACD(Symbol(),Period(),FastMACD,SlowMACD,MACDSMA,MACDprice);
      ChartRedraw();
     }

   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditSlowMACD")
     {
      SlowMACD=(int)ObjectGetString(0,"PIPSetEditSlowMACD",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditSlowMACD",OBJPROP_TEXT,(string)SlowMACD);
      IndicatorRelease(h_macd);
      h_macd=iMACD(Symbol(),Period(),FastMACD,SlowMACD,MACDSMA,MACDprice);
      ChartRedraw();
     }

   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditMACDSMA")
     {
      MACDSMA=(int)ObjectGetString(0,"PIPSetEditMACDSMA",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditMACDSMA",OBJPROP_TEXT,(string)MACDSMA);
      IndicatorRelease(h_macd);
      h_macd=iMACD(Symbol(),Period(),FastMACD,SlowMACD,MACDSMA,MACDprice);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditMACDprice")
     {
      MACDprice=(ENUM_APPLIED_PRICE)ObjectGetString(0,"PIPSetEditMACDprice",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditMACDprice",OBJPROP_TEXT,(string)MACDprice);
      IndicatorRelease(h_macd);
      h_macd=iMACD(Symbol(),Period(),FastMACD,SlowMACD,MACDSMA,MACDprice);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditPCPeriod")
     {
      PCPeriod=(int)ObjectGetString(0,"PIPSetEditPCPeriod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditPCPeriod",OBJPROP_TEXT,(string)PCPeriod);
      IndicatorRelease(h_pc);
      h_pc=iCustom(Symbol(),Period(),"Price Channel",PCPeriod);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditADXPeriod")
     {
      ADXPeriod=(int)ObjectGetString(0,"PIPSetEditADXPeriod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditADXPeriod",OBJPROP_TEXT,(string)ADXPeriod);
      IndicatorRelease(h_acadx);
      h_acadx=iCustom(Symbol(),Period(),"AdaptiveChannelADX",ADXPeriod);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditSOPeriodK")
     {
      SOPeriodK=(int)ObjectGetString(0,"PIPSetEditSOPeriodK",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditSOPeriodK",OBJPROP_TEXT,(string)SOPeriodK);
      IndicatorRelease(h_stoh);
      h_stoh=iStochastic(Symbol(),Period(),SOPeriodK,SOPeriodD,SOslowing,SOmethod,SOpricefield);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditSOPeriodD")
     {
      SOPeriodD=(int)ObjectGetString(0,"PIPSetEditSOPeriodD",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditSOPeriodD",OBJPROP_TEXT,(string)SOPeriodD);
      IndicatorRelease(h_stoh);
      h_stoh=iStochastic(Symbol(),Period(),SOPeriodK,SOPeriodD,SOslowing,SOmethod,SOpricefield);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditSOslowing")
     {
      SOslowing=(int)ObjectGetString(0,"PIPSetEditSOslowing",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditSOslowing",OBJPROP_TEXT,(string)SOslowing);
      IndicatorRelease(h_stoh);
      h_stoh=iStochastic(Symbol(),Period(),SOPeriodK,SOPeriodD,SOslowing,SOmethod,SOpricefield);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditSOmethod")
     {
      SOmethod=(ENUM_MA_METHOD)ObjectGetString(0,"PIPSetEditSOmethod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditSOmethod",OBJPROP_TEXT,(string)SOmethod);
      IndicatorRelease(h_stoh);
      h_stoh=iStochastic(Symbol(),Period(),SOPeriodK,SOPeriodD,SOslowing,SOmethod,SOpricefield);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditSOpricefield")
     {
      SOpricefield=(ENUM_STO_PRICE)ObjectGetString(0,"PIPSetEditSOpricefield",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditSOpricefield",OBJPROP_TEXT,(string)SOpricefield);
      IndicatorRelease(h_stoh);
      h_stoh=iStochastic(Symbol(),Period(),SOPeriodK,SOPeriodD,SOslowing,SOmethod,SOpricefield);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditRSIPeriod")
     {
      RSIPeriod=(int)ObjectGetString(0,"PIPSetEditRSIPeriod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditRSIPeriod",OBJPROP_TEXT,(string)RSIPeriod);
      IndicatorRelease(h_rsi);
      h_rsi=iRSI(Symbol(),Period(),RSIPeriod,RSIprice);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditRSIprice")
     {
      RSIprice=(ENUM_APPLIED_PRICE)ObjectGetString(0,"PIPSetEditRSIprice",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditRSIprice",OBJPROP_TEXT,(string)RSIprice);
      IndicatorRelease(h_rsi);
      h_rsi=iRSI(Symbol(),Period(),RSIPeriod,RSIprice);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditCCIPeriod")
     {
      CCIPeriod=(int)ObjectGetString(0,"PIPSetEditCCIPeriod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditCCIPeriod",OBJPROP_TEXT,(string)CCIPeriod);
      IndicatorRelease(h_cci);
      h_cci=iCCI(Symbol(),Period(),CCIPeriod,CCIprice);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditCCIprice")
     {
      CCIprice=(ENUM_APPLIED_PRICE)ObjectGetString(0,"PIPSetEditCCIprice",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditCCIprice",OBJPROP_TEXT,(string)CCIprice);
      IndicatorRelease(h_cci);
      h_cci=iCCI(Symbol(),Period(),CCIPeriod,CCIprice);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditWPRPeriod")
     {
      WPRPeriod=(int)ObjectGetString(0,"PIPSetEditWPRPeriod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditWPRPeriod",OBJPROP_TEXT,(string)WPRPeriod);
      IndicatorRelease(h_wpr);
      h_wpr=iWPR(Symbol(),Period(),WPRPeriod);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditBBPeriod")
     {
      BBPeriod=(int)ObjectGetString(0,"PIPSetEditBBPeriod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditBBPeriod",OBJPROP_TEXT,(string)BBPeriod);
      IndicatorRelease(h_bb);
      h_bb=iBands(Symbol(),Period(),BBPeriod,0,BBdeviation,BBprice);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditBBdeviation")
     {
      BBdeviation=(double)ObjectGetString(0,"PIPSetEditBBdeviation",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditBBdeviation",OBJPROP_TEXT,DoubleToString(BBdeviation));

      IndicatorRelease(h_bb);
      h_bb=iBands(Symbol(),Period(),BBPeriod,0,BBdeviation,BBprice);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditBBprice")
     {
      BBprice=(ENUM_APPLIED_PRICE)ObjectGetString(0,"PIPSetEditBBprice",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditBBprice",OBJPROP_TEXT,(string)BBprice);
      IndicatorRelease(h_bb);
      h_bb=iBands(Symbol(),Period(),BBPeriod,0,BBdeviation,BBprice);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditSDCPeriod")
     {
      SDCPeriod=(int)ObjectGetString(0,"PIPSetEditSDCPeriod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditSDCPeriod",OBJPROP_TEXT,(string)SDCPeriod);
      IndicatorRelease(h_sdc);
      h_sdc=iCustom(Symbol(),Period(),"StandardDeviationChannel",SDCPeriod,SDCmethod,SDCprice,SDCdeviation);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditSDCdeviation")
     {
      SDCdeviation=(double)ObjectGetString(0,"PIPSetEditSDCdeviation",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditSDCdeviation",OBJPROP_TEXT,DoubleToString(SDCdeviation));
      IndicatorRelease(h_sdc);
      h_sdc=iCustom(Symbol(),Period(),"StandardDeviationChannel",SDCPeriod,SDCmethod,SDCprice,SDCdeviation);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditSDCprice")
     {
      SDCprice=(ENUM_APPLIED_PRICE)ObjectGetString(0,"PIPSetEditSDCprice",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditSDCprice",OBJPROP_TEXT,(string)SDCprice);
      IndicatorRelease(h_sdc);
      h_sdc=iCustom(Symbol(),Period(),"StandardDeviationChannel",SDCPeriod,SDCmethod,SDCprice,SDCdeviation);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditSDCmethod")
     {
      SDCmethod=(ENUM_MA_METHOD)ObjectGetString(0,"PIPSetEditSDCmethod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditSDCmethod",OBJPROP_TEXT,(string)SDCmethod);
      IndicatorRelease(h_sdc);
      h_sdc=iCustom(Symbol(),Period(),"StandardDeviationChannel",SDCPeriod,SDCmethod,SDCprice,SDCdeviation);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditPC2Period")
     {
      PC2Period=(int)ObjectGetString(0,"PIPSetEditPC2Period",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditPC2Period",OBJPROP_TEXT,(string)PC2Period);
      IndicatorRelease(h_pc2);
      h_pc2=iCustom(Symbol(),Period(),"Price Channel",PC2Period);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditENVPeriod")
     {
      ENVPeriod=(int)ObjectGetString(0,"PIPSetEditENVPeriod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditENVPeriod",OBJPROP_TEXT,(string)ENVPeriod);
      IndicatorRelease(h_env);
      h_env=iEnvelopes(Symbol(),Period(),ENVPeriod,0,ENVmethod,ENVprice,ENVdeviation);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditENVdeviation")
     {
      ENVdeviation=(double)ObjectGetString(0,"PIPSetEditENVdeviation",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditENVdeviation",OBJPROP_TEXT,DoubleToString(ENVdeviation));
      IndicatorRelease(h_env);
      h_env=iEnvelopes(Symbol(),Period(),ENVPeriod,0,ENVmethod,ENVprice,ENVdeviation);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditENVprice")
     {
      ENVprice=(ENUM_APPLIED_PRICE)ObjectGetString(0,"PIPSetEditENVprice",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditENVprice",OBJPROP_TEXT,(string)ENVprice);
      IndicatorRelease(h_env);
      h_env=iEnvelopes(Symbol(),Period(),ENVPeriod,0,ENVmethod,ENVprice,ENVdeviation);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditENVmethod")
     {
      ENVmethod=(ENUM_MA_METHOD)ObjectGetString(0,"PIPSetEditENVmethod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditENVmethod",OBJPROP_TEXT,(string)ENVmethod);
      IndicatorRelease(h_env);
      h_env=iEnvelopes(Symbol(),Period(),ENVPeriod,0,ENVmethod,ENVprice,ENVdeviation);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditDCPeriod")
     {
      DCPeriod=(int)ObjectGetString(0,"PIPSetEditDCPeriod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditDCPeriod",OBJPROP_TEXT,(string)DCPeriod);
      IndicatorRelease(h_dc);
      h_dc=iCustom(Symbol(),Period(),"Donchian Channels",DCPeriod,DCExtremes,DCMargins);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditDCExtremes")
     {
      DCExtremes=(int)ObjectGetString(0,"PIPSetEditDCExtremes",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditDCExtremes",OBJPROP_TEXT,(string)DCExtremes);
      IndicatorRelease(h_dc);
      h_dc=iCustom(Symbol(),Period(),"Donchian Channels",DCPeriod,DCExtremes,DCMargins);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditDCMargins")
     {
      DCMargins=(int)ObjectGetString(0,"PIPSetEditDCMargins",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditDCMargins",OBJPROP_TEXT,(string)DCMargins);
      IndicatorRelease(h_dc);
      h_dc=iCustom(Symbol(),Period(),"Donchian Channels",DCPeriod,DCExtremes,DCMargins);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditSCPeriod")
     {
      SCPeriod=(int)ObjectGetString(0,"PIPSetEditSCPeriod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditSCPeriod",OBJPROP_TEXT,(string)SCPeriod);
      IndicatorRelease(h_sc);
      h_sc=iCustom(Symbol(),Period(),"Silver-channels",SCPeriod,SCSilvCh,SCSkyCh,SCFutCh);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditSCSilvCh")
     {
      SCSilvCh=(double)ObjectGetString(0,"PIPSetEditSCSilvCh",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditSCSilvCh",OBJPROP_TEXT,DoubleToString(SCSilvCh));
      IndicatorRelease(h_sc);
      h_sc=iCustom(Symbol(),Period(),"Silver-channels",SCPeriod,SCSilvCh,SCSkyCh,SCFutCh);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditSCSkyCh")
     {
      SCSkyCh=(double)ObjectGetString(0,"PIPSetEditSCSkyCh",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditSCSkyCh",OBJPROP_TEXT,DoubleToString(SCSkyCh));
      IndicatorRelease(h_sc);
      h_sc=iCustom(Symbol(),Period(),"Silver-channels",SCPeriod,SCSilvCh,SCSkyCh,SCFutCh);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditSCFutCh")
     {
      SCFutCh=(double)ObjectGetString(0,"PIPSetEditSCFutCh",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditSCFutCh",OBJPROP_TEXT,DoubleToString(SCFutCh));
      IndicatorRelease(h_sc);
      h_sc=iCustom(Symbol(),Period(),"Silver-channels",SCPeriod,SCSilvCh,SCSkyCh,SCFutCh);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditNRTRPeriod")
     {
      NRTRPeriod=(int)ObjectGetString(0,"PIPSetEditNRTRPeriod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditNRTRPeriod",OBJPROP_TEXT,(string)NRTRPeriod);
      IndicatorRelease(h_nrtr);
      h_nrtr=iCustom(Symbol(),Period(),"NRTR",NRTRPeriod,NRTRK);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditNRTRK")
     {
      NRTRK=(double)ObjectGetString(0,"PIPSetEditNRTRK",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditNRTRK",OBJPROP_TEXT,DoubleToString(NRTRK));
      IndicatorRelease(h_nrtr);
      h_nrtr=iCustom(Symbol(),Period(),"NRTR",NRTRPeriod,NRTRK);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditALjawperiod")
     {
      ALjawperiod=(int)ObjectGetString(0,"PIPSetEditALjawperiod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditALjawperiod",OBJPROP_TEXT,(string)ALjawperiod);
      IndicatorRelease(h_al);
      h_al=iAlligator(Symbol(),Period(),ALjawperiod,0,ALteethperiod,0,ALlipsperiod,0,ALmethod,ALprice);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditALteethperiod")
     {
      ALteethperiod=(int)ObjectGetString(0,"PIPSetEditALteethperiod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditALteethperiod",OBJPROP_TEXT,(string)ALteethperiod);
      IndicatorRelease(h_al);
      h_al=iAlligator(Symbol(),Period(),ALjawperiod,0,ALteethperiod,0,ALlipsperiod,0,ALmethod,ALprice);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditALlipsperiod")
     {
      ALlipsperiod=(int)ObjectGetString(0,"PIPSetEditALlipsperiod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditALlipsperiod",OBJPROP_TEXT,(string)ALlipsperiod);
      IndicatorRelease(h_al);
      h_al=iAlligator(Symbol(),Period(),ALjawperiod,0,ALteethperiod,0,ALlipsperiod,0,ALmethod,ALprice);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditALmethod")
     {
      ALmethod=(ENUM_MA_METHOD)ObjectGetString(0,"PIPSetEditALmethod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditALmethod",OBJPROP_TEXT,(string)ALmethod);
      IndicatorRelease(h_al);
      h_al=iAlligator(Symbol(),Period(),ALjawperiod,0,ALteethperiod,0,ALlipsperiod,0,ALmethod,ALprice);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditALprice")
     {
      ALprice=(ENUM_APPLIED_PRICE)ObjectGetString(0,"PIPSetEditALprice",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditALprice",OBJPROP_TEXT,(string)ALprice);
      IndicatorRelease(h_al);
      h_al=iAlligator(Symbol(),Period(),ALjawperiod,0,ALteethperiod,0,ALlipsperiod,0,ALmethod,ALprice);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditAMAperiod")
     {
      AMAperiod=(int)ObjectGetString(0,"PIPSetEditAMAperiod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditAMAperiod",OBJPROP_TEXT,(string)AMAperiod);
      IndicatorRelease(h_ama);
      h_ama=iAMA(Symbol(),Period(),AMAperiod,AMAfastperiod,AMAslowperiod,0,AMAprice);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditAMAfastperiod")
     {
      AMAfastperiod=(int)ObjectGetString(0,"PIPSetEditAMAfastperiod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditAMAfastperiod",OBJPROP_TEXT,(string)AMAfastperiod);
      IndicatorRelease(h_ama);
      h_ama=iAMA(Symbol(),Period(),AMAperiod,AMAfastperiod,AMAslowperiod,0,AMAprice);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditAMAslowperiod")
     {
      AMAslowperiod=(int)ObjectGetString(0,"PIPSetEditAMAslowperiod",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditAMAslowperiod",OBJPROP_TEXT,(string)AMAslowperiod);
      IndicatorRelease(h_ama);
      h_ama=iAMA(Symbol(),Period(),AMAperiod,AMAfastperiod,AMAslowperiod,0,AMAprice);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditAMAprice")
     {
      AMAprice=(ENUM_APPLIED_PRICE)ObjectGetString(0,"PIPSetEditAMAprice",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditAMAprice",OBJPROP_TEXT,(string)AMAprice);
      IndicatorRelease(h_ama);
      h_ama=iAMA(Symbol(),Period(),AMAperiod,AMAfastperiod,AMAslowperiod,0,AMAprice);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditIKHtenkansen")
     {
      IKHtenkansen=(int)ObjectGetString(0,"PIPSetEditIKHtenkansen",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditIKHtenkansen",OBJPROP_TEXT,(string)IKHtenkansen);
      IndicatorRelease(h_ich);
      h_ich=iIchimoku(Symbol(),Period(),IKHtenkansen,IKHkijunsen,IKHsenkouspanb);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditIKHkijunsen")
     {
      IKHkijunsen=(int)ObjectGetString(0,"PIPSetEditIKHkijunsen",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditIKHkijunsen",OBJPROP_TEXT,(string)IKHkijunsen);
      IndicatorRelease(h_ich);
      h_ich=iIchimoku(Symbol(),Period(),IKHtenkansen,IKHkijunsen,IKHsenkouspanb);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_ENDEDIT && sparam=="PIPSetEditIKHsenkouspanb")
     {
      IKHsenkouspanb=(int)ObjectGetString(0,"PIPSetEditIKHsenkouspanb",OBJPROP_TEXT);
      ObjectSetString(0,"PIPSetEditIKHsenkouspanb",OBJPROP_TEXT,(string)IKHsenkouspanb);
      IndicatorRelease(h_ich);
      h_ich=iIchimoku(Symbol(),Period(),IKHtenkansen,IKHkijunsen,IKHsenkouspanb);
      ChartRedraw();
     }

//-----------------------------------------------------------------------------
   if(id==CHARTEVENT_OBJECT_CLICK && sparam=="PIPIndNaneButton")
     {
      showdates=(int)ObjectGetInteger(0,"PIPIndNaneButton",OBJPROP_STATE);
      ChartRedraw();
     }
//-----------------------------------------------------------------------------
   if(showdates)
     {
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="PIPIndNaneButtonMA")
        {
         showMA=(int)ObjectGetInteger(0,"PIPIndNaneButtonMA",OBJPROP_STATE);
         showMACD=false;
         showPC=false;
         showADX=false;
         showSO=false;
         showRSI=false;
         showCCI=false;
         showWPR=false;
         showBB=false;
         showSDC=false;
         showPC2=false;
         showENV=false;
         showDC=false;
         showSC=false;
         showNRTR=false;
         showAL=false;
         showAMA=false;
         showIKH=false;
        }
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="PIPIndNaneButtonMACD")
        {
         showMACD=(int)ObjectGetInteger(0,"PIPIndNaneButtonMACD",OBJPROP_STATE);
         showMA=false;
         showPC=false;
         showADX=false;
         showSO=false;
         showRSI=false;
         showCCI=false;
         showWPR=false;
         showBB=false;
         showSDC=false;
         showPC2=false;
         showENV=false;
         showDC=false;
         showSC=false;
         showNRTR=false;
         showAL=false;
         showAMA=false;
         showIKH=false;
        }
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="PIPIndNameButtonPC")
        {
         showPC=(int)ObjectGetInteger(0,"PIPIndNameButtonPC",OBJPROP_STATE);
         showMA=false;
         showMACD=false;
         showADX=false;
         showSO=false;
         showRSI=false;
         showCCI=false;
         showWPR=false;
         showBB=false;
         showSDC=false;
         showPC2=false;
         showENV=false;
         showDC=false;
         showSC=false;
         showNRTR=false;
         showAL=false;
         showAMA=false;
         showIKH=false;
        }
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="PIPIndNameButtonACADX")
        {
         showADX=(int)ObjectGetInteger(0,"PIPIndNameButtonACADX",OBJPROP_STATE);
         showMA=false;
         showMACD=false;
         showPC=false;
         showSO=false;
         showRSI=false;
         showCCI=false;
         showWPR=false;
         showBB=false;
         showSDC=false;
         showPC2=false;
         showENV=false;
         showDC=false;
         showSC=false;
         showNRTR=false;
         showAL=false;
         showAMA=false;
         showIKH=false;
        }
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="PIPIndNameButtonSO")
        {
         showSO=(int)ObjectGetInteger(0,"PIPIndNameButtonSO",OBJPROP_STATE);
         showMA=false;
         showMACD=false;
         showPC=false;
         showADX=false;
         showRSI=false;
         showCCI=false;
         showWPR=false;
         showBB=false;
         showSDC=false;
         showPC2=false;
         showENV=false;
         showDC=false;
         showSC=false;
         showNRTR=false;
         showAL=false;
         showAMA=false;
         showIKH=false;
        }
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="PIPIndNameButtonRSI")
        {
         showRSI=(int)ObjectGetInteger(0,"PIPIndNameButtonRSI",OBJPROP_STATE);
         showMA=false;
         showMACD=false;
         showPC=false;
         showADX=false;
         showSO=false;
         showCCI=false;
         showWPR=false;
         showBB=false;
         showSDC=false;
         showPC2=false;
         showENV=false;
         showDC=false;
         showSC=false;
         showNRTR=false;
         showAL=false;
         showAMA=false;
         showIKH=false;
        }
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="PIPIndNameButtonCCI")
        {
         showCCI=(int)ObjectGetInteger(0,"PIPIndNameButtonCCI",OBJPROP_STATE);
         showMA=false;
         showMACD=false;
         showPC=false;
         showADX=false;
         showSO=false;
         showRSI=false;
         showWPR=false;
         showBB=false;
         showSDC=false;
         showPC2=false;
         showENV=false;
         showDC=false;
         showSC=false;
         showNRTR=false;
         showAL=false;
         showAMA=false;
         showIKH=false;
        }
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="PIPIndNameButtonWPR")
        {
         showWPR=(int)ObjectGetInteger(0,"PIPIndNameButtonWPR",OBJPROP_STATE);
         showMA=false;
         showMACD=false;
         showPC=false;
         showADX=false;
         showSO=false;
         showRSI=false;
         showCCI=false;
         showBB=false;
         showSDC=false;
         showPC2=false;
         showENV=false;
         showDC=false;
         showSC=false;
         showNRTR=false;
         showAL=false;
         showAMA=false;
         showIKH=false;
        }
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="PIPIndNameButtonBB")
        {
         showBB=(int)ObjectGetInteger(0,"PIPIndNameButtonBB",OBJPROP_STATE);
         showMA=false;
         showMACD=false;
         showPC=false;
         showADX=false;
         showSO=false;
         showRSI=false;
         showCCI=false;
         showWPR=false;
         showSDC=false;
         showPC2=false;
         showENV=false;
         showDC=false;
         showSC=false;
         showNRTR=false;
         showAL=false;
         showAMA=false;
         showIKH=false;
        }
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="PIPIndNameButtonSDC")
        {
         showSDC=(int)ObjectGetInteger(0,"PIPIndNameButtonSDC",OBJPROP_STATE);
         showMA=false;
         showMACD=false;
         showPC=false;
         showADX=false;
         showSO=false;
         showRSI=false;
         showCCI=false;
         showWPR=false;
         showBB=false;
         showPC2=false;
         showENV=false;
         showDC=false;
         showSC=false;
         showNRTR=false;
         showAL=false;
         showAMA=false;
         showIKH=false;
        }
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="PIPIndNameButtonPC2")
        {
         showPC2=(int)ObjectGetInteger(0,"PIPIndNameButtonPC2",OBJPROP_STATE);
         showMA=false;
         showMACD=false;
         showPC=false;
         showADX=false;
         showSO=false;
         showRSI=false;
         showCCI=false;
         showWPR=false;
         showBB=false;
         showSDC=false;
         showENV=false;
         showDC=false;
         showSC=false;
         showNRTR=false;
         showAL=false;
         showAMA=false;
         showIKH=false;
        }
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="PIPIndNameButtonENV")
        {
         showENV=(int)ObjectGetInteger(0,"PIPIndNameButtonENV",OBJPROP_STATE);
         showMA=false;
         showMACD=false;
         showPC=false;
         showADX=false;
         showSO=false;
         showRSI=false;
         showCCI=false;
         showWPR=false;
         showBB=false;
         showSDC=false;
         showPC2=false;
         showDC=false;
         showSC=false;
         showNRTR=false;
         showAL=false;
         showAMA=false;
         showIKH=false;
        }
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="PIPIndNameButtonDC")
        {
         showDC=(int)ObjectGetInteger(0,"PIPIndNameButtonDC",OBJPROP_STATE);
         showMA=false;
         showMACD=false;
         showPC=false;
         showADX=false;
         showSO=false;
         showRSI=false;
         showCCI=false;
         showWPR=false;
         showBB=false;
         showSDC=false;
         showPC2=false;
         showENV=false;
         showSC=false;
         showNRTR=false;
         showAL=false;
         showAMA=false;
         showIKH=false;
        }
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="PIPIndNameButtonSC")
        {
         showSC=(int)ObjectGetInteger(0,"PIPIndNameButtonSC",OBJPROP_STATE);
         showMA=false;
         showMACD=false;
         showPC=false;
         showADX=false;
         showSO=false;
         showRSI=false;
         showCCI=false;
         showWPR=false;
         showBB=false;
         showSDC=false;
         showPC2=false;
         showENV=false;
         showDC=false;
         showNRTR=false;
         showAL=false;
         showAMA=false;
         showIKH=false;
        }
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="PIPIndNameButtonNRTR")
        {
         showNRTR=(int)ObjectGetInteger(0,"PIPIndNameButtonNRTR",OBJPROP_STATE);
         showMA=false;
         showMACD=false;
         showPC=false;
         showADX=false;
         showSO=false;
         showRSI=false;
         showCCI=false;
         showWPR=false;
         showBB=false;
         showSDC=false;
         showPC2=false;
         showENV=false;
         showDC=false;
         showSC=false;
         showAL=false;
         showAMA=false;
         showIKH=false;
        }
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="PIPIndNameButtonAL")
        {
         showAL=(int)ObjectGetInteger(0,"PIPIndNameButtonAL",OBJPROP_STATE);
         showMA=false;
         showMACD=false;
         showPC=false;
         showADX=false;
         showSO=false;
         showRSI=false;
         showCCI=false;
         showWPR=false;
         showBB=false;
         showSDC=false;
         showPC2=false;
         showENV=false;
         showDC=false;
         showSC=false;
         showNRTR=false;
         showAMA=false;
         showIKH=false;
        }
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="PIPIndNameButtonAMA")
        {
         showAMA=(int)ObjectGetInteger(0,"PIPIndNameButtonAMA",OBJPROP_STATE);
         showMA=false;
         showMACD=false;
         showPC=false;
         showADX=false;
         showSO=false;
         showRSI=false;
         showCCI=false;
         showWPR=false;
         showBB=false;
         showSDC=false;
         showPC2=false;
         showENV=false;
         showDC=false;
         showSC=false;
         showNRTR=false;
         showAL=false;
         showIKH=false;
        }
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="PIPIndNameButtonIKH")
        {
         showIKH=(int)ObjectGetInteger(0,"PIPIndNameButtonIKH",OBJPROP_STATE);
         showMA=false;
         showMACD=false;
         showPC=false;
         showADX=false;
         showSO=false;
         showRSI=false;
         showCCI=false;
         showWPR=false;
         showBB=false;
         showSDC=false;
         showPC2=false;
         showENV=false;
         showDC=false;
         showSC=false;
         showNRTR=false;
         showAL=false;
         showAMA=false;
        }
      //---------------------------------------------------------------------------
      if(showMA)
        {
         PIPSetEditMA();
         PIPDeleteParamsMACD();
         PIPDeleteParamsPC();
         PIPDeleteParamsADX();
         PIPDeleteParamsSO();
         PIPDeleteParamsRSI();
         PIPDeleteParamsCCI();
         PIPDeleteParamsWPR();
         PIPDeleteParamsBB();
         PIPDeleteParamsSDC();
         PIPDeleteParamsPC2();
         PIPDeleteParamsENV();
         PIPDeleteParamsDC();
         PIPDeleteParamsSC();
         PIPDeleteParamsNRTR();
         PIPDeleteParamsAL();
         PIPDeleteParamsAMA();
         PIPDeleteParamsIKH();
        }
      else
        {
         PIPDeleteParamsMA();
         showMA=false;
        }
      if(showMACD)
        {
         PIPSetEditMACD();
         PIPDeleteParamsMA();
         PIPDeleteParamsPC();
         PIPDeleteParamsADX();
         PIPDeleteParamsSO();
         PIPDeleteParamsRSI();
         PIPDeleteParamsCCI();
         PIPDeleteParamsWPR();
         PIPDeleteParamsBB();
         PIPDeleteParamsSDC();
         PIPDeleteParamsPC2();
         PIPDeleteParamsENV();
         PIPDeleteParamsDC();
         PIPDeleteParamsSC();
         PIPDeleteParamsNRTR();
         PIPDeleteParamsAL();
         PIPDeleteParamsAMA();
         PIPDeleteParamsIKH();
        }
      else
        {
         PIPDeleteParamsMACD();
         showMACD=false;
        }
      if(showPC)
        {
         PIPSetEditPC();
         PIPDeleteParamsMA();
         PIPDeleteParamsMACD();
         PIPDeleteParamsADX();
         PIPDeleteParamsSO();
         PIPDeleteParamsRSI();
         PIPDeleteParamsCCI();
         PIPDeleteParamsWPR();
         PIPDeleteParamsBB();
         PIPDeleteParamsSDC();
         PIPDeleteParamsPC2();
         PIPDeleteParamsENV();
         PIPDeleteParamsDC();
         PIPDeleteParamsSC();
         PIPDeleteParamsNRTR();
         PIPDeleteParamsAL();
         PIPDeleteParamsAMA();
         PIPDeleteParamsIKH();
        }
      else
        {
         PIPDeleteParamsPC();
         showPC=false;
        }
      if(showADX)
        {
         PIPSetEditADX();
         PIPDeleteParamsMA();
         PIPDeleteParamsMACD();
         PIPDeleteParamsPC();
         PIPDeleteParamsSO();
         PIPDeleteParamsRSI();
         PIPDeleteParamsCCI();
         PIPDeleteParamsWPR();
         PIPDeleteParamsBB();
         PIPDeleteParamsSDC();
         PIPDeleteParamsPC2();
         PIPDeleteParamsENV();
         PIPDeleteParamsDC();
         PIPDeleteParamsSC();
         PIPDeleteParamsNRTR();
         PIPDeleteParamsAL();
         PIPDeleteParamsAMA();
         PIPDeleteParamsIKH();
        }
      else
        {
         PIPDeleteParamsADX();
         showADX=false;
        }
      if(showSO)
        {
         PIPSetEditSO();
         PIPDeleteParamsMA();
         PIPDeleteParamsMACD();
         PIPDeleteParamsPC();
         PIPDeleteParamsADX();
         PIPDeleteParamsRSI();
         PIPDeleteParamsCCI();
         PIPDeleteParamsWPR();
         PIPDeleteParamsBB();
         PIPDeleteParamsSDC();
         PIPDeleteParamsPC2();
         PIPDeleteParamsENV();
         PIPDeleteParamsDC();
         PIPDeleteParamsSC();
         PIPDeleteParamsNRTR();
         PIPDeleteParamsAL();
         PIPDeleteParamsAMA();
         PIPDeleteParamsIKH();
        }
      else
        {
         PIPDeleteParamsSO();
         showSO=false;
        }
      if(showRSI)
        {
         PIPSetEditRSI();
         PIPDeleteParamsMA();
         PIPDeleteParamsMACD();
         PIPDeleteParamsPC();
         PIPDeleteParamsADX();
         PIPDeleteParamsSO();
         PIPDeleteParamsCCI();
         PIPDeleteParamsWPR();
         PIPDeleteParamsBB();
         PIPDeleteParamsSDC();
         PIPDeleteParamsPC2();
         PIPDeleteParamsENV();
         PIPDeleteParamsDC();
         PIPDeleteParamsSC();
         PIPDeleteParamsNRTR();
         PIPDeleteParamsAL();
         PIPDeleteParamsAMA();
         PIPDeleteParamsIKH();
        }
      else
        {
         PIPDeleteParamsRSI();
         showRSI=false;
        }
      if(showCCI)
        {
         PIPSetEditCCI();
         PIPDeleteParamsMA();
         PIPDeleteParamsMACD();
         PIPDeleteParamsPC();
         PIPDeleteParamsADX();
         PIPDeleteParamsSO();
         PIPDeleteParamsRSI();
         PIPDeleteParamsWPR();
         PIPDeleteParamsBB();
         PIPDeleteParamsSDC();
         PIPDeleteParamsPC2();
         PIPDeleteParamsENV();
         PIPDeleteParamsDC();
         PIPDeleteParamsSC();
         PIPDeleteParamsNRTR();
         PIPDeleteParamsAL();
         PIPDeleteParamsAMA();
         PIPDeleteParamsIKH();
        }
      else
        {
         PIPDeleteParamsCCI();
         showCCI=false;
        }
      if(showWPR)
        {
         PIPSetEditWPR();
         PIPDeleteParamsMA();
         PIPDeleteParamsMACD();
         PIPDeleteParamsPC();
         PIPDeleteParamsADX();
         PIPDeleteParamsSO();
         PIPDeleteParamsRSI();
         PIPDeleteParamsCCI();
         PIPDeleteParamsBB();
         PIPDeleteParamsSDC();
         PIPDeleteParamsPC2();
         PIPDeleteParamsENV();
         PIPDeleteParamsDC();
         PIPDeleteParamsSC();
         PIPDeleteParamsNRTR();
         PIPDeleteParamsAL();
         PIPDeleteParamsAMA();
         PIPDeleteParamsIKH();
        }
      else
        {
         PIPDeleteParamsWPR();
         showWPR=false;
        }
      if(showBB)
        {
         PIPSetEditBB();
         PIPDeleteParamsMA();
         PIPDeleteParamsMACD();
         PIPDeleteParamsPC();
         PIPDeleteParamsADX();
         PIPDeleteParamsSO();
         PIPDeleteParamsRSI();
         PIPDeleteParamsCCI();
         PIPDeleteParamsWPR();
         PIPDeleteParamsSDC();
         PIPDeleteParamsPC2();
         PIPDeleteParamsENV();
         PIPDeleteParamsDC();
         PIPDeleteParamsSC();
         PIPDeleteParamsNRTR();
         PIPDeleteParamsAL();
         PIPDeleteParamsAMA();
         PIPDeleteParamsIKH();
        }
      else
        {
         PIPDeleteParamsBB();
         showBB=false;
        }
      if(showSDC)
        {
         PIPSetEditSDC();
         PIPDeleteParamsMA();
         PIPDeleteParamsMACD();
         PIPDeleteParamsPC();
         PIPDeleteParamsADX();
         PIPDeleteParamsSO();
         PIPDeleteParamsRSI();
         PIPDeleteParamsCCI();
         PIPDeleteParamsWPR();
         PIPDeleteParamsBB();
         PIPDeleteParamsPC2();
         PIPDeleteParamsENV();
         PIPDeleteParamsDC();
         PIPDeleteParamsSC();
         PIPDeleteParamsNRTR();
         PIPDeleteParamsAL();
         PIPDeleteParamsAMA();
         PIPDeleteParamsIKH();
        }
      else
        {
         PIPDeleteParamsSDC();
         showSDC=false;
        }
      if(showPC2)
        {
         PIPSetEditPC2();
         PIPDeleteParamsMA();
         PIPDeleteParamsMACD();
         PIPDeleteParamsPC();
         PIPDeleteParamsADX();
         PIPDeleteParamsSO();
         PIPDeleteParamsRSI();
         PIPDeleteParamsCCI();
         PIPDeleteParamsWPR();
         PIPDeleteParamsBB();
         PIPDeleteParamsSDC();
         PIPDeleteParamsENV();
         PIPDeleteParamsDC();
         PIPDeleteParamsSC();
         PIPDeleteParamsNRTR();
         PIPDeleteParamsAL();
         PIPDeleteParamsAMA();
         PIPDeleteParamsIKH();
        }
      else
        {
         PIPDeleteParamsPC2();
         showPC2=false;
        }
      if(showENV)
        {
         PIPSetEditENV();
         PIPDeleteParamsMA();
         PIPDeleteParamsMACD();
         PIPDeleteParamsPC();
         PIPDeleteParamsADX();
         PIPDeleteParamsSO();
         PIPDeleteParamsRSI();
         PIPDeleteParamsCCI();
         PIPDeleteParamsWPR();
         PIPDeleteParamsBB();
         PIPDeleteParamsSDC();
         PIPDeleteParamsPC2();
         PIPDeleteParamsDC();
         PIPDeleteParamsSC();
         PIPDeleteParamsNRTR();
         PIPDeleteParamsAL();
         PIPDeleteParamsAMA();
         PIPDeleteParamsIKH();
        }
      else
        {
         PIPDeleteParamsENV();
         showENV=false;
        }
      if(showDC)
        {
         PIPSetEditDC();
         PIPDeleteParamsMA();
         PIPDeleteParamsMACD();
         PIPDeleteParamsPC();
         PIPDeleteParamsADX();
         PIPDeleteParamsSO();
         PIPDeleteParamsRSI();
         PIPDeleteParamsCCI();
         PIPDeleteParamsWPR();
         PIPDeleteParamsBB();
         PIPDeleteParamsSDC();
         PIPDeleteParamsPC2();
         PIPDeleteParamsENV();
         PIPDeleteParamsSC();
         PIPDeleteParamsNRTR();
         PIPDeleteParamsAL();
         PIPDeleteParamsAMA();
         PIPDeleteParamsIKH();
        }
      else
        {
         PIPDeleteParamsDC();
         showDC=false;
        }
      if(showSC)
        {
         PIPSetEditSC();
         PIPDeleteParamsMA();
         PIPDeleteParamsMACD();
         PIPDeleteParamsPC();
         PIPDeleteParamsADX();
         PIPDeleteParamsSO();
         PIPDeleteParamsRSI();
         PIPDeleteParamsCCI();
         PIPDeleteParamsWPR();
         PIPDeleteParamsBB();
         PIPDeleteParamsSDC();
         PIPDeleteParamsPC2();
         PIPDeleteParamsENV();
         PIPDeleteParamsDC();
         PIPDeleteParamsNRTR();
         PIPDeleteParamsAL();
         PIPDeleteParamsAMA();
         PIPDeleteParamsIKH();
        }
      else
        {
         PIPDeleteParamsSC();
         showSC=false;
        }
      if(showNRTR)
        {
         PIPSetEditNRTR();
         PIPDeleteParamsMA();
         PIPDeleteParamsMACD();
         PIPDeleteParamsPC();
         PIPDeleteParamsADX();
         PIPDeleteParamsSO();
         PIPDeleteParamsRSI();
         PIPDeleteParamsCCI();
         PIPDeleteParamsWPR();
         PIPDeleteParamsBB();
         PIPDeleteParamsSDC();
         PIPDeleteParamsPC2();
         PIPDeleteParamsENV();
         PIPDeleteParamsDC();
         PIPDeleteParamsSC();
         PIPDeleteParamsAL();
         PIPDeleteParamsAMA();
         PIPDeleteParamsIKH();
        }
      else
        {
         PIPDeleteParamsNRTR();
         showNRTR=false;
        }
      if(showAL)
        {
         PIPSetEditAL();
         PIPDeleteParamsMA();
         PIPDeleteParamsMACD();
         PIPDeleteParamsPC();
         PIPDeleteParamsADX();
         PIPDeleteParamsSO();
         PIPDeleteParamsRSI();
         PIPDeleteParamsCCI();
         PIPDeleteParamsWPR();
         PIPDeleteParamsBB();
         PIPDeleteParamsSDC();
         PIPDeleteParamsPC2();
         PIPDeleteParamsENV();
         PIPDeleteParamsDC();
         PIPDeleteParamsSC();
         PIPDeleteParamsNRTR();
         PIPDeleteParamsAMA();
         PIPDeleteParamsIKH();
        }
      else
        {
         PIPDeleteParamsAL();
         showAL=false;
        }
      if(showAMA)
        {
         PIPSetEditAMA();
         PIPDeleteParamsMA();
         PIPDeleteParamsMACD();
         PIPDeleteParamsPC();
         PIPDeleteParamsADX();
         PIPDeleteParamsSO();
         PIPDeleteParamsRSI();
         PIPDeleteParamsCCI();
         PIPDeleteParamsWPR();
         PIPDeleteParamsBB();
         PIPDeleteParamsSDC();
         PIPDeleteParamsPC2();
         PIPDeleteParamsENV();
         PIPDeleteParamsDC();
         PIPDeleteParamsSC();
         PIPDeleteParamsNRTR();
         PIPDeleteParamsAL();
         PIPDeleteParamsIKH();
        }
      else
        {
         PIPDeleteParamsAMA();
         showAMA=false;
        }
      if(showIKH)
        {
         PIPSetEditIKH();
         PIPDeleteParamsMA();
         PIPDeleteParamsMACD();
         PIPDeleteParamsPC();
         PIPDeleteParamsADX();
         PIPDeleteParamsSO();
         PIPDeleteParamsRSI();
         PIPDeleteParamsCCI();
         PIPDeleteParamsWPR();
         PIPDeleteParamsBB();
         PIPDeleteParamsSDC();
         PIPDeleteParamsPC2();
         PIPDeleteParamsENV();
         PIPDeleteParamsDC();
         PIPDeleteParamsSC();
         PIPDeleteParamsNRTR();
         PIPDeleteParamsAL();
         PIPDeleteParamsAMA();
        }
      else
        {
         PIPDeleteParamsIKH();
         showIKH=false;
        }

      //-----------------------------------------------------------------
      PIPSetMenu();
      ChartRedraw();
     }
   else
     {
      showMA=false;
      showMACD=false;
      PIPDeleteMenu();
     }

   PIPSetParams();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
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

  }
//+------------------------------------------------------------------+
//| Create objects                                                   |
//+------------------------------------------------------------------+
void PIPCreate()
  {
   ObjectCreate(0,"PIPIndNaneButton",OBJ_BUTTON,0,0,0,0,0);
  }
//+------------------------------------------------------------------+
//| Delete objects                                                   |
//+------------------------------------------------------------------+
void PIPDelete()
  {
   ObjectDelete(0,"PIPIndNaneButton");
   PIPDeleteMenu();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPDeleteMenu()
  {
   ObjectDelete(0,"PIPIndNaneButtonMA");
   PIPDeleteParamsMA();
   ObjectDelete(0,"PIPIndNaneButtonMACD");
   PIPDeleteParamsMACD();
   ObjectDelete(0,"PIPIndNameButtonPC");
   PIPDeleteParamsPC();
   ObjectDelete(0,"PIPIndNameButtonACADX");
   PIPDeleteParamsADX();
   ObjectDelete(0,"PIPIndNameButtonSO");
   PIPDeleteParamsSO();
   ObjectDelete(0,"PIPIndNameButtonRSI");
   PIPDeleteParamsRSI();
   ObjectDelete(0,"PIPIndNameButtonCCI");
   PIPDeleteParamsCCI();
   ObjectDelete(0,"PIPIndNameButtonWPR");
   PIPDeleteParamsWPR();
   ObjectDelete(0,"PIPIndNameButtonBB");
   PIPDeleteParamsBB();
   ObjectDelete(0,"PIPIndNameButtonSDC");
   PIPDeleteParamsSDC();
   ObjectDelete(0,"PIPIndNameButtonPC2");
   PIPDeleteParamsPC2();
   ObjectDelete(0,"PIPIndNameButtonENV");
   PIPDeleteParamsENV();
   ObjectDelete(0,"PIPIndNameButtonDC");
   PIPDeleteParamsDC();
   ObjectDelete(0,"PIPIndNameButtonSC");
   PIPDeleteParamsSC();
   ObjectDelete(0,"PIPIndNameButtonNRTR");
   PIPDeleteParamsNRTR();
   ObjectDelete(0,"PIPIndNameButtonAL");
   PIPDeleteParamsAL();
   ObjectDelete(0,"PIPIndNameButtonAMA");
   PIPDeleteParamsAMA();
   ObjectDelete(0,"PIPIndNameButtonIKH");
   PIPDeleteParamsIKH();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPDeleteParamsMA()
  {
   ObjectDelete(0,"PIPSetEditMA1");
   ObjectDelete(0,"PIPSetEditMAPeriod1");
   ObjectDelete(0,"PIPSetEditMA2");
   ObjectDelete(0,"PIPSetEditMAPeriod2");
   ObjectDelete(0,"PIPSetMAmethod");
   ObjectDelete(0,"PIPSetEditMAmethod");
   ObjectDelete(0,"PIPSetMAprice");
   ObjectDelete(0,"PIPSetEditMAprice");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPDeleteParamsMACD()
  {
   ObjectDelete(0,"PIPSetFastMACD");
   ObjectDelete(0,"PIPSetEditFastMACD");
   ObjectDelete(0,"PIPSetSlowMACD");
   ObjectDelete(0,"PIPSetEditSlowMACD");
   ObjectDelete(0,"PIPSetMACDSMA");
   ObjectDelete(0,"PIPSetEditMACDSMA");
   ObjectDelete(0,"PIPSetMACDprice");
   ObjectDelete(0,"PIPSetEditMACDprice");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPDeleteParamsPC()
  {
   ObjectDelete(0,"PIPSetPCPeriod");
   ObjectDelete(0,"PIPSetEditPCPeriod");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPDeleteParamsADX()
  {
   ObjectDelete(0,"PIPSetADXPeriod");
   ObjectDelete(0,"PIPSetEditADXPeriod");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPDeleteParamsSO()
  {
   ObjectDelete(0,"PIPSetSOPeriodK");
   ObjectDelete(0,"PIPSetEditSOPeriodK");
   ObjectDelete(0,"PIPSetSOPeriodD");
   ObjectDelete(0,"PIPSetEditSOPeriodD");
   ObjectDelete(0,"PIPSetSOslowing");
   ObjectDelete(0,"PIPSetEditSOslowing");
   ObjectDelete(0,"PIPSetSOmethod");
   ObjectDelete(0,"PIPSetEditSOmethod");
   ObjectDelete(0,"PIPSetSOpricefield");
   ObjectDelete(0,"PIPSetEditSOpricefield");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPDeleteParamsRSI()
  {
   ObjectDelete(0,"PIPSetRSIPeriod");
   ObjectDelete(0,"PIPSetEditRSIPeriod");
   ObjectDelete(0,"PIPSetRSIprice");
   ObjectDelete(0,"PIPSetEditRSIprice");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPDeleteParamsCCI()
  {
   ObjectDelete(0,"PIPSetCCIPeriod");
   ObjectDelete(0,"PIPSetEditCCIPeriod");
   ObjectDelete(0,"PIPSetCCIprice");
   ObjectDelete(0,"PIPSetEditCCIprice");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPDeleteParamsWPR()
  {
   ObjectDelete(0,"PIPSetWPRPeriod");
   ObjectDelete(0,"PIPSetEditWPRPeriod");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPDeleteParamsBB()
  {
   ObjectDelete(0,"PIPSetBBPeriod");
   ObjectDelete(0,"PIPSetEditBBPeriod");
   ObjectDelete(0,"PIPSetBBdeviation");
   ObjectDelete(0,"PIPSetEditBBdeviation");
   ObjectDelete(0,"PIPSetBBprice");
   ObjectDelete(0,"PIPSetEditBBprice");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPDeleteParamsSDC()
  {
   ObjectDelete(0,"PIPSetSDCPeriod");
   ObjectDelete(0,"PIPSetEditSDCPeriod");
   ObjectDelete(0,"PIPSetSDCdeviation");
   ObjectDelete(0,"PIPSetEditSDCdeviation");
   ObjectDelete(0,"PIPSetSDCprice");
   ObjectDelete(0,"PIPSetEditSDCprice");
   ObjectDelete(0,"PIPSetSDCmethod");
   ObjectDelete(0,"PIPSetEditSDCmethod");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPDeleteParamsENV()
  {
   ObjectDelete(0,"PIPSetENVPeriod");
   ObjectDelete(0,"PIPSetEditENVPeriod");
   ObjectDelete(0,"PIPSetENVdeviation");
   ObjectDelete(0,"PIPSetEditENVdeviation");
   ObjectDelete(0,"PIPSetENVprice");
   ObjectDelete(0,"PIPSetEditENVprice");
   ObjectDelete(0,"PIPSetENVmethod");
   ObjectDelete(0,"PIPSetEditENVmethod");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPDeleteParamsPC2()
  {
   ObjectDelete(0,"PIPSetPC2Period");
   ObjectDelete(0,"PIPSetEditPC2Period");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPDeleteParamsDC()
  {
   ObjectDelete(0,"PIPSetDCPeriod");
   ObjectDelete(0,"PIPSetEditDCPeriod");
   ObjectDelete(0,"PIPSetDCExtremes");
   ObjectDelete(0,"PIPSetEditDCExtremes");
   ObjectDelete(0,"PIPSetDCMargins");
   ObjectDelete(0,"PIPSetEditDCMargins");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPDeleteParamsSC()
  {
   ObjectDelete(0,"PIPSetSCPeriod");
   ObjectDelete(0,"PIPSetEditSCPeriod");
   ObjectDelete(0,"PIPSetSCSilvCh");
   ObjectDelete(0,"PIPSetEditSCSilvCh");
   ObjectDelete(0,"PIPSetSCSkyCh");
   ObjectDelete(0,"PIPSetEditSCSkyCh");
   ObjectDelete(0,"PIPSetSCFutCh");
   ObjectDelete(0,"PIPSetEditSCFutCh");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPDeleteParamsNRTR()
  {
   ObjectDelete(0,"PIPSetNRTRPeriod");
   ObjectDelete(0,"PIPSetEditNRTRPeriod");
   ObjectDelete(0,"PIPSetNRTRK");
   ObjectDelete(0,"PIPSetEditNRTRK");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPDeleteParamsAL()
  {
   ObjectDelete(0,"PIPSetALjawperiod");
   ObjectDelete(0,"PIPSetEditALjawperiod");
   ObjectDelete(0,"PIPSetALteethperiod");
   ObjectDelete(0,"PIPSetEditALteethperiod");
   ObjectDelete(0,"PIPSetALlipsperiod");
   ObjectDelete(0,"PIPSetEditALlipsperiod");
   ObjectDelete(0,"PIPSetALmethod");
   ObjectDelete(0,"PIPSetEditALmethod");
   ObjectDelete(0,"PIPSetALprice");
   ObjectDelete(0,"PIPSetEditALprice");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPDeleteParamsAMA()
  {
   ObjectDelete(0,"PIPSetAMAperiod");
   ObjectDelete(0,"PIPSetEditAMAperiod");
   ObjectDelete(0,"PIPSetAMAfastperiod");
   ObjectDelete(0,"PIPSetEditAMAfastperiod");
   ObjectDelete(0,"PIPSetAMAslowperiod");
   ObjectDelete(0,"PIPSetEditAMAslowperiod");
   ObjectDelete(0,"PIPSetAMAprice");
   ObjectDelete(0,"PIPSetEditAMAprice");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPDeleteParamsIKH()
  {
   ObjectDelete(0,"PIPSetIKHtenkansen");
   ObjectDelete(0,"PIPSetEditIKHtenkansen");
   ObjectDelete(0,"PIPSetIKHkijunsen");
   ObjectDelete(0,"PIPSetEditIKHkijunsen");
   ObjectDelete(0,"PIPSetIKHsenkouspanb");
   ObjectDelete(0,"PIPSetEditIKHsenkouspanb");
  }
//+------------------------------------------------------------------+
//| Set objects params                                               |
//+------------------------------------------------------------------+
void PIPSetParams()
  {
   ObjectSetInteger(0,"PIPIndNaneButton",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPIndNaneButton",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPIndNaneButton",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNaneButton",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNaneButton",OBJPROP_XSIZE,200);
   ObjectSetInteger(0,"PIPIndNaneButton",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPIndNaneButton",OBJPROP_TEXT,"Настройки индикаторов");
   ObjectSetString(0,"PIPIndNaneButton",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"PIPIndNaneButton",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPIndNaneButton",OBJPROP_STATE,showdates);
   ObjectSetInteger(0,"PIPIndNaneButton",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPSetMenu()
  {
   if(ObjectFind(0,"PIPIndNaneButtonMA")<0)ObjectCreate(0,"PIPIndNaneButtonMA",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPIndNaneButtonMA",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPIndNaneButtonMA",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPIndNaneButtonMA",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNaneButtonMA",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPIndNaneButtonMA",OBJPROP_XSIZE,200);
   ObjectSetInteger(0,"PIPIndNaneButtonMA",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPIndNaneButtonMA",OBJPROP_TEXT,"Moving Average");
   ObjectSetString(0,"PIPIndNaneButtonMA",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"PIPIndNaneButtonMA",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPIndNaneButtonMA",OBJPROP_STATE,showMA);
   ObjectSetInteger(0,"PIPIndNaneButtonMA",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPIndNaneButtonMACD")<0)ObjectCreate(0,"PIPIndNaneButtonMACD",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPIndNaneButtonMACD",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPIndNaneButtonMACD",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPIndNaneButtonMACD",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNaneButtonMACD",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPIndNaneButtonMACD",OBJPROP_XSIZE,200);
   ObjectSetInteger(0,"PIPIndNaneButtonMACD",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPIndNaneButtonMACD",OBJPROP_TEXT,"MACD");
   ObjectSetString(0,"PIPIndNaneButtonMACD",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"PIPIndNaneButtonMACD",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPIndNaneButtonMACD",OBJPROP_STATE,showMACD);
   ObjectSetInteger(0,"PIPIndNaneButtonMACD",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPIndNameButtonPC")<0)ObjectCreate(0,"PIPIndNameButtonPC",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPIndNameButtonPC",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPIndNameButtonPC",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPIndNameButtonPC",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNameButtonPC",OBJPROP_YDISTANCE,70);
   ObjectSetInteger(0,"PIPIndNameButtonPC",OBJPROP_XSIZE,200);
   ObjectSetInteger(0,"PIPIndNameButtonPC",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPIndNameButtonPC",OBJPROP_TEXT,"Price Channel");
   ObjectSetString(0,"PIPIndNameButtonPC",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"PIPIndNameButtonPC",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPIndNameButtonPC",OBJPROP_STATE,showPC);
   ObjectSetInteger(0,"PIPIndNameButtonPC",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPIndNameButtonACADX")<0)ObjectCreate(0,"PIPIndNameButtonACADX",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPIndNameButtonACADX",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPIndNameButtonACADX",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPIndNameButtonACADX",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNameButtonACADX",OBJPROP_YDISTANCE,90);
   ObjectSetInteger(0,"PIPIndNameButtonACADX",OBJPROP_XSIZE,200);
   ObjectSetInteger(0,"PIPIndNameButtonACADX",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPIndNameButtonACADX",OBJPROP_TEXT,"Adaptive Channel ADX");
   ObjectSetString(0,"PIPIndNameButtonACADX",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"PIPIndNameButtonACADX",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPIndNameButtonACADX",OBJPROP_STATE,showADX);
   ObjectSetInteger(0,"PIPIndNameButtonACADX",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPIndNameButtonSO")<0)ObjectCreate(0,"PIPIndNameButtonSO",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPIndNameButtonSO",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPIndNameButtonSO",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPIndNameButtonSO",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNameButtonSO",OBJPROP_YDISTANCE,110);
   ObjectSetInteger(0,"PIPIndNameButtonSO",OBJPROP_XSIZE,200);
   ObjectSetInteger(0,"PIPIndNameButtonSO",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPIndNameButtonSO",OBJPROP_TEXT,"Stochastic Oscillator");
   ObjectSetString(0,"PIPIndNameButtonSO",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"PIPIndNameButtonSO",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPIndNameButtonSO",OBJPROP_STATE,showSO);
   ObjectSetInteger(0,"PIPIndNameButtonSO",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPIndNameButtonRSI")<0)ObjectCreate(0,"PIPIndNameButtonRSI",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPIndNameButtonRSI",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPIndNameButtonRSI",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPIndNameButtonRSI",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNameButtonRSI",OBJPROP_YDISTANCE,110);
   ObjectSetInteger(0,"PIPIndNameButtonRSI",OBJPROP_XSIZE,200);
   ObjectSetInteger(0,"PIPIndNameButtonRSI",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPIndNameButtonRSI",OBJPROP_TEXT,"RSI");
   ObjectSetString(0,"PIPIndNameButtonRSI",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"PIPIndNameButtonRSI",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPIndNameButtonRSI",OBJPROP_STATE,showRSI);
   ObjectSetInteger(0,"PIPIndNameButtonRSI",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPIndNameButtonCCI")<0)ObjectCreate(0,"PIPIndNameButtonCCI",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPIndNameButtonCCI",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPIndNameButtonCCI",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPIndNameButtonCCI",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNameButtonCCI",OBJPROP_YDISTANCE,130);
   ObjectSetInteger(0,"PIPIndNameButtonCCI",OBJPROP_XSIZE,200);
   ObjectSetInteger(0,"PIPIndNameButtonCCI",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPIndNameButtonCCI",OBJPROP_TEXT,"CCI");
   ObjectSetString(0,"PIPIndNameButtonCCI",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"PIPIndNameButtonCCI",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPIndNameButtonCCI",OBJPROP_STATE,showCCI);
   ObjectSetInteger(0,"PIPIndNameButtonCCI",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPIndNameButtonWPR")<0)ObjectCreate(0,"PIPIndNameButtonWPR",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPIndNameButtonWPR",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPIndNameButtonWPR",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPIndNameButtonWPR",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNameButtonWPR",OBJPROP_YDISTANCE,150);
   ObjectSetInteger(0,"PIPIndNameButtonWPR",OBJPROP_XSIZE,200);
   ObjectSetInteger(0,"PIPIndNameButtonWPR",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPIndNameButtonWPR",OBJPROP_TEXT,"WPR");
   ObjectSetString(0,"PIPIndNameButtonWPR",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"PIPIndNameButtonWPR",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPIndNameButtonWPR",OBJPROP_STATE,showWPR);
   ObjectSetInteger(0,"PIPIndNameButtonWPR",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPIndNameButtonBB")<0)ObjectCreate(0,"PIPIndNameButtonBB",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPIndNameButtonBB",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPIndNameButtonBB",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPIndNameButtonBB",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNameButtonBB",OBJPROP_YDISTANCE,170);
   ObjectSetInteger(0,"PIPIndNameButtonBB",OBJPROP_XSIZE,200);
   ObjectSetInteger(0,"PIPIndNameButtonBB",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPIndNameButtonBB",OBJPROP_TEXT,"Bollinger Bands");
   ObjectSetString(0,"PIPIndNameButtonBB",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"PIPIndNameButtonBB",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPIndNameButtonBB",OBJPROP_STATE,showBB);
   ObjectSetInteger(0,"PIPIndNameButtonBB",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPIndNameButtonSDC")<0)ObjectCreate(0,"PIPIndNameButtonSDC",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPIndNameButtonSDC",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPIndNameButtonSDC",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPIndNameButtonSDC",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNameButtonSDC",OBJPROP_YDISTANCE,190);
   ObjectSetInteger(0,"PIPIndNameButtonSDC",OBJPROP_XSIZE,200);
   ObjectSetInteger(0,"PIPIndNameButtonSDC",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPIndNameButtonSDC",OBJPROP_TEXT,"Standard Deviation Channel");
   ObjectSetString(0,"PIPIndNameButtonSDC",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"PIPIndNameButtonSDC",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPIndNameButtonSDC",OBJPROP_STATE,showSDC);
   ObjectSetInteger(0,"PIPIndNameButtonSDC",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPIndNameButtonPC2")<0)ObjectCreate(0,"PIPIndNameButtonPC2",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPIndNameButtonPC2",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPIndNameButtonPC2",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPIndNameButtonPC2",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNameButtonPC2",OBJPROP_YDISTANCE,210);
   ObjectSetInteger(0,"PIPIndNameButtonPC2",OBJPROP_XSIZE,200);
   ObjectSetInteger(0,"PIPIndNameButtonPC2",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPIndNameButtonPC2",OBJPROP_TEXT,"Price Channel 2");
   ObjectSetString(0,"PIPIndNameButtonPC2",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"PIPIndNameButtonPC2",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPIndNameButtonPC2",OBJPROP_STATE,showPC2);
   ObjectSetInteger(0,"PIPIndNameButtonPC2",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPIndNameButtonENV")<0)ObjectCreate(0,"PIPIndNameButtonENV",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPIndNameButtonENV",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPIndNameButtonENV",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPIndNameButtonENV",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNameButtonENV",OBJPROP_YDISTANCE,230);
   ObjectSetInteger(0,"PIPIndNameButtonENV",OBJPROP_XSIZE,200);
   ObjectSetInteger(0,"PIPIndNameButtonENV",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPIndNameButtonENV",OBJPROP_TEXT,"Envelopes");
   ObjectSetString(0,"PIPIndNameButtonENV",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"PIPIndNameButtonENV",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPIndNameButtonENV",OBJPROP_STATE,showPC2);
   ObjectSetInteger(0,"PIPIndNameButtonENV",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPIndNameButtonDC")<0)ObjectCreate(0,"PIPIndNameButtonDC",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPIndNameButtonDC",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPIndNameButtonDC",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPIndNameButtonDC",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNameButtonDC",OBJPROP_YDISTANCE,230);
   ObjectSetInteger(0,"PIPIndNameButtonDC",OBJPROP_XSIZE,200);
   ObjectSetInteger(0,"PIPIndNameButtonDC",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPIndNameButtonDC",OBJPROP_TEXT,"Donchian Channels");
   ObjectSetString(0,"PIPIndNameButtonDC",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"PIPIndNameButtonDC",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPIndNameButtonDC",OBJPROP_STATE,showDC);
   ObjectSetInteger(0,"PIPIndNameButtonDC",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPIndNameButtonSC")<0)ObjectCreate(0,"PIPIndNameButtonSC",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPIndNameButtonSC",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPIndNameButtonSC",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPIndNameButtonSC",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNameButtonSC",OBJPROP_YDISTANCE,250);
   ObjectSetInteger(0,"PIPIndNameButtonSC",OBJPROP_XSIZE,200);
   ObjectSetInteger(0,"PIPIndNameButtonSC",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPIndNameButtonSC",OBJPROP_TEXT,"Silver-channels");
   ObjectSetString(0,"PIPIndNameButtonSC",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"PIPIndNameButtonSC",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPIndNameButtonSC",OBJPROP_STATE,showSC);
   ObjectSetInteger(0,"PIPIndNameButtonSC",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPIndNameButtonNRTR")<0)ObjectCreate(0,"PIPIndNameButtonNRTR",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPIndNameButtonNRTR",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPIndNameButtonNRTR",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPIndNameButtonNRTR",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNameButtonNRTR",OBJPROP_YDISTANCE,270);
   ObjectSetInteger(0,"PIPIndNameButtonNRTR",OBJPROP_XSIZE,200);
   ObjectSetInteger(0,"PIPIndNameButtonNRTR",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPIndNameButtonNRTR",OBJPROP_TEXT,"NRTR");
   ObjectSetString(0,"PIPIndNameButtonNRTR",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"PIPIndNameButtonNRTR",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPIndNameButtonNRTR",OBJPROP_STATE,showNRTR);
   ObjectSetInteger(0,"PIPIndNameButtonNRTR",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPIndNameButtonAL")<0)ObjectCreate(0,"PIPIndNameButtonAL",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPIndNameButtonAL",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPIndNameButtonAL",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPIndNameButtonAL",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNameButtonAL",OBJPROP_YDISTANCE,290);
   ObjectSetInteger(0,"PIPIndNameButtonAL",OBJPROP_XSIZE,200);
   ObjectSetInteger(0,"PIPIndNameButtonAL",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPIndNameButtonAL",OBJPROP_TEXT,"Alligator");
   ObjectSetString(0,"PIPIndNameButtonAL",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"PIPIndNameButtonAL",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPIndNameButtonAL",OBJPROP_STATE,showAL);
   ObjectSetInteger(0,"PIPIndNameButtonAL",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPIndNameButtonAMA")<0)ObjectCreate(0,"PIPIndNameButtonAMA",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPIndNameButtonAMA",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPIndNameButtonAMA",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPIndNameButtonAMA",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNameButtonAMA",OBJPROP_YDISTANCE,290);
   ObjectSetInteger(0,"PIPIndNameButtonAMA",OBJPROP_XSIZE,200);
   ObjectSetInteger(0,"PIPIndNameButtonAMA",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPIndNameButtonAMA",OBJPROP_TEXT,"AMA");
   ObjectSetString(0,"PIPIndNameButtonAMA",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"PIPIndNameButtonAMA",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPIndNameButtonAMA",OBJPROP_STATE,showAMA);
   ObjectSetInteger(0,"PIPIndNameButtonAMA",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPIndNameButtonIKH")<0)ObjectCreate(0,"PIPIndNameButtonIKH",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPIndNameButtonIKH",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPIndNameButtonIKH",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPIndNameButtonIKH",OBJPROP_XDISTANCE,10);
   ObjectSetInteger(0,"PIPIndNameButtonIKH",OBJPROP_YDISTANCE,310);
   ObjectSetInteger(0,"PIPIndNameButtonIKH",OBJPROP_XSIZE,200);
   ObjectSetInteger(0,"PIPIndNameButtonIKH",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPIndNameButtonIKH",OBJPROP_TEXT,"Ichimoku Kinko Hyo");
   ObjectSetString(0,"PIPIndNameButtonIKH",OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,"PIPIndNameButtonIKH",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPIndNameButtonIKH",OBJPROP_STATE,showIKH);
   ObjectSetInteger(0,"PIPIndNameButtonIKH",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPSetEditMA()
  {
   if(ObjectFind(0,"PIPSetEditMAPeriod1")<0)ObjectCreate(0,"PIPSetEditMAPeriod1",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditMAPeriod1",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditMAPeriod1",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditMAPeriod1",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetEditMAPeriod1",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetEditMAPeriod1",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditMAPeriod1",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditMAPeriod1",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditMAPeriod1",OBJPROP_TEXT,"Period MA 1");
   ObjectSetInteger(0,"PIPSetEditMAPeriod1",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditMAPeriod1",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditMA1")<0)ObjectCreate(0,"PIPSetEditMA1",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditMA1",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditMA1",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditMA1",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditMA1",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetEditMA1",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditMA1",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditMA1",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditMA1",OBJPROP_TEXT,(string)periodma1);
   ObjectSetInteger(0,"PIPSetEditMA1",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditMA1",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetEditMAPeriod2")<0)ObjectCreate(0,"PIPSetEditMAPeriod2",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditMAPeriod2",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditMAPeriod2",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditMAPeriod2",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetEditMAPeriod2",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetEditMAPeriod2",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditMAPeriod2",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditMAPeriod2",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditMAPeriod2",OBJPROP_TEXT,"Period MA 2");
   ObjectSetInteger(0,"PIPSetEditMAPeriod2",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditMAPeriod2",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditMA2")<0)ObjectCreate(0,"PIPSetEditMA2",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditMA2",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditMA2",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditMA2",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditMA2",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetEditMA2",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditMA2",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditMA2",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditMA2",OBJPROP_TEXT,(string)periodma2);
   ObjectSetInteger(0,"PIPSetEditMA2",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditMA2",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetMAmethod")<0)ObjectCreate(0,"PIPSetMAmethod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetMAmethod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetMAmethod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetMAmethod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetMAmethod",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetMAmethod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetMAmethod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetMAmethod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetMAmethod",OBJPROP_TEXT,"MA method");
   ObjectSetInteger(0,"PIPSetMAmethod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetMAmethod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditMAmethod")<0)ObjectCreate(0,"PIPSetEditMAmethod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditMAmethod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditMAmethod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditMAmethod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditMAmethod",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetEditMAmethod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditMAmethod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditMAmethod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditMAmethod",OBJPROP_TEXT,(string)MAmethod);
   ObjectSetInteger(0,"PIPSetEditMAmethod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditMAmethod",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetMAprice")<0)ObjectCreate(0,"PIPSetMAprice",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetMAprice",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetMAprice",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetMAprice",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetMAprice",OBJPROP_YDISTANCE,70);
   ObjectSetInteger(0,"PIPSetMAprice",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetMAprice",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetMAprice",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetMAprice",OBJPROP_TEXT,"MA price");
   ObjectSetInteger(0,"PIPSetMAprice",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetMAprice",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditMAprice")<0)ObjectCreate(0,"PIPSetEditMAprice",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditMAprice",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditMAprice",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditMAprice",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditMAprice",OBJPROP_YDISTANCE,70);
   ObjectSetInteger(0,"PIPSetEditMAprice",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditMAprice",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditMAprice",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditMAprice",OBJPROP_TEXT,(string)MAprice);
   ObjectSetInteger(0,"PIPSetEditMAprice",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditMAprice",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPSetEditMACD()
  {
   if(ObjectFind(0,"PIPSetFastMACD")<0)ObjectCreate(0,"PIPSetFastMACD",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetFastMACD",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetFastMACD",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetFastMACD",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetFastMACD",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetFastMACD",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetFastMACD",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetFastMACD",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetFastMACD",OBJPROP_TEXT,"Fast EMA");
   ObjectSetInteger(0,"PIPSetFastMACD",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetFastMACD",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditFastMACD")<0)ObjectCreate(0,"PIPSetEditFastMACD",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditFastMACD",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditFastMACD",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditFastMACD",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditFastMACD",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetEditFastMACD",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditFastMACD",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditFastMACD",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditFastMACD",OBJPROP_TEXT,(string)FastMACD);
   ObjectSetInteger(0,"PIPSetEditFastMACD",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditFastMACD",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetSlowMACD")<0)ObjectCreate(0,"PIPSetSlowMACD",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetSlowMACD",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetSlowMACD",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetSlowMACD",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetSlowMACD",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetSlowMACD",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetSlowMACD",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetSlowMACD",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetSlowMACD",OBJPROP_TEXT,"Slow EMA");
   ObjectSetInteger(0,"PIPSetSlowMACD",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetSlowMACD",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditSlowMACD")<0)ObjectCreate(0,"PIPSetEditSlowMACD",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditSlowMACD",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditSlowMACD",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditSlowMACD",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditSlowMACD",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetEditSlowMACD",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditSlowMACD",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditSlowMACD",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditSlowMACD",OBJPROP_TEXT,(string)SlowMACD);
   ObjectSetInteger(0,"PIPSetEditSlowMACD",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditSlowMACD",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetMACDSMA")<0)ObjectCreate(0,"PIPSetMACDSMA",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetMACDSMA",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetMACDSMA",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetMACDSMA",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetMACDSMA",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetMACDSMA",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetMACDSMA",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetMACDSMA",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetMACDSMA",OBJPROP_TEXT,"MACD SMA");
   ObjectSetInteger(0,"PIPSetMACDSMA",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetMACDSMA",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditMACDSMA")<0)ObjectCreate(0,"PIPSetEditMACDSMA",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditMACDSMA",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditMACDSMA",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditMACDSMA",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditMACDSMA",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetEditMACDSMA",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditMACDSMA",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditMACDSMA",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditMACDSMA",OBJPROP_TEXT,(string)MACDSMA);
   ObjectSetInteger(0,"PIPSetEditMACDSMA",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditMACDSMA",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetMACDprice")<0)ObjectCreate(0,"PIPSetMACDprice",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetMACDprice",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetMACDprice",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetMACDprice",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetMACDprice",OBJPROP_YDISTANCE,70);
   ObjectSetInteger(0,"PIPSetMACDprice",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetMACDprice",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetMACDprice",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetMACDprice",OBJPROP_TEXT,"MACD price");
   ObjectSetInteger(0,"PIPSetMACDprice",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetMACDprice",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditMACDprice")<0)ObjectCreate(0,"PIPSetEditMACDprice",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditMACDprice",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditMACDprice",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditMACDprice",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditMACDprice",OBJPROP_YDISTANCE,70);
   ObjectSetInteger(0,"PIPSetEditMACDprice",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditMACDprice",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditMACDprice",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditMACDprice",OBJPROP_TEXT,(string)MACDprice);
   ObjectSetInteger(0,"PIPSetEditMACDprice",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditMACDprice",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPSetEditPC()
  {
   if(ObjectFind(0,"PIPSetPCPeriod")<0)ObjectCreate(0,"PIPSetPCPeriod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetPCPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetPCPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetPCPeriod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetPCPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetPCPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetPCPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetPCPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetPCPeriod",OBJPROP_TEXT,"Period PC");
   ObjectSetInteger(0,"PIPSetPCPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetPCPeriod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditPCPeriod")<0)ObjectCreate(0,"PIPSetEditPCPeriod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditPCPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditPCPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditPCPeriod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditPCPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetEditPCPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditPCPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditPCPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditPCPeriod",OBJPROP_TEXT,(string)PCPeriod);
   ObjectSetInteger(0,"PIPSetEditPCPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditPCPeriod",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPSetEditADX()
  {
   if(ObjectFind(0,"PIPSetADXPeriod")<0)ObjectCreate(0,"PIPSetADXPeriod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetADXPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetADXPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetADXPeriod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetADXPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetADXPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetADXPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetADXPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetADXPeriod",OBJPROP_TEXT,"Period ADX");
   ObjectSetInteger(0,"PIPSetADXPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetADXPeriod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditADXPeriod")<0)ObjectCreate(0,"PIPSetEditADXPeriod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditADXPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditADXPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditADXPeriod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditADXPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetEditADXPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditADXPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditADXPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditADXPeriod",OBJPROP_TEXT,(string)ADXPeriod);
   ObjectSetInteger(0,"PIPSetEditADXPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditADXPeriod",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPSetEditSO()
  {
   if(ObjectFind(0,"PIPSetSOPeriodK")<0)ObjectCreate(0,"PIPSetSOPeriodK",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetSOPeriodK",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetSOPeriodK",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetSOPeriodK",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetSOPeriodK",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetSOPeriodK",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetSOPeriodK",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetSOPeriodK",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetSOPeriodK",OBJPROP_TEXT,"Period %K");
   ObjectSetInteger(0,"PIPSetSOPeriodK",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetSOPeriodK",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditSOPeriodK")<0)ObjectCreate(0,"PIPSetEditSOPeriodK",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditSOPeriodK",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditSOPeriodK",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditSOPeriodK",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditSOPeriodK",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetEditSOPeriodK",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditSOPeriodK",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditSOPeriodK",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditSOPeriodK",OBJPROP_TEXT,(string)SOPeriodK);
   ObjectSetInteger(0,"PIPSetEditSOPeriodK",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditSOPeriodK",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetSOPeriodD")<0)ObjectCreate(0,"PIPSetSOPeriodD",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetSOPeriodD",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetSOPeriodD",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetSOPeriodD",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetSOPeriodD",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetSOPeriodD",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetSOPeriodD",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetSOPeriodD",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetSOPeriodD",OBJPROP_TEXT,"Period %D");
   ObjectSetInteger(0,"PIPSetSOPeriodD",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetSOPeriodD",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditSOPeriodD")<0)ObjectCreate(0,"PIPSetEditSOPeriodD",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditSOPeriodD",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditSOPeriodD",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditSOPeriodD",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditSOPeriodD",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetEditSOPeriodD",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditSOPeriodD",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditSOPeriodD",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditSOPeriodD",OBJPROP_TEXT,(string)SOPeriodD);
   ObjectSetInteger(0,"PIPSetEditSOPeriodD",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditSOPeriodD",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetSOslowing")<0)ObjectCreate(0,"PIPSetSOslowing",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetSOslowing",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetSOslowing",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetSOslowing",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetSOslowing",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetSOslowing",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetSOslowing",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetSOslowing",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetSOslowing",OBJPROP_TEXT,"Slowing");
   ObjectSetInteger(0,"PIPSetSOslowing",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetSOslowing",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditSOslowing")<0)ObjectCreate(0,"PIPSetEditSOslowing",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditSOslowing",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditSOslowing",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditSOslowing",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditSOslowing",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetEditSOslowing",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditSOslowing",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditSOslowing",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditSOslowing",OBJPROP_TEXT,(string)SOslowing);
   ObjectSetInteger(0,"PIPSetEditSOslowing",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditSOslowing",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetSOmethod")<0)ObjectCreate(0,"PIPSetSOmethod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetSOmethod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetSOmethod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetSOmethod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetSOmethod",OBJPROP_YDISTANCE,70);
   ObjectSetInteger(0,"PIPSetSOmethod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetSOmethod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetSOmethod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetSOmethod",OBJPROP_TEXT,"Method");
   ObjectSetInteger(0,"PIPSetSOmethod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetSOmethod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditSOmethod")<0)ObjectCreate(0,"PIPSetEditSOmethod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditSOmethod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditSOmethod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditSOmethod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditSOmethod",OBJPROP_YDISTANCE,70);
   ObjectSetInteger(0,"PIPSetEditSOmethod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditSOmethod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditSOmethod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditSOmethod",OBJPROP_TEXT,(string)SOmethod);
   ObjectSetInteger(0,"PIPSetEditSOmethod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditSOmethod",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetSOpricefield")<0)ObjectCreate(0,"PIPSetSOpricefield",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetSOpricefield",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetSOpricefield",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetSOpricefield",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetSOpricefield",OBJPROP_YDISTANCE,90);
   ObjectSetInteger(0,"PIPSetSOpricefield",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetSOpricefield",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetSOpricefield",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetSOpricefield",OBJPROP_TEXT,"Price field");
   ObjectSetInteger(0,"PIPSetSOpricefield",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetSOpricefield",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditSOpricefield")<0)ObjectCreate(0,"PIPSetEditSOpricefield",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditSOpricefield",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditSOpricefield",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditSOpricefield",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditSOpricefield",OBJPROP_YDISTANCE,90);
   ObjectSetInteger(0,"PIPSetEditSOpricefield",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditSOpricefield",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditSOpricefield",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditSOpricefield",OBJPROP_TEXT,(string)SOpricefield);
   ObjectSetInteger(0,"PIPSetEditSOpricefield",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditSOpricefield",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPSetEditRSI()
  {
   if(ObjectFind(0,"PIPSetRSIPeriod")<0)ObjectCreate(0,"PIPSetRSIPeriod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetRSIPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetRSIPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetRSIPeriod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetRSIPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetRSIPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetRSIPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetRSIPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetRSIPeriod",OBJPROP_TEXT,"Period RSI");
   ObjectSetInteger(0,"PIPSetRSIPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetRSIPeriod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditRSIPeriod")<0)ObjectCreate(0,"PIPSetEditRSIPeriod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditRSIPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditRSIPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditRSIPeriod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditRSIPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetEditRSIPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditRSIPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditRSIPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditRSIPeriod",OBJPROP_TEXT,(string)RSIPeriod);
   ObjectSetInteger(0,"PIPSetEditRSIPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditRSIPeriod",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetRSIprice")<0)ObjectCreate(0,"PIPSetRSIprice",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetRSIprice",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetRSIprice",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetRSIprice",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetRSIprice",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetRSIprice",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetRSIprice",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetRSIprice",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetRSIprice",OBJPROP_TEXT,"Price");
   ObjectSetInteger(0,"PIPSetRSIprice",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetRSIprice",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditRSIprice")<0)ObjectCreate(0,"PIPSetEditRSIprice",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditRSIprice",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditRSIprice",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditRSIprice",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditRSIprice",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetEditRSIprice",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditRSIprice",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditRSIprice",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditRSIprice",OBJPROP_TEXT,(string)RSIprice);
   ObjectSetInteger(0,"PIPSetEditRSIprice",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditRSIprice",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPSetEditCCI()
  {
   if(ObjectFind(0,"PIPSetCCIPeriod")<0)ObjectCreate(0,"PIPSetCCIPeriod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetCCIPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetCCIPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetCCIPeriod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetCCIPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetCCIPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetCCIPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetCCIPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetCCIPeriod",OBJPROP_TEXT,"Period CCI");
   ObjectSetInteger(0,"PIPSetCCIPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetCCIPeriod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditCCIPeriod")<0)ObjectCreate(0,"PIPSetEditCCIPeriod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditCCIPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditCCIPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditCCIPeriod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditCCIPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetEditCCIPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditCCIPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditCCIPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditCCIPeriod",OBJPROP_TEXT,(string)CCIPeriod);
   ObjectSetInteger(0,"PIPSetEditCCIPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditCCIPeriod",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetCCIprice")<0)ObjectCreate(0,"PIPSetCCIprice",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetCCIprice",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetCCIprice",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetCCIprice",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetCCIprice",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetCCIprice",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetCCIprice",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetCCIprice",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetCCIprice",OBJPROP_TEXT,"Price");
   ObjectSetInteger(0,"PIPSetCCIprice",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetCCIprice",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditCCIprice")<0)ObjectCreate(0,"PIPSetEditCCIprice",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditCCIprice",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditCCIprice",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditCCIprice",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditCCIprice",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetEditCCIprice",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditCCIprice",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditCCIprice",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditCCIprice",OBJPROP_TEXT,(string)CCIprice);
   ObjectSetInteger(0,"PIPSetEditCCIprice",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditCCIprice",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPSetEditWPR()
  {
   if(ObjectFind(0,"PIPSetWPRPeriod")<0)ObjectCreate(0,"PIPSetWPRPeriod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetWPRPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetWPRPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetWPRPeriod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetWPRPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetWPRPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetWPRPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetWPRPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetWPRPeriod",OBJPROP_TEXT,"Period WPR");
   ObjectSetInteger(0,"PIPSetWPRPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetWPRPeriod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditWPRPeriod")<0)ObjectCreate(0,"PIPSetEditWPRPeriod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditWPRPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditWPRPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditWPRPeriod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditWPRPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetEditWPRPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditWPRPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditWPRPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditWPRPeriod",OBJPROP_TEXT,(string)WPRPeriod);
   ObjectSetInteger(0,"PIPSetEditWPRPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditWPRPeriod",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPSetEditBB()
  {
   if(ObjectFind(0,"PIPSetBBPeriod")<0)ObjectCreate(0,"PIPSetBBPeriod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetBBPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetBBPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetBBPeriod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetBBPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetBBPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetBBPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetBBPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetBBPeriod",OBJPROP_TEXT,"Period BB");
   ObjectSetInteger(0,"PIPSetBBPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetBBPeriod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditBBPeriod")<0)ObjectCreate(0,"PIPSetEditBBPeriod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditBBPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditBBPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditBBPeriod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditBBPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetEditBBPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditBBPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditBBPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditBBPeriod",OBJPROP_TEXT,(string)BBPeriod);
   ObjectSetInteger(0,"PIPSetEditBBPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditBBPeriod",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetBBdeviation")<0)ObjectCreate(0,"PIPSetBBdeviation",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetBBdeviation",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetBBdeviation",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetBBdeviation",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetBBdeviation",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetBBdeviation",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetBBdeviation",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetBBdeviation",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetBBdeviation",OBJPROP_TEXT,"deviation");
   ObjectSetInteger(0,"PIPSetBBdeviation",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetBBdeviation",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditBBdeviation")<0)ObjectCreate(0,"PIPSetEditBBdeviation",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditBBdeviation",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditBBdeviation",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditBBdeviation",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditBBdeviation",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetEditBBdeviation",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditBBdeviation",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditBBdeviation",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditBBdeviation",OBJPROP_TEXT,DoubleToString(BBdeviation));
   ObjectSetInteger(0,"PIPSetEditBBdeviation",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditBBdeviation",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetBBprice")<0)ObjectCreate(0,"PIPSetBBprice",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetBBprice",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetBBprice",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetBBprice",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetBBprice",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetBBprice",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetBBprice",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetBBprice",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetBBprice",OBJPROP_TEXT,"price");
   ObjectSetInteger(0,"PIPSetBBprice",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetBBprice",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditBBprice")<0)ObjectCreate(0,"PIPSetEditBBprice",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditBBprice",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditBBprice",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditBBprice",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditBBprice",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetEditBBprice",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditBBprice",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditBBprice",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditBBprice",OBJPROP_TEXT,(string)BBprice);
   ObjectSetInteger(0,"PIPSetEditBBprice",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditBBprice",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPSetEditSDC()
  {
   if(ObjectFind(0,"PIPSetSDCPeriod")<0)ObjectCreate(0,"PIPSetSDCPeriod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetSDCPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetSDCPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetSDCPeriod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetSDCPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetSDCPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetSDCPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetSDCPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetSDCPeriod",OBJPROP_TEXT,"Period");
   ObjectSetInteger(0,"PIPSetSDCPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetSDCPeriod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditSDCPeriod")<0)ObjectCreate(0,"PIPSetEditSDCPeriod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditSDCPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditSDCPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditSDCPeriod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditSDCPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetEditSDCPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditSDCPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditSDCPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditSDCPeriod",OBJPROP_TEXT,(string)SDCPeriod);
   ObjectSetInteger(0,"PIPSetEditSDCPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditSDCPeriod",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetSDCdeviation")<0)ObjectCreate(0,"PIPSetSDCdeviation",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetSDCdeviation",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetSDCdeviation",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetSDCdeviation",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetSDCdeviation",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetSDCdeviation",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetSDCdeviation",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetSDCdeviation",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetSDCdeviation",OBJPROP_TEXT,"deviation");
   ObjectSetInteger(0,"PIPSetSDCdeviation",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetSDCdeviation",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditSDCdeviation")<0)ObjectCreate(0,"PIPSetEditSDCdeviation",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditSDCdeviation",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditSDCdeviation",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditSDCdeviation",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditSDCdeviation",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetEditSDCdeviation",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditSDCdeviation",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditSDCdeviation",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditSDCdeviation",OBJPROP_TEXT,DoubleToString(SDCdeviation));
   ObjectSetInteger(0,"PIPSetEditSDCdeviation",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditSDCdeviation",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetSDCprice")<0)ObjectCreate(0,"PIPSetSDCprice",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetSDCprice",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetSDCprice",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetSDCprice",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetSDCprice",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetSDCprice",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetSDCprice",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetSDCprice",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetSDCprice",OBJPROP_TEXT,"price");
   ObjectSetInteger(0,"PIPSetSDCprice",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetSDCprice",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditSDCprice")<0)ObjectCreate(0,"PIPSetEditSDCprice",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditSDCprice",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditSDCprice",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditSDCprice",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditSDCprice",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetEditSDCprice",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditSDCprice",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditSDCprice",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditSDCprice",OBJPROP_TEXT,(string)SDCprice);
   ObjectSetInteger(0,"PIPSetEditSDCprice",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditSDCprice",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetSDCmethod")<0)ObjectCreate(0,"PIPSetSDCmethod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetSDCmethod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetSDCmethod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetSDCmethod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetSDCmethod",OBJPROP_YDISTANCE,70);
   ObjectSetInteger(0,"PIPSetSDCmethod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetSDCmethod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetSDCmethod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetSDCmethod",OBJPROP_TEXT,"method");
   ObjectSetInteger(0,"PIPSetSDCmethod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetSDCmethod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditSDCmethod")<0)ObjectCreate(0,"PIPSetEditSDCmethod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditSDCmethod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditSDCmethod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditSDCmethod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditSDCmethod",OBJPROP_YDISTANCE,70);
   ObjectSetInteger(0,"PIPSetEditSDCmethod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditSDCmethod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditSDCmethod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditSDCmethod",OBJPROP_TEXT,(string)SDCmethod);
   ObjectSetInteger(0,"PIPSetEditSDCmethod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditSDCmethod",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPSetEditPC2()
  {
   if(ObjectFind(0,"PIPSetPC2Period")<0)ObjectCreate(0,"PIPSetPC2Period",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetPC2Period",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetPC2Period",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetPC2Period",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetPC2Period",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetPC2Period",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetPC2Period",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetPC2Period",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetPC2Period",OBJPROP_TEXT,"Period PC");
   ObjectSetInteger(0,"PIPSetPC2Period",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetPC2Period",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditPC2Period")<0)ObjectCreate(0,"PIPSetEditPC2Period",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditPC2Period",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditPC2Period",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditPC2Period",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditPC2Period",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetEditPC2Period",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditPC2Period",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditPC2Period",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditPC2Period",OBJPROP_TEXT,(string)PC2Period);
   ObjectSetInteger(0,"PIPSetEditPC2Period",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditPC2Period",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPSetEditENV()
  {
   if(ObjectFind(0,"PIPSetENVPeriod")<0)ObjectCreate(0,"PIPSetENVPeriod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetENVPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetENVPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetENVPeriod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetENVPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetENVPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetENVPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetENVPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetENVPeriod",OBJPROP_TEXT,"Period");
   ObjectSetInteger(0,"PIPSetENVPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetENVPeriod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditENVPeriod")<0)ObjectCreate(0,"PIPSetEditENVPeriod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditENVPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditENVPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditENVPeriod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditENVPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetEditENVPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditENVPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditENVPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditENVPeriod",OBJPROP_TEXT,(string)ENVPeriod);
   ObjectSetInteger(0,"PIPSetEditENVPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditENVPeriod",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetENVdeviation")<0)ObjectCreate(0,"PIPSetENVdeviation",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetENVdeviation",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetENVdeviation",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetENVdeviation",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetENVdeviation",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetENVdeviation",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetENVdeviation",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetENVdeviation",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetENVdeviation",OBJPROP_TEXT,"deviation");
   ObjectSetInteger(0,"PIPSetENVdeviation",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetENVdeviation",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditENVdeviation")<0)ObjectCreate(0,"PIPSetEditENVdeviation",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditENVdeviation",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditENVdeviation",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditENVdeviation",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditENVdeviation",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetEditENVdeviation",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditENVdeviation",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditENVdeviation",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditENVdeviation",OBJPROP_TEXT,DoubleToString(ENVdeviation));
   ObjectSetInteger(0,"PIPSetEditENVdeviation",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditENVdeviation",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetENVprice")<0)ObjectCreate(0,"PIPSetENVprice",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetENVprice",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetENVprice",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetENVprice",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetENVprice",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetENVprice",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetENVprice",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetENVprice",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetENVprice",OBJPROP_TEXT,"price");
   ObjectSetInteger(0,"PIPSetENVprice",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetENVprice",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditENVprice")<0)ObjectCreate(0,"PIPSetEditENVprice",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditENVprice",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditENVprice",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditENVprice",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditENVprice",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetEditENVprice",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditENVprice",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditENVprice",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditENVprice",OBJPROP_TEXT,(string)ENVprice);
   ObjectSetInteger(0,"PIPSetEditENVprice",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditENVprice",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetENVmethod")<0)ObjectCreate(0,"PIPSetENVmethod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetENVmethod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetENVmethod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetENVmethod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetENVmethod",OBJPROP_YDISTANCE,70);
   ObjectSetInteger(0,"PIPSetENVmethod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetENVmethod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetENVmethod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetENVmethod",OBJPROP_TEXT,"method");
   ObjectSetInteger(0,"PIPSetENVmethod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetENVmethod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditENVmethod")<0)ObjectCreate(0,"PIPSetEditENVmethod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditENVmethod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditENVmethod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditENVmethod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditENVmethod",OBJPROP_YDISTANCE,70);
   ObjectSetInteger(0,"PIPSetEditENVmethod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditENVmethod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditENVmethod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditENVmethod",OBJPROP_TEXT,(string)ENVmethod);
   ObjectSetInteger(0,"PIPSetEditENVmethod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditENVmethod",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPSetEditDC()
  {
   if(ObjectFind(0,"PIPSetDCPeriod")<0)ObjectCreate(0,"PIPSetDCPeriod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetDCPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetDCPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetDCPeriod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetDCPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetDCPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetDCPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetDCPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetDCPeriod",OBJPROP_TEXT,"Period");
   ObjectSetInteger(0,"PIPSetDCPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetDCPeriod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditDCPeriod")<0)ObjectCreate(0,"PIPSetEditDCPeriod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditDCPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditDCPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditDCPeriod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditDCPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetEditDCPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditDCPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditDCPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditDCPeriod",OBJPROP_TEXT,(string)DCPeriod);
   ObjectSetInteger(0,"PIPSetEditDCPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditDCPeriod",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetDCExtremes")<0)ObjectCreate(0,"PIPSetDCExtremes",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetDCExtremes",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetDCExtremes",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetDCExtremes",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetDCExtremes",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetDCExtremes",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetDCExtremes",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetDCExtremes",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetDCExtremes",OBJPROP_TEXT,"Extremes");
   ObjectSetInteger(0,"PIPSetDCExtremes",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetDCExtremes",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditDCExtremes")<0)ObjectCreate(0,"PIPSetEditDCExtremes",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditDCExtremes",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditDCExtremes",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditDCExtremes",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditDCExtremes",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetEditDCExtremes",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditDCExtremes",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditDCExtremes",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditDCExtremes",OBJPROP_TEXT,(string)DCExtremes);
   ObjectSetInteger(0,"PIPSetEditDCExtremes",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditDCExtremes",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetDCMargins")<0)ObjectCreate(0,"PIPSetDCMargins",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetDCMargins",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetDCMargins",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetDCMargins",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetDCMargins",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetDCMargins",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetDCMargins",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetDCMargins",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetDCMargins",OBJPROP_TEXT,"Margins");
   ObjectSetInteger(0,"PIPSetDCMargins",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetDCMargins",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditDCMargins")<0)ObjectCreate(0,"PIPSetEditDCMargins",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditDCMargins",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditDCMargins",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditDCMargins",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditDCMargins",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetEditDCMargins",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditDCMargins",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditDCMargins",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditDCMargins",OBJPROP_TEXT,(string)DCMargins);
   ObjectSetInteger(0,"PIPSetEditDCMargins",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditDCMargins",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPSetEditSC()
  {
   if(ObjectFind(0,"PIPSetSCPeriod")<0)ObjectCreate(0,"PIPSetSCPeriod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetSCPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetSCPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetSCPeriod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetSCPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetSCPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetSCPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetSCPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetSCPeriod",OBJPROP_TEXT,"Period");
   ObjectSetInteger(0,"PIPSetSCPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetSCPeriod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditSCPeriod")<0)ObjectCreate(0,"PIPSetEditSCPeriod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditSCPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditSCPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditSCPeriod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditSCPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetEditSCPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditSCPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditSCPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditSCPeriod",OBJPROP_TEXT,(string)SCPeriod);
   ObjectSetInteger(0,"PIPSetEditSCPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditSCPeriod",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetSCSilvCh")<0)ObjectCreate(0,"PIPSetSCSilvCh",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetSCSilvCh",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetSCSilvCh",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetSCSilvCh",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetSCSilvCh",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetSCSilvCh",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetSCSilvCh",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetSCSilvCh",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetSCSilvCh",OBJPROP_TEXT,"SilvCh");
   ObjectSetInteger(0,"PIPSetSCSilvCh",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetSCSilvCh",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditSCSilvCh")<0)ObjectCreate(0,"PIPSetEditSCSilvCh",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditSCSilvCh",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditSCSilvCh",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditSCSilvCh",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditSCSilvCh",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetEditSCSilvCh",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditSCSilvCh",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditSCSilvCh",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditSCSilvCh",OBJPROP_TEXT,DoubleToString(SCSilvCh));
   ObjectSetInteger(0,"PIPSetEditSCSilvCh",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditSCSilvCh",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetSCSkyCh")<0)ObjectCreate(0,"PIPSetSCSkyCh",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetSCSkyCh",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetSCSkyCh",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetSCSkyCh",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetSCSkyCh",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetSCSkyCh",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetSCSkyCh",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetSCSkyCh",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetSCSkyCh",OBJPROP_TEXT,"SkyCh");
   ObjectSetInteger(0,"PIPSetSCSkyCh",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetSCSkyCh",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditSCSkyCh")<0)ObjectCreate(0,"PIPSetEditSCSkyCh",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditSCSkyCh",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditSCSkyCh",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditSCSkyCh",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditSCSkyCh",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetEditSCSkyCh",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditSCSkyCh",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditSCSkyCh",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditSCSkyCh",OBJPROP_TEXT,DoubleToString(SCSkyCh));
   ObjectSetInteger(0,"PIPSetEditSCSkyCh",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditSCSkyCh",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetSCFutCh")<0)ObjectCreate(0,"PIPSetSCFutCh",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetSCFutCh",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetSCFutCh",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetSCFutCh",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetSCFutCh",OBJPROP_YDISTANCE,70);
   ObjectSetInteger(0,"PIPSetSCFutCh",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetSCFutCh",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetSCFutCh",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetSCFutCh",OBJPROP_TEXT,"FutCh");
   ObjectSetInteger(0,"PIPSetSCFutCh",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetSCFutCh",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditSCFutCh")<0)ObjectCreate(0,"PIPSetEditSCFutCh",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditSCFutCh",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditSCFutCh",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditSCFutCh",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditSCFutCh",OBJPROP_YDISTANCE,70);
   ObjectSetInteger(0,"PIPSetEditSCFutCh",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditSCFutCh",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditSCFutCh",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditSCFutCh",OBJPROP_TEXT,DoubleToString(SCFutCh));
   ObjectSetInteger(0,"PIPSetEditSCFutCh",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditSCFutCh",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPSetEditNRTR()
  {
   if(ObjectFind(0,"PIPSetNRTRPeriod")<0)ObjectCreate(0,"PIPSetNRTRPeriod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetNRTRPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetNRTRPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetNRTRPeriod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetNRTRPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetNRTRPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetNRTRPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetNRTRPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetNRTRPeriod",OBJPROP_TEXT,"Period");
   ObjectSetInteger(0,"PIPSetNRTRPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetNRTRPeriod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditNRTRPeriod")<0)ObjectCreate(0,"PIPSetEditNRTRPeriod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditNRTRPeriod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditNRTRPeriod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditNRTRPeriod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditNRTRPeriod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetEditNRTRPeriod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditNRTRPeriod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditNRTRPeriod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditNRTRPeriod",OBJPROP_TEXT,(string)NRTRPeriod);
   ObjectSetInteger(0,"PIPSetEditNRTRPeriod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditNRTRPeriod",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetNRTRK")<0)ObjectCreate(0,"PIPSetNRTRK",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetNRTRK",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetNRTRK",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetNRTRK",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetNRTRK",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetNRTRK",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetNRTRK",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetNRTRK",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetNRTRK",OBJPROP_TEXT,"K");
   ObjectSetInteger(0,"PIPSetNRTRK",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetNRTRK",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditNRTRK")<0)ObjectCreate(0,"PIPSetEditNRTRK",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditNRTRK",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditNRTRK",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditNRTRK",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditNRTRK",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetEditNRTRK",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditNRTRK",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditNRTRK",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditNRTRK",OBJPROP_TEXT,DoubleToString(NRTRK));
   ObjectSetInteger(0,"PIPSetEditNRTRK",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditNRTRK",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPSetEditAL()
  {
   if(ObjectFind(0,"PIPSetALjawperiod")<0)ObjectCreate(0,"PIPSetALjawperiod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetALjawperiod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetALjawperiod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetALjawperiod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetALjawperiod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetALjawperiod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetALjawperiod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetALjawperiod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetALjawperiod",OBJPROP_TEXT,"jaw period");
   ObjectSetInteger(0,"PIPSetALjawperiod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetALjawperiod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditALjawperiod")<0)ObjectCreate(0,"PIPSetEditALjawperiod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditALjawperiod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditALjawperiod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditALjawperiod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditALjawperiod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetEditALjawperiod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditALjawperiod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditALjawperiod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditALjawperiod",OBJPROP_TEXT,(string)ALjawperiod);
   ObjectSetInteger(0,"PIPSetEditALjawperiod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditALjawperiod",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetALteethperiod")<0)ObjectCreate(0,"PIPSetALteethperiod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetALteethperiod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetALteethperiod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetALteethperiod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetALteethperiod",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetALteethperiod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetALteethperiod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetALteethperiod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetALteethperiod",OBJPROP_TEXT,"teeth period");
   ObjectSetInteger(0,"PIPSetALteethperiod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetALteethperiod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditALteethperiod")<0)ObjectCreate(0,"PIPSetEditALteethperiod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditALteethperiod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditALteethperiod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditALteethperiod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditALteethperiod",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetEditALteethperiod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditALteethperiod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditALteethperiod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditALteethperiod",OBJPROP_TEXT,(string)ALteethperiod);
   ObjectSetInteger(0,"PIPSetEditALteethperiod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditALteethperiod",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetALlipsperiod")<0)ObjectCreate(0,"PIPSetALlipsperiod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetALlipsperiod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetALlipsperiod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetALlipsperiod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetALlipsperiod",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetALlipsperiod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetALlipsperiod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetALlipsperiod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetALlipsperiod",OBJPROP_TEXT,"lips period");
   ObjectSetInteger(0,"PIPSetALlipsperiod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetALlipsperiod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditALlipsperiod")<0)ObjectCreate(0,"PIPSetEditALlipsperiod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditALlipsperiod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditALlipsperiod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditALlipsperiod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditALlipsperiod",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetEditALlipsperiod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditALlipsperiod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditALlipsperiod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditALlipsperiod",OBJPROP_TEXT,(string)ALlipsperiod);
   ObjectSetInteger(0,"PIPSetEditALlipsperiod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditALlipsperiod",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetALmethod")<0)ObjectCreate(0,"PIPSetALmethod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetALmethod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetALmethod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetALmethod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetALmethod",OBJPROP_YDISTANCE,70);
   ObjectSetInteger(0,"PIPSetALmethod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetALmethod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetALmethod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetALmethod",OBJPROP_TEXT,"Method");
   ObjectSetInteger(0,"PIPSetALmethod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetALmethod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditALmethod")<0)ObjectCreate(0,"PIPSetEditALmethod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditALmethod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditALmethod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditALmethod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditALmethod",OBJPROP_YDISTANCE,70);
   ObjectSetInteger(0,"PIPSetEditALmethod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditALmethod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditALmethod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditALmethod",OBJPROP_TEXT,(string)ALmethod);
   ObjectSetInteger(0,"PIPSetEditALmethod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditALmethod",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetALprice")<0)ObjectCreate(0,"PIPSetALprice",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetALprice",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetALprice",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetALprice",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetALprice",OBJPROP_YDISTANCE,90);
   ObjectSetInteger(0,"PIPSetALprice",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetALprice",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetALprice",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetALprice",OBJPROP_TEXT,"Price");
   ObjectSetInteger(0,"PIPSetALprice",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetALprice",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditALprice")<0)ObjectCreate(0,"PIPSetEditALprice",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditALprice",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditALprice",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditALprice",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditALprice",OBJPROP_YDISTANCE,90);
   ObjectSetInteger(0,"PIPSetEditALprice",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditALprice",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditALprice",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditALprice",OBJPROP_TEXT,(string)ALprice);
   ObjectSetInteger(0,"PIPSetEditALprice",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditALprice",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPSetEditAMA()
  {
   if(ObjectFind(0,"PIPSetAMAperiod")<0)ObjectCreate(0,"PIPSetAMAperiod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetAMAperiod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetAMAperiod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetAMAperiod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetAMAperiod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetAMAperiod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetAMAperiod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetAMAperiod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetAMAperiod",OBJPROP_TEXT,"Period");
   ObjectSetInteger(0,"PIPSetAMAperiod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetAMAperiod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditAMAperiod")<0)ObjectCreate(0,"PIPSetEditAMAperiod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditAMAperiod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditAMAperiod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditAMAperiod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditAMAperiod",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetEditAMAperiod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditAMAperiod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditAMAperiod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditAMAperiod",OBJPROP_TEXT,(string)AMAperiod);
   ObjectSetInteger(0,"PIPSetEditAMAperiod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditAMAperiod",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetAMAfastperiod")<0)ObjectCreate(0,"PIPSetAMAfastperiod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetAMAfastperiod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetAMAfastperiod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetAMAfastperiod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetAMAfastperiod",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetAMAfastperiod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetAMAfastperiod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetAMAfastperiod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetAMAfastperiod",OBJPROP_TEXT,"fast EMA");
   ObjectSetInteger(0,"PIPSetAMAfastperiod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetAMAfastperiod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditAMAfastperiod")<0)ObjectCreate(0,"PIPSetEditAMAfastperiod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditAMAfastperiod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditAMAfastperiod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditAMAfastperiod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditAMAfastperiod",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetEditAMAfastperiod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditAMAfastperiod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditAMAfastperiod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditAMAfastperiod",OBJPROP_TEXT,(string)AMAfastperiod);
   ObjectSetInteger(0,"PIPSetEditAMAfastperiod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditAMAfastperiod",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetAMAslowperiod")<0)ObjectCreate(0,"PIPSetAMAslowperiod",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetAMAslowperiod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetAMAslowperiod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetAMAslowperiod",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetAMAslowperiod",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetAMAslowperiod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetAMAslowperiod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetAMAslowperiod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetAMAslowperiod",OBJPROP_TEXT,"slow EMA");
   ObjectSetInteger(0,"PIPSetAMAslowperiod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetAMAslowperiod",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditAMAslowperiod")<0)ObjectCreate(0,"PIPSetEditAMAslowperiod",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditAMAslowperiod",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditAMAslowperiod",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditAMAslowperiod",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditAMAslowperiod",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetEditAMAslowperiod",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditAMAslowperiod",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditAMAslowperiod",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditAMAslowperiod",OBJPROP_TEXT,(string)AMAslowperiod);
   ObjectSetInteger(0,"PIPSetEditAMAslowperiod",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditAMAslowperiod",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetAMAprice")<0)ObjectCreate(0,"PIPSetAMAprice",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetAMAprice",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetAMAprice",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetAMAprice",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetAMAprice",OBJPROP_YDISTANCE,70);
   ObjectSetInteger(0,"PIPSetAMAprice",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetAMAprice",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetAMAprice",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetAMAprice",OBJPROP_TEXT,"Price");
   ObjectSetInteger(0,"PIPSetAMAprice",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetAMAprice",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditAMAprice")<0)ObjectCreate(0,"PIPSetEditAMAprice",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditAMAprice",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditAMAprice",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditAMAprice",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditAMAprice",OBJPROP_YDISTANCE,70);
   ObjectSetInteger(0,"PIPSetEditAMAprice",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditAMAprice",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditAMAprice",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditAMAprice",OBJPROP_TEXT,(string)AMAprice);
   ObjectSetInteger(0,"PIPSetEditAMAprice",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditAMAprice",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PIPSetEditIKH()
  {
   if(ObjectFind(0,"PIPSetIKHtenkansen")<0)ObjectCreate(0,"PIPSetIKHtenkansen",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetIKHtenkansen",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetIKHtenkansen",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetIKHtenkansen",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetIKHtenkansen",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetIKHtenkansen",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetIKHtenkansen",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetIKHtenkansen",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetIKHtenkansen",OBJPROP_TEXT,"tenkan-sen");
   ObjectSetInteger(0,"PIPSetIKHtenkansen",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetIKHtenkansen",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditIKHtenkansen")<0)ObjectCreate(0,"PIPSetEditIKHtenkansen",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditIKHtenkansen",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditIKHtenkansen",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditIKHtenkansen",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditIKHtenkansen",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"PIPSetEditIKHtenkansen",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditIKHtenkansen",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditIKHtenkansen",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditIKHtenkansen",OBJPROP_TEXT,(string)IKHtenkansen);
   ObjectSetInteger(0,"PIPSetEditIKHtenkansen",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditIKHtenkansen",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetIKHkijunsen")<0)ObjectCreate(0,"PIPSetIKHkijunsen",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetIKHkijunsen",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetIKHkijunsen",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetIKHkijunsen",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetIKHkijunsen",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetIKHkijunsen",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetIKHkijunsen",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetIKHkijunsen",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetIKHkijunsen",OBJPROP_TEXT,"kijun-sen");
   ObjectSetInteger(0,"PIPSetIKHkijunsen",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetIKHkijunsen",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditIKHkijunsen")<0)ObjectCreate(0,"PIPSetEditIKHkijunsen",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditIKHkijunsen",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditIKHkijunsen",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditIKHkijunsen",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditIKHkijunsen",OBJPROP_YDISTANCE,30);
   ObjectSetInteger(0,"PIPSetEditIKHkijunsen",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditIKHkijunsen",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditIKHkijunsen",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditIKHkijunsen",OBJPROP_TEXT,(string)IKHkijunsen);
   ObjectSetInteger(0,"PIPSetEditIKHkijunsen",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditIKHkijunsen",OBJPROP_SELECTABLE,0);

   if(ObjectFind(0,"PIPSetIKHsenkouspanb")<0)ObjectCreate(0,"PIPSetIKHsenkouspanb",OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetIKHsenkouspanb",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetIKHsenkouspanb",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetIKHsenkouspanb",OBJPROP_XDISTANCE,220);
   ObjectSetInteger(0,"PIPSetIKHsenkouspanb",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetIKHsenkouspanb",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetIKHsenkouspanb",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetIKHsenkouspanb",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetIKHsenkouspanb",OBJPROP_TEXT,"senkou span b");
   ObjectSetInteger(0,"PIPSetIKHsenkouspanb",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetIKHsenkouspanb",OBJPROP_SELECTABLE,1);

   if(ObjectFind(0,"PIPSetEditIKHsenkouspanb")<0)ObjectCreate(0,"PIPSetEditIKHsenkouspanb",OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,"PIPSetEditIKHsenkouspanb",OBJPROP_COLOR,TextColor);
   ObjectSetInteger(0,"PIPSetEditIKHsenkouspanb",OBJPROP_BGCOLOR,BGColor);
   ObjectSetInteger(0,"PIPSetEditIKHsenkouspanb",OBJPROP_XDISTANCE,320);
   ObjectSetInteger(0,"PIPSetEditIKHsenkouspanb",OBJPROP_YDISTANCE,50);
   ObjectSetInteger(0,"PIPSetEditIKHsenkouspanb",OBJPROP_XSIZE,100);
   ObjectSetInteger(0,"PIPSetEditIKHsenkouspanb",OBJPROP_YSIZE,18);
   ObjectSetString(0,"PIPSetEditIKHsenkouspanb",OBJPROP_FONT,"Arial");
   ObjectSetString(0,"PIPSetEditIKHsenkouspanb",OBJPROP_TEXT,(string)IKHsenkouspanb);
   ObjectSetInteger(0,"PIPSetEditIKHsenkouspanb",OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,"PIPSetEditIKHsenkouspanb",OBJPROP_SELECTABLE,0);
  }
//+------------------------------------------------------------------+

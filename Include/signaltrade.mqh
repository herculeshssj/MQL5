//+------------------------------------------------------------------+
//|                                                  SignalTrade.mqh |
//|                                                   Sergey Greecie |
//|                                               sergey1294@list.ru |
//+------------------------------------------------------------------+
#property copyright "Sergey Greecie"
#property link      "sergey1294@list.ru"
//+------------------------------------------------------------------+
//| Declare variables for storing the handles of indicators          |
//+------------------------------------------------------------------+
int h_ma1   = INVALID_HANDLE;
int h_ma2   = INVALID_HANDLE;
int h_macd  = INVALID_HANDLE;
int h_pc    = INVALID_HANDLE;
int h_acadx = INVALID_HANDLE;
int h_stoh  = INVALID_HANDLE;
int h_rsi   = INVALID_HANDLE;
int h_cci   = INVALID_HANDLE;
int h_wpr   = INVALID_HANDLE;
int h_bb    = INVALID_HANDLE;
int h_sdc   = INVALID_HANDLE;
int h_env   = INVALID_HANDLE;
int h_dc    = INVALID_HANDLE;
int h_sc    = INVALID_HANDLE;
int h_gc    = INVALID_HANDLE;
int h_nrtr  = INVALID_HANDLE;
int h_al    = INVALID_HANDLE;
int h_ama   = INVALID_HANDLE;
int h_ao    = INVALID_HANDLE;
int h_ich   = INVALID_HANDLE;
//+------------------------------------------------------------------+
//| Declare necessary arrays for storing data of indicators          |
//+------------------------------------------------------------------+
double ma1_buffer[];
double ma2_buffer[];
double macd1_buffer[];
double macd2_buffer[];
double pc1_buffer[];
double pc2_buffer[];
double acadx1_buffer[];
double acadx2_buffer[];
double stoh_buffer[];
double rsi_buffer[];
double cci_buffer[];
double wpr_buffer[];
double bb1_buffer[];
double bb2_buffer[];
double sdc1_buffer[];
double sdc2_buffer[];
double env1_buffer[];
double env2_buffer[];
double dc1_buffer[];
double dc2_buffer[];
double sc1_buffer[];
double sc2_buffer[];
double gc1_buffer[];
double gc2_buffer[];
double nrtr1_buffer[];
double nrtr2_buffer[];
double al1_buffer[];
double al2_buffer[];
double al3_buffer[];
double ama_buffer[];
double ao_buffer[];
double ich1_buffer[];
double ich2_buffer[];
double Close[];
//+------------------------------------------------------------------+
//| functions for forming signals                                    |
//|  0 - no signal                                                   |
//|  1 - signal to buy                                               |
//| -1 - signal to sell                                              |
//+------------------------------------------------------------------+
int TradeSignal_01()
  {
//--- zero means absence of a signal
   int sig=0;

//--- check handles of indicators
   if(h_ma1==INVALID_HANDLE)//--- if the handle is invalid
     {
      //--- create it again                                                      
      h_ma1=iMA(Symbol(),Period(),8,0,MODE_SMA,PRICE_CLOSE);
      //--- exit from the function
      return(0);
     }
   else //--- if the handle is valid 
     {
      //--- copy the values of indicator to the array
      if(CopyBuffer(h_ma1,0,0,3,ma1_buffer)<3) //--- and if the data is less than necessary
         //--- exit from the function
         return(0);
      //--- set indexing in the array as in a timeseries                                   
      if(!ArraySetAsSeries(ma1_buffer,true))
         //--- in case of an indexation error exit from the function
         return(0);
     }

   if(h_ma2==INVALID_HANDLE)//--- if the handle is invalid
     {
      //--- create it again                                                      
      h_ma2=iMA(Symbol(),Period(),16,0,MODE_SMA,PRICE_CLOSE);
      //--- exit from the function
      return(0);
     }
   else //--- if the handle is valid 
     {
      //--- copy the values of indicator to the array
      if(CopyBuffer(h_ma2,0,0,2,ma2_buffer)<2) //--- and if the data is less than necessary
         //--- exit from the function
         return(0);
      //--- set indexing in the array as in a timeseries                                   
      if(!ArraySetAsSeries(ma1_buffer,true))
         //--- in case of an indexation error exit from the function
         return(0);
     }

//--- perform checking of the condition and set the value for sig
   if(ma1_buffer[2]<ma2_buffer[1] && ma1_buffer[1]>ma2_buffer[1])
      sig=1;
   else if(ma1_buffer[2]>ma2_buffer[1] && ma1_buffer[1]<ma2_buffer[1])
      sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+
int TradeSignal_02()
  {
   int sig=0;

   if(h_macd==INVALID_HANDLE)
     {
      h_macd=iMACD(Symbol(),Period(),12,26,9,PRICE_CLOSE);
      return(0);
     }
   else
     {
      if(CopyBuffer(h_macd,0,0,2,macd1_buffer)<2)
         return(0);
      if(CopyBuffer(h_macd,1,0,3,macd2_buffer)<3)
         return(0);
      if(!ArraySetAsSeries(macd1_buffer,true))
         return(0);
      if(!ArraySetAsSeries(macd2_buffer,true))
         return(0);
     }

//--- perform checking of the condition and set the value for sig
   if(macd2_buffer[2]>macd1_buffer[1] && macd2_buffer[1]<macd1_buffer[1])
      sig=1;
   else if(macd2_buffer[2]<macd1_buffer[1] && macd2_buffer[1]>macd1_buffer[1])
      sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+
int TradeSignal_03()
  {
   int sig=0;

   if(h_pc==INVALID_HANDLE)
     {
      h_pc=iCustom(Symbol(),Period(),"Price Channel",22);
      return(0);
     }
   else
     {
      if(CopyBuffer(h_pc,0,0,3,pc1_buffer)<3)
         return(0);
      if(CopyBuffer(h_pc,1,0,3,pc2_buffer)<3)
         return(0);
      if(CopyClose(Symbol(),Period(),0,2,Close)<2)
         return(0);
      if(!ArraySetAsSeries(pc1_buffer,true))
         return(0);
      if(!ArraySetAsSeries(pc2_buffer,true))
         return(0);
      if(!ArraySetAsSeries(Close,true))
         return(0);
     }
//--- perform checking of the condition and set the value for sig
   if(Close[1]>pc1_buffer[2])
      sig=1;
   else if(Close[1]<pc2_buffer[2])
      sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+
int TradeSignal_04()
  {
   int sig=0;

   if(h_acadx==INVALID_HANDLE)
     {
      h_acadx=iCustom(Symbol(),Period(),"AdaptiveChannelADX",14);
      return(0);
     }
   else
     {
      if(CopyBuffer(h_acadx,0,0,2,acadx1_buffer)<2)
         return(0);
      if(CopyBuffer(h_acadx,1,0,2,acadx2_buffer)<2)
         return(0);
      if(CopyClose(Symbol(),Period(),0,2,Close)<2)
         return(0);
      if(!ArraySetAsSeries(acadx1_buffer,true))
         return(0);
      if(!ArraySetAsSeries(acadx2_buffer,true))
         return(0);
      if(!ArraySetAsSeries(Close,true))
         return(0);
     }
//--- perform checking of the condition and set the value for sig
   if(Close[1]>acadx1_buffer[1])
      sig=1;
   else if(Close[1]<acadx2_buffer[1])
      sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+
int TradeSignal_05()
  {
   int sig=0;

   if(h_stoh==INVALID_HANDLE)
     {
      h_stoh=iStochastic(Symbol(),Period(),5,3,3,MODE_SMA,STO_LOWHIGH);
      return(0);
     }
   else
     {
      if(CopyBuffer(h_stoh,0,0,3,stoh_buffer)<3)
         return(0);

      if(!ArraySetAsSeries(stoh_buffer,true))
         return(0);
     }
//--- perform checking of the condition and set the value for sig
   if(stoh_buffer[2]<20 && stoh_buffer[1]>20)
      sig=1;
   else if(stoh_buffer[2]>80 && stoh_buffer[1]<80)
      sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+
int TradeSignal_06()
  {
   int sig=0;

   if(h_rsi==INVALID_HANDLE)
     {
      h_rsi=iRSI(Symbol(),Period(),14,PRICE_CLOSE);
      return(0);
     }
   else
     {
      if(CopyBuffer(h_rsi,0,0,3,rsi_buffer)<3)
         return(0);

      if(!ArraySetAsSeries(rsi_buffer,true))
         return(0);
     }
//--- perform checking of the condition and set the value for sig
   if(rsi_buffer[2]<30 && rsi_buffer[1]>30)
      sig=1;
   else if(rsi_buffer[2]>70 && rsi_buffer[1]<70)
      sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+
int TradeSignal_07()
  {
   int sig=0;

   if(h_cci==INVALID_HANDLE)
     {
      h_cci=iCCI(Symbol(),Period(),14,PRICE_TYPICAL);
      return(0);
     }
   else
     {
      if(CopyBuffer(h_cci,0,0,3,cci_buffer)<3)
         return(0);

      if(!ArraySetAsSeries(cci_buffer,true))
         return(0);
     }
//--- perform checking of the condition and set the value for sig
   if(cci_buffer[2]<-100 && cci_buffer[1]>-100)
      sig=1;
   else if(cci_buffer[2]>100 && cci_buffer[1]<100)
      sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+
int TradeSignal_08()
  {
   int sig=0;

   if(h_wpr==INVALID_HANDLE)
     {
      h_wpr=iWPR(Symbol(),Period(),14);
      return(0);
     }
   else
     {
      if(CopyBuffer(h_wpr,0,0,3,wpr_buffer)<3)
         return(0);

      if(!ArraySetAsSeries(wpr_buffer,true))
         return(0);
     }
//--- perform checking of the condition and set the value for sig
   if(wpr_buffer[2]<-80 && wpr_buffer[1]>-80)
      sig=1;
   else if(wpr_buffer[2]>-20 && wpr_buffer[1]<-20)
      sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+
int TradeSignal_09()
  {
   int sig=0;

   if(h_bb==INVALID_HANDLE)
     {
      h_bb=iBands(Symbol(),Period(),20,0,2,PRICE_CLOSE);
      return(0);
     }
   else
     {
      if(CopyBuffer(h_bb,1,0,2,bb1_buffer)<2)
         return(0);
      if(CopyBuffer(h_bb,2,0,2,bb2_buffer)<2)
         return(0);
      if(CopyClose(Symbol(),Period(),0,3,Close)<3)
         return(0);
      if(!ArraySetAsSeries(bb1_buffer,true))
         return(0);
      if(!ArraySetAsSeries(bb2_buffer,true))
         return(0);
      if(!ArraySetAsSeries(Close,true))
         return(0);
     }
//--- perform checking of the condition and set the value for sig
   if(Close[2]<=bb2_buffer[1] && Close[1]>bb2_buffer[1])
      sig=1;
   else if(Close[2]>=bb1_buffer[1] && Close[1]<bb1_buffer[1])
                     sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+
int TradeSignal_10()
  {
   int sig=0;

   if(h_sdc==INVALID_HANDLE)
     {
      h_sdc=iCustom(Symbol(),Period(),"StandardDeviationChannel",14,MODE_SMA,PRICE_CLOSE,2.0);
      return(0);
     }
   else
     {
      if(CopyBuffer(h_sdc,0,0,2,sdc1_buffer)<2)
         return(0);
      if(CopyBuffer(h_sdc,1,0,2,sdc2_buffer)<2)
         return(0);
      if(CopyClose(Symbol(),Period(),0,3,Close)<3)
         return(0);
      if(!ArraySetAsSeries(sdc1_buffer,true))
         return(0);
      if(!ArraySetAsSeries(sdc2_buffer,true))
         return(0);
      if(!ArraySetAsSeries(Close,true))
         return(0);
     }
//--- perform checking of the condition and set the value for sig
   if(Close[2]<=sdc2_buffer[1] && Close[1]>sdc2_buffer[1])
      sig=1;
   else if(Close[2]>=sdc1_buffer[1] && Close[1]<sdc1_buffer[1])
                     sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+
int TradeSignal_11()
  {
   int sig=0;

   if(h_pc==INVALID_HANDLE)
     {
      h_pc=iCustom(Symbol(),Period(),"Price Channel",22);
      return(0);
     }
   else
     {
      if(CopyBuffer(h_pc,0,0,4,pc1_buffer)<4)
         return(0);
      if(CopyBuffer(h_pc,1,0,4,pc2_buffer)<4)
         return(0);
      if(CopyClose(Symbol(),Period(),0,3,Close)<3)
         return(0);
      if(!ArraySetAsSeries(pc1_buffer,true))
         return(0);
      if(!ArraySetAsSeries(pc2_buffer,true))
         return(0);
      if(!ArraySetAsSeries(Close,true))
         return(0);
     }
//--- perform checking of the condition and set the value for sig
   if(Close[1]>pc2_buffer[2] && Close[2]<=pc2_buffer[3])
      sig=1;
   else if(Close[1]<pc1_buffer[2] && Close[2]>=pc1_buffer[3])
                                               sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+
int TradeSignal_12()
  {
   int sig=0;

   if(h_env==INVALID_HANDLE)
     {
      h_env=iEnvelopes(Symbol(),Period(),28,0,MODE_SMA,PRICE_CLOSE,0.1);
      return(0);
     }
   else
     {
      if(CopyBuffer(h_env,0,0,2,env1_buffer)<2)
         return(0);
      if(CopyBuffer(h_env,1,0,2,env2_buffer)<2)
         return(0);
      if(CopyClose(Symbol(),Period(),0,3,Close)<3)
         return(0);
      if(!ArraySetAsSeries(env1_buffer,true))
         return(0);
      if(!ArraySetAsSeries(env2_buffer,true))
         return(0);
      if(!ArraySetAsSeries(Close,true))
         return(0);
     }
//--- perform checking of the condition and set the value for sig
   if(Close[2]<=env2_buffer[1] && Close[1]>env2_buffer[1])
      sig=1;
   else if(Close[2]>=env1_buffer[1] && Close[1]<env1_buffer[1])
                     sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+
int TradeSignal_13()
  {
   int sig=0;

   if(h_dc==INVALID_HANDLE)
     {
      h_dc=iCustom(Symbol(),Period(),"Donchian Channels",24,3,-2);
      return(0);
     }
   else
     {
      if(CopyBuffer(h_dc,0,0,3,dc1_buffer)<3)
         return(0);
      if(CopyBuffer(h_dc,1,0,3,dc2_buffer)<3)
         return(0);
      if(CopyClose(Symbol(),Period(),0,2,Close)<2)
         return(0);
      if(!ArraySetAsSeries(dc1_buffer,true))
         return(0);
      if(!ArraySetAsSeries(dc2_buffer,true))
         return(0);
      if(!ArraySetAsSeries(Close,true))
         return(0);
     }
//--- perform checking of the condition and set the value for sig
   if(Close[1]>dc1_buffer[2])
      sig=1;
   else if(Close[1]<dc2_buffer[2])
      sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+
int TradeSignal_14()
  {
   int sig=0;

   if(h_sc==INVALID_HANDLE)
     {
      h_sc=iCustom(Symbol(),Period(),"Silver-channels",26,38.2,23.6,0,61.8);
      return(0);
     }
   else
     {
      if(CopyBuffer(h_sc,0,0,2,sc1_buffer)<2)
         return(0);
      if(CopyBuffer(h_sc,1,0,2,sc2_buffer)<2)
         return(0);
      if(CopyClose(Symbol(),Period(),0,3,Close)<3)
         return(0);
      if(!ArraySetAsSeries(sc1_buffer,true))
         return(0);
      if(!ArraySetAsSeries(sc2_buffer,true))
         return(0);
      if(!ArraySetAsSeries(Close,true))
         return(0);
     }
//--- perform checking of the condition and set the value for sig
   if(Close[2]<sc1_buffer[1] && Close[1]>sc1_buffer[1])
      sig=1;
   else if(Close[2]>sc2_buffer[1] && Close[1]<sc2_buffer[1])
      sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+
int TradeSignal_15()
  {
   int sig=0;

   if(h_gc==INVALID_HANDLE)
     {
      h_gc=iCustom(Symbol(),Period(),"PriceChannelGalaher");
      return(0);
     }
   else
     {
      if(CopyBuffer(h_gc,0,0,3,gc1_buffer)<3)
         return(0);
      if(CopyBuffer(h_gc,1,0,3,gc2_buffer)<3)
         return(0);
      if(CopyClose(Symbol(),Period(),0,2,Close)<2)
         return(0);
      if(!ArraySetAsSeries(gc1_buffer,true))
         return(0);
      if(!ArraySetAsSeries(gc2_buffer,true))
         return(0);
      if(!ArraySetAsSeries(Close,true))
         return(0);
     }
//--- perform checking of the condition and set the value for sig
   if(Close[1]>gc1_buffer[2])
      sig=1;
   else if(Close[1]<gc2_buffer[2])
      sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+
int TradeSignal_16()
  {
   int sig=0;

   if(h_nrtr==INVALID_HANDLE)
     {
      h_nrtr=iCustom(Symbol(),Period(),"NRTR",40,2.0);
      return(0);
     }
   else
     {
      if(CopyBuffer(h_nrtr,0,0,2,nrtr1_buffer)<2)
         return(0);
      if(CopyBuffer(h_nrtr,1,0,2,nrtr2_buffer)<2)
         return(0);
      if(!ArraySetAsSeries(nrtr1_buffer,true))
         return(0);
      if(!ArraySetAsSeries(nrtr2_buffer,true))
         return(0);
     }
//--- perform checking of the condition and set the value for sig
   if(nrtr1_buffer[1]>0)
      sig=1;
   else if(nrtr2_buffer[1]>0)
      sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+
int TradeSignal_17()
  {
   int sig=0;

   if(h_al==INVALID_HANDLE)
     {
      h_al=iAlligator(Symbol(),Period(),13,0,8,0,5,0,MODE_SMMA,PRICE_MEDIAN);
      return(0);
     }
   else
     {
      if(CopyBuffer(h_al,0,0,2,al1_buffer)<2)
         return(0);
      if(CopyBuffer(h_al,1,0,2,al2_buffer)<2)
         return(0);
      if(CopyBuffer(h_al,2,0,2,al3_buffer)<2)
         return(0);
      if(!ArraySetAsSeries(al1_buffer,true))
         return(0);
      if(!ArraySetAsSeries(al2_buffer,true))
         return(0);
      if(!ArraySetAsSeries(al3_buffer,true))
         return(0);
     }
//--- perform checking of the condition and set the value for sig
   if(al3_buffer[1]>al2_buffer[1] && al2_buffer[1]>al1_buffer[1])
      sig=1;
   else if(al3_buffer[1]<al2_buffer[1] && al2_buffer[1]<al1_buffer[1])
      sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+
int TradeSignal_18()
  {
   int sig=0;

   if(h_ama==INVALID_HANDLE)
     {
      h_ama=iAMA(Symbol(),Period(),9,2,30,0,PRICE_CLOSE);
      return(0);
     }
   else
     {
      if(CopyBuffer(h_ama,0,0,3,ama_buffer)<3)
         return(0);
      if(!ArraySetAsSeries(ama_buffer,true))
         return(0);
     }
//--- perform checking of the condition and set the value for sig
   if(ama_buffer[2]<ama_buffer[1])
      sig=1;
   else if(ama_buffer[2]>ama_buffer[1])
      sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+
int TradeSignal_19()
  {
   int sig=0;

   if(h_ao==INVALID_HANDLE)
     {
      h_ao=iAO(Symbol(),Period());
      return(0);
     }
   else
     {
      if(CopyBuffer(h_ao,1,0,20,ao_buffer)<20)
         return(0);
      if(!ArraySetAsSeries(ao_buffer,true))
         return(0);
     }
//--- perform checking of the condition and set the value for sig
   if(ao_buffer[1]==0)
      sig=1;
   else if(ao_buffer[1]==1)
      sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+
int TradeSignal_20()
  {
   int sig=0;

   if(h_ich==INVALID_HANDLE)
     {
      h_ich=iIchimoku(Symbol(),Period(),9,26,52);
      return(0);
     }
   else
     {
      if(CopyBuffer(h_ich,0,0,2,ich1_buffer)<2)
         return(0);
      if(CopyBuffer(h_ich,1,0,2,ich2_buffer)<2)
         return(0);
      if(!ArraySetAsSeries(ich1_buffer,true))
         return(0);
      if(!ArraySetAsSeries(ich2_buffer,true))
         return(0);
     }
//--- perform checking of the condition and set the value for sig
   if(ich1_buffer[1]>ich2_buffer[1])
      sig=1;
   else if(ich1_buffer[1]<ich2_buffer[1])
      sig=-1;
   else sig=0;

//--- return the trade signal
   return(sig);
  }
//+------------------------------------------------------------------+

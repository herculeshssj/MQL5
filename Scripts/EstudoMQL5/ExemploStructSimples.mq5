//+------------------------------------------------------------------+
//|                                         ExemploStructSimples.mq5 |
//|                              Copyright 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   //--- criamos a mesma estrutura como a construída por MqlTick 
   struct CustomMqlTick 
     { 
      datetime          time;          // Tempo da última atualização dos preços 
      double            bid;           // Preço atual Bid 
      double            ask;           // Preço atual Ask 
      double            last;          // Preço atual da última transação (Last) 
      ulong             volume;        // Volume para o preço atual Last 
      long              time_msc;      // Hora da última atualização dos preços em milissegundos 
      uint              flags;         // Sinalizadores de ticks      
     }; 
   //--- obtemos os valores do último ticks 
   MqlTick last_tick; 
   CustomMqlTick my_tick1, my_tick2; 
//--- tentamos colar e copiar os dados a partir do MqlTick no CustomMqlTick 
   if(SymbolInfoTick(Symbol(),last_tick)) 
     { 
      //--- copiar e colar estruturas simples não aparentadas é restrito 
      //1. my_tick1=last_tick;               // aqui o compilador gerará um erro 
      
      //--- combinar estruturas não aparentadas também é restrito 
      //2. my_tick1=(CustomMqlTick)last_tick;// aqui o compilador gerará um erro 
      
      //--- por isso copiamos e colamos os membros da estrutura elemento por elemento      
      my_tick1.time=last_tick.time; 
      my_tick1.bid=last_tick.bid; 
      my_tick1.ask=last_tick.ask; 
      my_tick1.volume=last_tick.volume; 
      my_tick1.time_msc=last_tick.time_msc; 
      my_tick1.flags=last_tick.flags; 
      
      //--- também é possível copiar e colar objetos da mesma estrutura CustomMqlTick 
      my_tick2=my_tick1; 
      
      //--- criamos uma matriz a partir de objetos da estrutura simples CustomMqlTick e registramos nela os valores 
      CustomMqlTick arr[2]; 
      arr[0]=my_tick1; 
      arr[1]=my_tick2; 
      ArrayPrint(arr); 
//--- exemplo de exibição de valores de matriz contendo objetos do tipo CustomMqlTick 
      /* 
                       [time]   [bid]   [ask]   [last] [volume]    [time_msc] [flags] 
      [0] 2017.05.29 15:04:37 1.11854 1.11863 +0.00000  1450000 1496070277157       2 
      [1] 2017.05.29 15:04:37 1.11854 1.11863 +0.00000  1450000 1496070277157       2            
      */ 
     } 
   else 
      Print("SymbolInfoTick() failed, error = ",GetLastError()); 

  }
//+------------------------------------------------------------------+

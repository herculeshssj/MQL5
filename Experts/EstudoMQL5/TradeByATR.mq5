//+------------------------------------------------------------------+
//|                                                   TradeByATR.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Exemplo de EA que opera segundo a direção da vela \"detonante\"" 
#property description "O corpo da vela \"detonante\" tem um tamanho maior que k*ATR" 
#property description "O parâmetro \"revers\" inverte a direção do sinal" 
#property description "Código disponível em https://www.mql5.com/pt/docs/event_handlers/ontick"

input double lots=0.1;        // volume em lotes 
input double kATR=3;          // tamanho da vela de sinal no ATR 
input int    ATRperiod=20;    // período do indicador ATR 
input int    holdbars=8;      // número de barras para manter a posição 
input int    slippage=10;     // derrapagem admissível 
input bool   revers=false;    // invertemos o sinal?  
input ulong  EXPERT_MAGIC=0;  // MagicNumber do EA 
//--- para armazenar o identificador do indicador ATR 
int atr_handle; 
//--- aqui vamos armazenar os últimos valores do ATR e o corpo da vela 
double last_atr,last_body; 
datetime lastbar_timeopen; 
double trade_lot; 

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- inicializamos as variáveis globais 
   last_atr=0; 
   last_body=0; 
//--- definimos o volume correto 
   double min_lot=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN); 
   trade_lot=lots>min_lot? lots:min_lot;    
//--- criamos o identificador do indicador ATR 
   atr_handle=iATR(_Symbol,_Period,ATRperiod); 
   if(atr_handle==INVALID_HANDLE) 
     { 
      PrintFormat("%s: não foi possível criar o iATR, código de erro %d",__FUNCTION__,GetLastError()); 
      return(INIT_FAILED); 
     } 
//--- inicialização bem-sucedida do EA 
   return(INIT_SUCCEEDED); 
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- relatamos o código de desligamento do EA 
   Print(__FILE__,": Código de motivo da desinicialização = ",reason); 
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- sinal de negociação 
   static int signal=0; // +1 significa um sinal de compra, -1 significa um sinal de venda 
//--- verificamos e fechamos as posições abertas antigas, abertas há mais de holdbars barras atrás 
   ClosePositionsByBars(holdbars,slippage,EXPERT_MAGIC); 
//--- verificamos o surgimento de uma nova barra 
   if(isNewBar()) 
     { 
      //--- verificamos a presença de sinal       
      signal=CheckSignal(); 
     } 
//--- se aberta uma posição de 'netting', ignoramos o sinal e esperamos até que ele feche 
   if(signal!=0 && PositionsTotal()>0 && (ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_NETTING) 
     { 
      signal=0; 
      return; // saímos do manipulador de eventos NewTick e não entramos no mercado até que apareça uma nova barra 
     } 
//--- para contas de cobertura ('hedge'), casa posição tem vida e fecha separadamente 
   if(signal!=0) 
     { 
      //--- sinal de compra 
      if(signal>0) 
        { 
         PrintFormat("%s: Existe um sinal de compra! Revers=%s",__FUNCTION__,string(revers)); 
         if(Buy(trade_lot,slippage,EXPERT_MAGIC)) 
            signal=0; 
        } 
      //--- sinal de venda 
      if(signal<0) 
        { 
         PrintFormat("%s: Existe um sinal de venda! Revers=%s",__FUNCTION__,string(revers)); 
         if(Sell(trade_lot,slippage,EXPERT_MAGIC)) 
            signal=0; 
        } 
     } 
//--- fim da função OnTick 
   
  }
//+------------------------------------------------------------------+ 
//| Verificando se á sinal de negociação                             | 
//+------------------------------------------------------------------+ 
int CheckSignal() 
  { 
//--- 0 significa que não há sinal 
   int res=0; 
//--- obtemos o valor do ATR na penúltima barra concluída (o índice da barra igual a 2) 
   double atr_value[1]; 
   if(CopyBuffer(atr_handle,0,2,1,atr_value)!=-1) 
     { 
      last_atr=atr_value[0]; 
      //--- recebemos os dados da última barra fechada numa matriz do tipo MqlRates 
      MqlRates bar[1]; 
      if(CopyRates(_Symbol,_Period,1,1,bar)!=-1) 
        { 
         //--- calculamos o tamanho do corpo da barra na última barra fechada 
         last_body=bar[0].close-bar[0].open; 
         //--- se o corpo da última barra (com índice 1) exceder o valor anterior do ATR (na barra com índice 2), o sinal de negociação é recebido 
         if(MathAbs(last_body)>kATR*last_atr) 
            res=last_body>0?1:-1; // para a leva altista um valor positivo 
        } 
      else 
         PrintFormat("%s: Não foi possível obter a última barra! Erro",__FUNCTION__,GetLastError()); 
     } 
   else 
      PrintFormat("%s: Não foi possível obter o valor do indicador ATR! Erro",__FUNCTION__,GetLastError()); 
//--- se estiver ativado o modo de negociação de reversão 
   res=revers?-res:res;  // se necessário, revertemos o sinal (em vez de 1, retornamos -1, e, em vez de -1, retornamos +1) 
//--- retornamos o valor do sinal de negociação 
   return (res); 
  } 
//+------------------------------------------------------------------+ 
//|  Retornando true quando aparece uma nova barra                   | 
//+------------------------------------------------------------------+ 
bool isNewBar(const bool print_log=true) 
  { 
   static datetime bartime=0; // armazenamos o tempo de abertura da barra atual 
//--- obtemos o tempo de abertura da barra zero 
   datetime currbar_time=iTime(_Symbol,_Period,0); 
//--- se o tempo de abertura mudar, é porque apareceu uma nova barra 
   if(bartime!=currbar_time) 
     { 
      bartime=currbar_time; 
      lastbar_timeopen=bartime; 
      //--- exibir no log informações sobre o tempo de abertura da nova barra       
      if(print_log && !(MQLInfoInteger(MQL_OPTIMIZATION)||MQLInfoInteger(MQL_TESTER))) 
        { 
         //--- exibimos uma mensagem sobre o tempo de abertura da nova barra 
         PrintFormat("%s: new bar on %s %s opened at %s",__FUNCTION__,_Symbol, 
                     StringSubstr(EnumToString(_Period),7), 
                     TimeToString(TimeCurrent(),TIME_SECONDS)); 
         //--- obtemos os dados do último tick 
         MqlTick last_tick; 
         if(!SymbolInfoTick(Symbol(),last_tick)) 
            Print("SymbolInfoTick() failed, error = ",GetLastError()); 
         //--- exibimos o tempo do último tick em segundos 
         PrintFormat("Last tick was at %s.%03d", 
                     TimeToString(last_tick.time,TIME_SECONDS),last_tick.time_msc%1000); 
        } 
      //--- temos uma nova barra 
      return (true); 
     } 
//--- não há nenhuma barra nova 
   return (false); 
  } 
//+------------------------------------------------------------------+ 
//| Comprando a mercado com o volume especificado                    | 
//+------------------------------------------------------------------+ 
bool Buy(double volume,ulong deviation=10,ulong  magicnumber=0) 
  { 
//--- compramos a mercado 
   return (MarketOrder(ORDER_TYPE_BUY,volume,deviation,magicnumber)); 
  } 
//+------------------------------------------------------------------+ 
//| Vendendo a mercado com o volume definido                          | 
//+------------------------------------------------------------------+ 
bool Sell(double volume,ulong deviation=10,ulong  magicnumber=0) 
  { 
//--- vendemos a mercado 
   return (MarketOrder(ORDER_TYPE_SELL,volume,deviation,magicnumber)); 
  } 
//+------------------------------------------------------------------+ 
//| Fechando posições segundo o tempo de retenção nas barras         | 
//+------------------------------------------------------------------+ 
void ClosePositionsByBars(int holdtimebars,ulong deviation=10,ulong  magicnumber=0) 
  { 
   int total=PositionsTotal(); // número de posições abertas    
//--- pesquisa detalhada de todas as posições abertas 
   for(int i=total-1; i>=0; i--) 
     { 
      //--- parâmetros da posição 
      ulong  position_ticket=PositionGetTicket(i);                                      // boleta da posição 
      string position_symbol=PositionGetString(POSITION_SYMBOL);                        // símbolo  
      ulong  magic=PositionGetInteger(POSITION_MAGIC);                                  // MagicNumber da posição 
      datetime position_open=(datetime)PositionGetInteger(POSITION_TIME);               // tempo de abertura da posição 
      int bars=iBarShift(_Symbol,PERIOD_CURRENT,position_open)+1;                       // há quantos barras atrás foi aberta a posição 
  
      //--- se a posição tem vivido por um longo tempo, e também o MagicNumber e o símbolo são os mesmos 
      if(bars>holdtimebars && magic==magicnumber && position_symbol==_Symbol) 
        { 
         int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);           // número de casas decimais 
         double volume=PositionGetDouble(POSITION_VOLUME);                              // volume da posição 
         ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); // tipo de posição 
         string str_type=StringSubstr(EnumToString(type),14); 
         StringToLower(str_type); // reduzimos o registro do texto para uma correta formatação da mensagem 
         PrintFormat("Fechamos a posição #%d %s %s %.2f", 
                     position_ticket,position_symbol,str_type,volume); 
         //--- definindo o tipo de ordem e de envio do pedido de negociação 
         if(type==POSITION_TYPE_BUY) 
            MarketOrder(ORDER_TYPE_SELL,volume,deviation,magicnumber,position_ticket); 
         else 
            MarketOrder(ORDER_TYPE_BUY,volume,deviation,magicnumber,position_ticket); 
        } 
     } 
  } 
//+------------------------------------------------------------------+ 
//| Preparando e enviando uma solicitação de negociação              | 
//+------------------------------------------------------------------+ 
bool MarketOrder(ENUM_ORDER_TYPE type,double volume,ulong slip,ulong magicnumber,ulong pos_ticket=0) 
  { 
//--- declaração e inicialização de estruturas 
   MqlTradeRequest request={0}; 
   MqlTradeResult  result={0}; 
   double price=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
   if(type==ORDER_TYPE_BUY) 
      price=SymbolInfoDouble(Symbol(),SYMBOL_ASK); 
//--- parâmetros da solicitação 
   request.action   =TRADE_ACTION_DEAL;                     // tipo de operação de negociação 
   request.position =pos_ticket;                            // boleta da posição, se fechada 
   request.symbol   =Symbol();                              // símbolo 
   request.volume   =volume;                                // volume  
   request.type     =type;                                  // tipo de ordem 
   request.price    =price;                                 // preço de transação 
   request.deviation=slip;                                  // desvio permitido em relação ao preço 
   request.magic    =magicnumber;                           // MagicNumber da ordem 
//--- envio do pedido 
   if(!OrderSend(request,result)) 
     { 
      //--- exibimos as informações sobre a falha 
      PrintFormat("OrderSend %s %s %.2f at %.5f error %d", 
                  request.symbol,EnumToString(type),volume,request.price,GetLastError()); 
      return (false); 
     } 
//--- relatamos sobre a operação bem-sucedida 
   PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order); 
   return (true); 
  }  
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                           EATudoOuNadaWINx19.mq5 |
//|                            Copyright ® 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|Changelog:                                                        |
//|v1.00 - Versão inicial baseado no EADunniganNRTRIniciante         |
//|v1.01 - Remoção de código desnecessário vindo do                  |
//|        EADunniganNRTRIniciante                                   |
//|v1.02 - Melhorias gerais no código do EA                          |
//|      - Definição do horário do pregão para operações daytrade    |
//|        (de 10h às 16h55m)                                        |
//|v1.03 - Usando o cruzamento de médias móveis para indicar sinais  |
//|        sinais de reversão.                                       |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property version   "1.03"
#property description "EA desenvolvido para operar unicamente com minicontrato de índice no BM&F Bovespa. O foco do EA é obter o máximo de lucro possível, e para isso ele fecha posições de compra/venda e abre nova posição inversa de acordo com os sinas do indicador de Dunnigan. Não existe stop loss/take profit nas ordens, portanto é ESSENCIAL ter margem financeira suficiente para suportar grandes perdas."

//--- Arquivos incluídos
#include <Trade\Trade.mqh>

//-- Enumerações
enum ENUM_METODO_CALCULO {
   HIGH_LOW = 0, // Máxima/Mínima
   OPEN_CLOSE = 1 // Abertura/Fechamento
};

//--- Parâmetros de entrada
input int      EA_Magic=38402;   // EA Magic Number
input double   Lot=1.0;          // Lots to Trade
input ENUM_METODO_CALCULO metodoCalculo = HIGH_LOW; // Método de cálculo

//--- Handles de indicadores
int dunniganHandle; // Handle para o indicador Dunnigan
int maCurtaHandle, maLongaHandle; // Handle para os indicadores MA

//-- Buffers de indicadores
double buyValue[], sellValue[]; // Armazena os sinais de compra e venda
double valorMACurta[]; // Armazena o valor da MA curta
double valorMALonga[]; // Armazena o valor da MA longa

// Variáveis estáticas
static bool mudouTendencia; // Sinaliza para o próximo tick que a tendência mudou
static double valorAnteriorMACurta; // Armazena o valor anterior da MA curta
static double valorAnteriorMALonga; // Armazena o valor anterior da MA longa

//--- Outras variáveis e objetos globais
CTrade cTrade; // Classe com métodos para negociação
ENUM_ACCOUNT_MARGIN_MODE marginMode; // Determina o tipo de margem da conta: netting ou hedging

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

   //--- Obtém o handle para o indicador Dunnigan
   dunniganHandle = iCustom(_Symbol, _Period, "herculeshssj\\IDunnigan.ex5", metodoCalculo);
   
   if (dunniganHandle < 0) {
      Alert("Error creating handles for indicators - error: ", GetLastError(), "!!!");
      return(INIT_FAILED);
   }
   
   //--- Obtém o handle para a média móvel curta
   maCurtaHandle = iMA(_Symbol, PERIOD_M2, 7, 0, MODE_SMA, PRICE_CLOSE);
   if (maCurtaHandle < 0) {
      Alert("Erro na criação do indicador média móvel curta: ", GetLastError(), "!!!");
      return(INIT_FAILED);
   }
   
   //--- Obtém o handle para a média móvel longa
   maLongaHandle = iMA(_Symbol, PERIOD_M2, 15, 0, MODE_SMA, PRICE_CLOSE);
   if (maLongaHandle < 0) {
      Alert("Erro na criação do indicador média móvel longa: ", GetLastError(), "!!!");
      return(INIT_FAILED);
   }
   
   //-- Identifica o tipo de margem da conta
   marginMode = (ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if (marginMode == ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) {
      Print("*** Este EA só trabalha com conta netting! Saindo... ***");
      return(INIT_FAILED);
   }
   
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   IndicatorRelease(dunniganHandle);
   IndicatorRelease(maCurtaHandle);
   IndicatorRelease(maLongaHandle);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   
   // Obtém a hora atual
   MqlDateTime horaAtual;
   TimeCurrent(horaAtual);

   if (CopyBuffer(maCurtaHandle, 0, 0, 1, valorMACurta) < 0
         || CopyBuffer(maLongaHandle, 0, 0, 1, valorMALonga) < 0) {
      
      Print("Erro ao copiar os dados do buffer dos indicadores MA - erro ", GetLastError());
   
   } else {
      
      //--- Verifica os valores anteriores das MAs para saber se houve mudança de tendência
      Print("Valor da MA curta: ", valorMACurta[0]);
      Print("Valor da MA longa: ", valorMALonga[0]);
      
      if (valorMACurta[0] > valorMALonga[0]) {
         Print("MA curta está acima da MA longa");
         //--- No tick anterior a MA curta estava acima da MA longa?
         if (valorAnteriorMACurta > valorAnteriorMALonga) {
            //--- Tendência não mudou, atualiza os valores
            valorAnteriorMACurta = valorMACurta[0];
            valorAnteriorMALonga = valorMALonga[0];
         } else {
            Print("***** TENDÊNCIA MUDOU!!!! *****");
            mudouTendencia = true;
            valorAnteriorMACurta = valorMACurta[0];
            valorAnteriorMALonga = valorMALonga[0];
         }
      } else {
         Print("MA curta está abaixo da MA longa");
         if (valorAnteriorMACurta < valorAnteriorMALonga) {
            //--- Tendência não mudou, atualiza os valores
            valorAnteriorMACurta = valorMACurta[0];
            valorAnteriorMALonga = valorMALonga[0];
         } else {
            Print("***** TENDÊNCIA MUDOU!!!! *****");
            mudouTendencia = true;
            valorAnteriorMACurta = valorMACurta[0];
            valorAnteriorMALonga = valorMALonga[0];
         }
      }
   }
   
   //--- No caso de mudança de tendência, todas as posições abertas são encerradas
   //--- para preservar o lucro obtido até o presente momento.
   if (mudouTendencia) {
      Print("***** Todas as posições abertas foram invertidas!!!!! *****");
      mudouTendencia = false;
      
      fecharPosicoesAbertas(POSITION_TYPE_BUY); // remover
      fecharPosicoesAbertas(POSITION_TYPE_SELL); // remover
   }
   
   // Verifica se tem uma nova barra
   if (temNovaBarra() && horarioPermiteOperar(horaAtual)) {
   
      //--- Define some MQL5 structs we will use for our trade
      MqlTick latestPrice; // To be used for getting recent/lastest price quotes
      
      //--- Get the last price quote using the MQL5 MqlTick struct
      if (!SymbolInfoTick(_Symbol, latestPrice))
      {
         Alert("Error getting the latest price quote - error: ", GetLastError(), "!!!");
         return;
      }
      
      //--- Copy the new values of our indicators to buffers (arrays) using the handle
      if (CopyBuffer(dunniganHandle, 0, 0, BarsCalculated(dunniganHandle), sellValue) < 0 
            || CopyBuffer(dunniganHandle, 1, 0, BarsCalculated(dunniganHandle), buyValue) < 0) {
         
         Alert("Erro ao copiar os valores do buffer do indicador - error: ", GetLastError(), "!!!");
         return;
      }
      
      // Invertendo os arrays
      ArrayReverse(sellValue, 0, WHOLE_ARRAY);
      ArrayReverse(buyValue, 0, WHOLE_ARRAY);
      
      // Verifica se existe preço de compra disponível no buffer do indicador
      if (buyValue[1] > 0) {
      
         /* Fecha a posição de venda anteriormente aberta */
         fecharPosicoesAbertas(POSITION_TYPE_SELL);
         
         // Envia a ordem de negociação
         enviaOrdem(ORDER_TYPE_BUY, TRADE_ACTION_DEAL, latestPrice.ask, Lot, 0, 0);
         
         // Sai da função
         return; 
      }
      
      // Verifica se existe preço de venda disponível no buffer do indicador
      if (sellValue[1] > 0) {
      
         /* Fecha a posição de compra anteriormente aberta */
         fecharPosicoesAbertas(POSITION_TYPE_BUY);
         
         // Envia a ordem de negociação
         enviaOrdem(ORDER_TYPE_SELL, TRADE_ACTION_DEAL, latestPrice.bid, Lot, 0, 0);
         
         // Sai da função
         return;  
      }
   
   } else {
   
      //--- Verifica o horário para saber se o pregão terminou, e assim fechar todas
      //--- as ordens abertas
      if (horaAtual.hour == 16 && horaAtual.min >= 55) {
         Print("Fora do horário do pregão! Fechando todas as ordens abertas...");
         fecharPosicoesAbertas(POSITION_TYPE_BUY);
         fecharPosicoesAbertas(POSITION_TYPE_SELL);
      }
      
      // Sai da função
      return;      
   }
}

//+------------------------------------------------------------------+ 
//|  Retorna true caso esteja dentro do perído permitido para        |
//|  operações daytrade com minicontratos de índice.                 |
//+------------------------------------------------------------------+  
bool horarioPermiteOperar(MqlDateTime &hora) {
   
   //--- Verifica se o horário atual permite operar
   if (hora.hour >= 10 && hora.hour < 17) {
      return(true);
   } else {
      if (MQL5InfoInteger(MQL5_DEBUGGING)) {
         //--- Exibimos uma mensagem sobre o tempo de abertura da nova barra
         Print("São ", hora.hour, "h ", hora.min, "m - está fora do horário de negociação!");
      }
   }
   
   return(false);
} 

//+------------------------------------------------------------------+ 
//|  Fecha todas as posições que estão atualmente abertas            |
//+------------------------------------------------------------------+  
void fecharPosicoesAbertas(ENUM_POSITION_TYPE typeOrder) {
   
   /* Fecha a posição anteriormente abertas */
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      // Verifica se a posição aberta é uma posição inversa
      if (PositionSelectByTicket(PositionGetTicket(i)) && ((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)) == typeOrder) {
         Print("Ticket #", PositionGetTicket(i), " fechado com o lucro aproximado de ", PositionGetDouble(POSITION_PROFIT));
         cTrade.PositionClose(PositionGetTicket(i));
      }
   }
}  
 
//+------------------------------------------------------------------+ 
//|  Retorna true quando aparece uma nova barra no gráfico           |
//|  Função obtida no seguinte tópico de ajuda:                      |
//|  https://www.mql5.com/pt/docs/event_handlers/ontick              |
//+------------------------------------------------------------------+ 
bool temNovaBarra() {

   static datetime barTime = 0; // Armazenamos o tempo de abertura da barra atual
   datetime currentBarTime = iTime(_Symbol, _Period, 0); // Obtemos o tempo de abertura da barra zero
   
   //-- Se o tempo de abertura mudar, é porque apareceu uma nova barra
   if (barTime != currentBarTime) {
      barTime = currentBarTime;
      if (MQL5InfoInteger(MQL5_DEBUGGING)) {
         //--- Exibimos uma mensagem sobre o tempo de abertura da nova barra
         PrintFormat("%s: nova barra em %s %s aberta em %s", __FUNCTION__, _Symbol,
            StringSubstr(EnumToString(_Period), 7), TimeToString(TimeCurrent(), TIME_SECONDS));
      }
      
      return(true); // temos uma nova barra
   }

   return(false); // não há nenhuma barra nova
}

//+------------------------------------------------------------------+ 
//|  Efetua uma operação de negociação a mercado                     |
//|  Função obtida no seguinte tópico de ajuda:                      |
//|  https://www.mql5.com/pt/docs/event_handlers/ontick              |
//+------------------------------------------------------------------+
bool enviaOrdem(ENUM_ORDER_TYPE typeOrder,
                 ENUM_TRADE_REQUEST_ACTIONS typeAction,
                 double price,
                 double volume,
                 double stop,
                 double profit,
                 ulong deviation = 100,
                 ulong positionTicket = 0) {
   
   //--- Declaração e inicialização das estruturas
   MqlTradeRequest tradeRequest; // Envia as requisições de negociação
   MqlTradeResult tradeResult; // Receba o resultado das requisições de negociação
   ZeroMemory(tradeRequest); // Inicializa a estrutura
   ZeroMemory(tradeResult); // Inicializa a estrutura
   
   //--- Popula os campos da estrutura tradeRequest
   tradeRequest.action = typeAction; // Tipo de execução da ordem
   tradeRequest.price = NormalizeDouble(price, _Digits); // Preço da ordem
   tradeRequest.sl = NormalizeDouble(stop, _Digits); // Stop loss da ordem
   tradeRequest.tp = NormalizeDouble(profit, _Digits); // Take profit da ordem
   tradeRequest.symbol = _Symbol; // Símbolo
   tradeRequest.volume = volume; // Volume a ser negociado
   tradeRequest.type = typeOrder; // Tipo de ordem
   tradeRequest.magic = EA_Magic; // Número mágico do EA
   tradeRequest.type_filling = ORDER_FILLING_FOK; // Tipo de execução da ordem
   tradeRequest.deviation = deviation; // Desvio permitido em relação ao preço
   tradeRequest.position = positionTicket; // Ticket da posição
   
   //--- Envia a ordem
   if (!OrderSend(tradeRequest, tradeResult)) {
      //-- Exibimos as informações sobre a falha
      Alert("Não foi possível enviar a ordem. Erro ", GetLastError());
      PrintFormat("Envio de ordem %s %s %.2f a %.5f, erro %d", tradeRequest.symbol, EnumToString(typeOrder), volume, tradeRequest.price, GetLastError());
      return(false);
   }
   
   //-- Exibimos as informações sobre a ordem bem-sucedida
   Alert("Uma nova ordem foi enviada com sucesso! Ticket #", tradeResult.order);
   PrintFormat("Código %u, negociação %I64u, ticket #%I64u", tradeResult.retcode, tradeResult.deal, tradeResult.order);
   return(true);
}
//+------------------------------------------------------------------+
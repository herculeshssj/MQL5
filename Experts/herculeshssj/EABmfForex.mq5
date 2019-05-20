//+------------------------------------------------------------------+
//|                                                   EABmfForex.mq5 |
//|                            Copyright ® 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|Changelog:                                                        |
//|v1.00 - EA para operação com minicontratos de índice na Bovespa   |
//|        BM&F e para operação com pares de moedas no mercado Forex.|
//|        O EA foi construído usando todo o conhecimento adquirido  |
//|        sobre linguagem MQL5 até o presente momento.              |
//|      - Estratégia adotada por padrão: ter a opção de não definir |
//|        stop loss e take profit para as ordens, a fim de trabalhar|
//|        somente com lucro/prejuízo máximos. Também não é definido |
//|        por padrão um número máximo de posições abertas, ficando  |
//|        a limitação em cima da margem disponível na conta.        |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property version   "1.00"
//#property description "EA para operação com minicontratos de índice na Bovespa BM&F e para operação com pares de moedas no mercado Forex."

//--- Inclusão de arquivos
#include <herculeshssj\HAccount.mqh>
#include <herculeshssj\HOrder.mqh>
#include <herculeshssj\HStrategy.mqh>
#include <Trade\Trade.mqh>

//--- Enumerações
enum ENUM_METODO_CALCULO {
   HIGH_LOW = 0,// Máxima/Mínima (H/L)
   OPEN_CLOSE = 1 // Abertura/Fechamento (O/C)
};

//--- Variáveis estáticas
static int spread = 10;

//--- Declaração de classe
CTrade cTrade; // Classe com métodos para negociação obtido das bibliotecas do MetaTrader
CAccount cAccount; // Classe com métodos para obter informações sobre a conta
COrder cOrder; // Classe com métodos utilitários para negociação
CStrategy cStrategy; // Classe mãe para as estratégias de negociação

//--- Handle dos indicadores
int dunniganHandle;

//--- Buffers
double vendaBuffer[], compraBuffer[]; // Armazena os sinais de compra e venda de Dunnigan

//--- Parâmetros de entrada
input double stopLoss = 0; // Stop loss, 0 - desabilita
input double takeProfit = 0; // Take profit, 0 - desabilita
input int    posicoesAbertas = 0; // Máximo de posições abertas, 0 - desabilita
input double prejuizoMaximo = 10.0; // Prejuízo máximo de uma posição aberta
input double lucroMaximo = 10.0; // Lucro máximo de uma posição aberta
input ENUM_METODO_CALCULO metodoCalculo = HIGH_LOW; // Método de cálculo Dunnigan
input double Lots = 0.1; // Lots
input int    magicNumber = 19851024; // Número mágico EA

//+------------------------------------------------------------------+
//| Inicialização do EA                                              |
//+------------------------------------------------------------------+
int init() {
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Encerramento do EA                                               |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   // Entre com o código aqui
}

//+------------------------------------------------------------------+
//| Método que recebe os ticks vindo do gráfico                      |
//+------------------------------------------------------------------+
void OnTick() {
   
   //--- Verifica se tem uma nova barra
   if (temNovaBarra()) {
      
      //--- Obtém o valor do spread
      spread = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
      
      //--- Obtém as informações do último preço da cotação
      MqlTick ultimoPreco;
      if (!SymbolInfoTick(_Symbol, ultimoPreco)) {
         Print("Erro ao obter a última cotação! - Erro ", GetLastError());
      }
      
      //--- Verifica o lucro e prejuízo das posições abertas para encerrar
      for (int i = PositionsTotal() - 1; i >= 0; i--) {
         if (PositionSelectByTicket(PositionGetTicket(i))) {
            
            if (PositionGetDouble(POSITION_PROFIT) >= lucroMaximo) {
               // Encerra a posição lucrativa
               cTrade.PositionClose(PositionGetTicket(i));
            }
            
            if (PositionGetDouble(POSITION_PROFIT) <= (prejuizoMaximo * -1)) {
               // Encerra a posição de prejuízo
               cTrade.PositionClose(PositionGetTicket(i));
            }
         }
      }
      
      //--- Armazena a quantidade de posições abertas
      //--- Caso a conta seja hegding, obtém a informação de PositionsTotal()
      //--- Caso a conta seja netting, obtém o volume da posição aberta
      int totalPosicoes = PositionsTotal();
      if(((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE)) == ACCOUNT_MARGIN_MODE_RETAIL_NETTING) {
         if(totalPosicoes > 0 && PositionSelectByTicket(PositionGetTicket(0))) {
            totalPosicoes=(int)PositionGetDouble(POSITION_VOLUME);
         }
      }
      
      //--- Verifica a possibilidade de abrir posições longas e curtas
      //--- Só abre uma nova posição se não tiver extrapolado o limite estabelecido
      if(posicoesAbertas == 0 || totalPosicoes < posicoesAbertas) {
         if(sinalNegociacao() > 0) {
            
            //--- Calcula o stop loss e take profit
            double sl = 0;
            if(stopLoss>0) {
               sl = ultimoPreco.ask - stopLoss * _Point;
            }

            double tp = 0;
            if(takeProfit > 0) {
               tp = ultimoPreco.ask + takeProfit * _Point;
            }

            //--- Envia a ordem de compra
            MarketOrder(ORDER_TYPE_BUY, TRADE_ACTION_DEAL, ultimoPreco.ask, Lots, sl, tp);
         
         } else {
         
            //--- Calcula o stop loss e take profit
            double sl = 0;
            if(stopLoss > 0) {
               sl = ultimoPreco.bid + stopLoss * _Point;
            }

            double tp = 0;
            if(takeProfit > 0) {
               tp = ultimoPreco.bid - takeProfit * _Point;
            }

            //--- Envia a ordem de venda  
            MarketOrder(ORDER_TYPE_SELL, TRADE_ACTION_DEAL, ultimoPreco.bid, Lots, sl, tp);
         }
      } else {
         Print("Atingido o limite máximo de posições abertas!");
      }
 
   }
   
   //--- Fim do método
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
bool MarketOrder(ENUM_ORDER_TYPE typeOrder,
                 ENUM_TRADE_REQUEST_ACTIONS typeAction,
                 double price,
                 double volume,
                 double stop,
                 double profit,
                 ulong deviation=100,
                 ulong positionTicket=0) {

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
   tradeRequest.magic = magicNumber; // Número mágico do EA
   tradeRequest.type_filling = ORDER_FILLING_FOK; // Tipo de execução da ordem
   tradeRequest.deviation = deviation; // Desvio permitido em relação ao preço
   tradeRequest.position = positionTicket; // Ticket da posição
   
   //--- Envia a ordem
   if(!OrderSend(tradeRequest, tradeResult)) {
      //-- Exibimos as informações sobre a falha
      Alert("Não foi possível enviar a ordem! Erro ",GetLastError());
      PrintFormat("Envio de ordem %s %s %.2f a %.5f, erro %d", tradeRequest.symbol, EnumToString(typeOrder), volume, tradeRequest.price, GetLastError());
      return(false);
   }
   
   //-- Exibimos as informações sobre a ordem bem-sucedida
   Alert("Uma nova ordem foi enviada com sucesso! Ticket #", tradeResult.order);
   PrintFormat("Código %u, negociação %I64u, ticket #%I64u", tradeResult.retcode, tradeResult.deal, tradeResult.order);
   return(true);
   
}

//+------------------------------------------------------------------+
//|  Função responsável por informar se o momento é de abrir uma     |
//|  posição de compra ou venda.                                     |
//|                                                                  |
//|  -1 - Abre uma posição de venda                                  |
//|  +1 - Abre uma posição de compra                                 |
//|   0 - Nenhum posição é aberta                                    |
//+------------------------------------------------------------------+
double sinalNegociacao() {

   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   //--- Instanciação do indicador
   dunniganHandle = iCustom(_Symbol, _Period, "herculeshssj\\IDunnigan.ex5", metodoCalculo);
   
   if(dunniganHandle < 0) {
      Alert("Falha ao criar o indicador! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Copia o valor do indicador para o array
   if(CopyBuffer(dunniganHandle, 0, 0, 2, vendaBuffer) < 2 || CopyBuffer(dunniganHandle, 1, 0, 2, compraBuffer) < 2) {
      Print("Falha ao copiar os valores do buffer do indicador Dunnigan! Erro ", GetLastError());
      return(sinal);
   }
   
   // Define o array como uma série temporal
   if(!ArraySetAsSeries(vendaBuffer, true)) {
      Print("Falha ao definir o buffer de venda como série temporal! Erro ", GetLastError());
      return(sinal);
   }

   if(!ArraySetAsSeries(compraBuffer, true)) {
      Print("Falha ao definir o buffer de compra como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Checa a condição e seta o valor para o sinal
   if(compraBuffer[1] > 0 && vendaBuffer[1] == 0) {
      sinal = 1; //--- Compra
   } else if(compraBuffer[1] == 0 && vendaBuffer[1] > 0) {
      sinal = -1; //--- Venda
   } else {
      sinal = 0; //--- Não faz nada
   }
   
   //--- Retorna o sinal de negociação
   return(sinal);
  
}
//+------------------------------------------------------------------+
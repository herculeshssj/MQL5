//+------------------------------------------------------------------+
//|                                             HBMFBovespaForex.mqh |
//|                            Copyright ® 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property description "Arquivo MQH que contém a estratégias para negociação nos mercados BM&FBovespa e Forex."

//--- Inclusão de arquivos
#include "..\\HStrategy.mqh"

//+------------------------------------------------------------------+
//| Classe CBMFBovespaForex - Sinais de negociação baseado no        |
//| cruzamento de MAs de 5 e 20 períodos, e também do oscilador      |
//| estocástico. Os dois indicadores dão sinais de negociação, que   |
//| são confirmados pelo NRTR e a posição da barra anterior em       |
//| relação a MA exponencial de 20 períodos, evitando assim abertura |
//| de novas posições contrários a tendência.                        |
//+------------------------------------------------------------------+
class CBMFBovespaForex : public CStrategy {

   private:
      int estocasticoHandle;
      int maAgilHandle;
      int maCurtaHandle;

   public:
      //--- Métodos
      virtual int init(void);
      virtual void release(void);
      virtual int sinalNegociacao(void);
      virtual int sinalConfirmacao(int sinalNegociacao);
      virtual int sinalSaidaNegociacao(int chamadaSaida);  
      
      int onTickBarTimer(void) {
         return(1); // Nova barra
      }    

};

int CBMFBovespaForex::init(void) {

   maAgilHandle = iMA(_Symbol, _Period, 5, 0, MODE_EMA, PRICE_CLOSE);
   maCurtaHandle = iMA(_Symbol, _Period, 20, 0, MODE_EMA, PRICE_CLOSE);
   estocasticoHandle = iStochastic(_Symbol, _Period, 5, 3, 3, MODE_SMA, STO_LOWHIGH);
   
   //--- Verifica se os indicadores foram criados com sucesso
   if (maAgilHandle < 0 || maCurtaHandle < 0 || estocasticoHandle < 0) {
      Alert("Erro ao criar os indicadores! Erro ", GetLastError());
      return(INIT_FAILED);
   }
   
   //--- Retorna o sinal de sucesso
   return(INIT_SUCCEEDED);
   
}

void CBMFBovespaForex::release(void) {
   //--- Libera os indicadores
   IndicatorRelease(maAgilHandle);
   IndicatorRelease(maCurtaHandle);
   IndicatorRelease(estocasticoHandle);
}

int CBMFBovespaForex::sinalNegociacao(void) {

   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   double maAgilBuffer[], maCurtaBuffer[]; // Armazena os valores das médias móveis
   double estocasticoBuffer[]; // Armazena os valores do oscilador estocástico
   
   //--- Copia o valor dos indicadores para seus respectivos buffers
   if (CopyBuffer(maAgilHandle, 0, 0, 3, maAgilBuffer) < 3
         || CopyBuffer(maCurtaHandle, 0, 0, 3, maCurtaBuffer) < 3) {
      Print("Falha ao copiar dados do indicador para o buffer! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Copia o valor do indicador para seu respectivo buffer
   if (CopyBuffer(estocasticoHandle, 0, 0, 3, estocasticoBuffer) < 3) {
      Print("Falha ao copiar dados do indicador para o buffer! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define os buffers como série temporal
   if (!ArraySetAsSeries(maAgilBuffer, true) || !ArraySetAsSeries(maCurtaBuffer, true)) {
      Print("Falha ao definir os buffers como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define os buffers como série temporal
   if (!ArraySetAsSeries(estocasticoBuffer, true)) {
      Print("Falha ao definir o buffer como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Verifica a MA das barras para determinar a tendência
   if (maAgilBuffer[2] < maCurtaBuffer[1] && maAgilBuffer[1] > maCurtaBuffer[1]) {
      // Tendência em alta
      sinal = 1;
   } else if (maAgilBuffer[2] > maCurtaBuffer[1] && maAgilBuffer[1] < maCurtaBuffer[1]) {
      // Tendência em baixa
      sinal = -1;
   } else {
      // Sem tendência
      sinal = 0;
   }
   
   //--- Caso o sinal gerado pelas MAs seja zero, obtém-se o sinal de negociação do 
   //--- estocástico
   if (sinal == 0) {
      if (estocasticoBuffer[2] < 20 && estocasticoBuffer[1] > 20) {
         sinal = 1;
      } else if (estocasticoBuffer[2] > 80 && estocasticoBuffer[1] < 80) {
         sinal = -1;
      } else {
         sinal = 0;
      }
   }
   
   //--- Caso nenhum sinal tenha sido gerado, usa-se o NRTR para gerar o sinal de negociação
   if (sinal == 0) {
      if (trailingStop.trend() == 1) {
         //--- Confirmado o sinal de compra
         sinal = 2;
      } else if (trailingStop.trend() == -1) {
         //--- Confirmado o sinal de venda
         sinal = -2;
      } else {
         sinal = 0;
      }
   }
   
   //--- Retorna o sinal de negociação
   return(sinal);
   
}

int CBMFBovespaForex::sinalConfirmacao(int sinalNegociacao) {
   
   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   //--- Compara o sinal de negociação com o valor atual de suporte e resistência
   //--- do indicador NRTR
   
   //--- Tendência está a favor?
   if (sinalNegociacao == 1 && trailingStop.trend() == 1) {
      //--- Confirmado o sinal de compra
      sinal = 1;
   } else if (sinalNegociacao == -1 && trailingStop.trend() == -1) {
      //--- Confirmado o sinal de venda
      sinal = -1;
   }
   
   //--- Para confirmar que o gráfico está mesmo em tendência, e não lateral, verifica
   //--- se a barra anterior está acima ou abaixo da MA curta
   
   double maBuffer[]; // Armazena os valores das médias móveis
   
   //--- Copia o valor do indicador para seu respectivo buffer
   if (CopyBuffer(this.maCurtaHandle, 0, 0, 4, maBuffer) < 4) {
      Print("Falha ao copiar dados do indicador para o buffer! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define os buffers como série temporal
   if (!ArraySetAsSeries(maBuffer, true)) {
      Print("Falha ao definir o buffer como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   if (sinalNegociacao == 2) {
      
      if (maBuffer[1] < iOpen(_Symbol, _Period, 1) && maBuffer[1] < iClose(_Symbol, _Period, 1)
         && maBuffer[1] < iHigh(_Symbol, _Period, 1) && maBuffer[1] < iLow(_Symbol, _Period, 1)) {
         
         sinal = 1;
      
      }
   
   } else if (sinalNegociacao == -2) {

      if (maBuffer[1] > iOpen(_Symbol, _Period, 1) && maBuffer[1] > iClose(_Symbol, _Period, 1)
         && maBuffer[1] > iHigh(_Symbol, _Period, 1) && maBuffer[1] > iLow(_Symbol, _Period, 1)) {
         
         sinal = -1;
      
      }
   
   } else {
      //--- Sinal não confirmado
      sinal = 0;
   }
   
   //--- Retorna o sinal de confirmação
   return(sinal);
   
}

int CBMFBovespaForex::sinalSaidaNegociacao(int chamadaSaida) {
   
   //--- Verifica se a chamada veio do método OnTimer()
   if (chamadaSaida == 9) {
      //--- Verifica se o ativo atingiu o lucro desejado para poder encerrar a posição
      if (cMoney.atingiuLucroDesejado()) {
         return(0); // Pode encerrar as posições abertas
      }
   }
   
   if (chamadaSaida == 0) {
      //--- Verifica o tamanho do prejuízo para poder encerrar as posições
      for (int i = PositionsTotal() - 1; i >= 0; i--) {
         if (PositionSelectByTicket(PositionGetTicket(i)) && PositionGetString(POSITION_SYMBOL) == _Symbol) {
            double lucro = PositionGetDouble(POSITION_PROFIT);
            if (lucro <= -50) {
               //--- Encerra a posição quando o prejuízo alcançar o limite máximo estabelecido
               return(0); // Pode encerrar as posições abertas
            }
         }
      }
   }
   
   
   return(-1);
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Classe CForexXAU - Sinais de negociação baseado no cruzamento das|
//| MAs exponenciais de 5, 20 e 50, e também do indicador NRTR.      |
//| Caso o cruzamento das MAs 50 e 20, e 20 e 5 não gerem sinais, é  |
//| usado o sinal do NRTR para abrir uma posição a favor da          |	     
//| tendência atual. Caso o sinal seja gerado pelo NRTR, verifica-se |
//| a posição da barra anterior em relação a MA exponencial de 20    |
//| períodos, evitando assim abertura de novas posições contrários a |
//| tendência. Esta estratégia foi otimizada para ouro (XAU) na      |
//| Pepperstone, uma vez que a cobrança do ativo é no spread, e não  |
//| na comissão.                                                     |
//+------------------------------------------------------------------+
class CForexXAU : public CStrategy {

   private:
      int maAgilHandle;
      int maCurtaHandle;
      int maLongaHandle;

   public:
      //--- Métodos
      virtual int init(void);
      virtual void release(void);
      virtual int sinalNegociacao(void);
      virtual int sinalConfirmacao(int sinalNegociacao);
      virtual int sinalSaidaNegociacao(int chamadaSaida);  
      
      int onTickBarTimer(void) {
         return(1); // Nova barra
      }    

};

int CForexXAU::init(void) {

   maAgilHandle = iMA(_Symbol, _Period, 5, 0, MODE_EMA, PRICE_CLOSE);
   maCurtaHandle = iMA(_Symbol, _Period, 20, 0, MODE_EMA, PRICE_CLOSE);
   maLongaHandle = iMA(_Symbol, _Period, 50, 0, MODE_EMA, PRICE_CLOSE);
   
   //--- Verifica se os indicadores foram criados com sucesso
   if (maAgilHandle < 0 || maCurtaHandle < 0 || maLongaHandle < 0) {
      Alert("Erro ao criar os indicadores! Erro ", GetLastError());
      return(INIT_FAILED);
   }
   
   //--- Retorna o sinal de sucesso
   return(INIT_SUCCEEDED);
   
}

void CForexXAU::release(void) {
   //--- Libera os indicadores
   IndicatorRelease(maAgilHandle);
   IndicatorRelease(maCurtaHandle);
   IndicatorRelease(maLongaHandle);
}

int CForexXAU::sinalNegociacao(void) {

   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   double maAgilBuffer[], maCurtaBuffer[], maLongaBuffer[]; // Armazena os valores das médias móveis
   
   //--- Copia o valor dos indicadores para seus respectivos buffers
   if (CopyBuffer(maAgilHandle, 0, 0, 3, maAgilBuffer) < 3
         || CopyBuffer(maCurtaHandle, 0, 0, 3, maCurtaBuffer) < 3
         || CopyBuffer(maLongaHandle, 0, 0, 3, maLongaBuffer) < 3) {
      Print("Falha ao copiar dados do indicador para o buffer! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define os buffers como série temporal
   if (!ArraySetAsSeries(maAgilBuffer, true) 
      || !ArraySetAsSeries(maCurtaBuffer, true)
      || !ArraySetAsSeries(maLongaBuffer, true)) {
      Print("Falha ao definir os buffers como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   /* 
      A estratégia usa os cruzamentos da MA Curta com MA Longa, MA Curta com MA Ágil e NRTR,
      de modo a obter a aproveitar ao máximo a tendência do ativo alvo. 
   */
   
   //--- Verifica a MA das barras para determinar a tendência
   if (maCurtaBuffer[2] < maLongaBuffer[1] && maCurtaBuffer[1] > maLongaBuffer[1]) {
      // Tendência em alta
      sinal = 1;
   } else if (maCurtaBuffer[2] > maLongaBuffer[1] && maCurtaBuffer[1] < maLongaBuffer[1]) {
      // Tendência em baixa
      sinal = -1;
   } else {
      // Sem tendência
      sinal = 0;
   }
   
   //--- Verifica a MA das barras para determinar a tendência caso não tenha havido o cruzamento
   //--- entre as MAs curta e longa
   if (sinal == 0) {
   
      if (maAgilBuffer[2] < maCurtaBuffer[1] && maAgilBuffer[1] > maCurtaBuffer[1]) {
         // Tendência em alta
         sinal = 1;
      } else if (maAgilBuffer[2] > maCurtaBuffer[1] && maAgilBuffer[1] < maCurtaBuffer[1]) {
         // Tendência em baixa
         sinal = -1;
      } else {
         // Sem tendência
         sinal = 0;
      }   
   }
   
   //--- Caso nenhum sinal tenha sido gerado, usa-se o NRTR para gerar o sinal de negociação
   if (sinal == 0) {
      if (trailingStop.trend() == 1) {
         //--- Confirmado o sinal de compra
         sinal = 2;
      } else if (trailingStop.trend() == -1) {
         //--- Confirmado o sinal de venda
         sinal = -2;
      } else {
         sinal = 0;
      }
   }
   
   //--- Retorna o sinal de negociação
   return(sinal);
   
}

int CForexXAU::sinalConfirmacao(int sinalNegociacao) {
   
   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   //--- Caso o sinal seja 1 ou -1, efetua a confirmação do sinal
   if (sinalNegociacao == 1 || sinalNegociacao == -1) {
      if (sinalNegociacao == 1 && trailingStop.trend() == 1) {
         //--- Confirmado o sinal de compra
         sinal = 1;
      } else if (sinalNegociacao == -1 && trailingStop.trend() == -1) {
         //--- Confirmado o sinal de venda
         sinal = -1;
      }
   } else {
      
      /* Caso o sinal tenha sido gerado pelo NRTR */
      
      //--- Para confirmar que o gráfico está mesmo em tendência, e não lateral, verifica
      //--- se a barra anterior está acima ou abaixo da MA curta
      
      double maBuffer[]; // Armazena os valores das médias móveis
      
      //--- Copia o valor do indicador para seu respectivo buffer
      if (CopyBuffer(this.maCurtaHandle, 0, 0, 4, maBuffer) < 4) {
         Print("Falha ao copiar dados do indicador para o buffer! Erro ", GetLastError());
         return(sinal);
      }
      
      //--- Define os buffers como série temporal
      if (!ArraySetAsSeries(maBuffer, true)) {
         Print("Falha ao definir o buffer como série temporal! Erro ", GetLastError());
         return(sinal);
      }
      
      //--- Verifica qual posição da barra anterior em relação a MA curta para poder confirmar o sinal
      if (sinalNegociacao == 2) {
      
         if (maBuffer[1] < iOpen(_Symbol, _Period, 1) && maBuffer[1] < iClose(_Symbol, _Period, 1)
            && maBuffer[1] < iHigh(_Symbol, _Period, 1) && maBuffer[1] < iLow(_Symbol, _Period, 1)
            && maBuffer[2] < iOpen(_Symbol, _Period, 2) && maBuffer[2] < iClose(_Symbol, _Period, 2)
            && maBuffer[2] < iHigh(_Symbol, _Period, 2) && maBuffer[2] < iLow(_Symbol, _Period, 2)) {
            
            sinal = 1;
         
         }
      
      } else if (sinalNegociacao == -2) {
   
         if (maBuffer[1] > iOpen(_Symbol, _Period, 1) && maBuffer[1] > iClose(_Symbol, _Period, 1)
            && maBuffer[1] > iHigh(_Symbol, _Period, 1) && maBuffer[1] > iLow(_Symbol, _Period, 1)
            && maBuffer[2] > iOpen(_Symbol, _Period, 2) && maBuffer[2] > iClose(_Symbol, _Period, 2)
            && maBuffer[2] > iHigh(_Symbol, _Period, 2) && maBuffer[2] > iLow(_Symbol, _Period, 2)) {
            
            sinal = -1;
         
         }
      
      } else {
         //--- Sinal não confirmado
         sinal = 0;
      }
      
   }
  
   //--- Retorna o sinal de confirmação
   return(sinal);
   
}

int CForexXAU::sinalSaidaNegociacao(int chamadaSaida) {
   
   //--- Verifica se a chamada veio do método OnTimer()
   if (chamadaSaida == 9) {
      //--- Verifica se o ativo atingiu o lucro desejado para poder encerrar a posição
      if (cMoney.atingiuLucroDesejado()) {
         return(0); // Pode encerrar as posições abertas
      }
   }
   
   if (chamadaSaida == 0) {
      //--- Verifica o tamanho do prejuízo para poder encerrar as posições
      for (int i = PositionsTotal() - 1; i >= 0; i--) {
         if (PositionSelectByTicket(PositionGetTicket(i)) && PositionGetString(POSITION_SYMBOL) == _Symbol) {
            double lucro = PositionGetDouble(POSITION_PROFIT);
            if (lucro <= -50) {
               //--- Encerra a posição quando o prejuízo alcançar o limite máximo estabelecido
               return(0); // Pode encerrar as posições abertas
            }
         }
      }
   }
   
   return(-1);
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Classe CMinicontratoIndice - Cruzamento de Médias Móveis         |
//| exponenciais de 20 e 50 períodos, com confirmação baseado no     |
//| indicador NRTR.                                                  |
//| Sempre que as posições abertas atingirem o lucro alvo, novas     |
//| posições serão abertas para maximixar o lucro.                   |
//+------------------------------------------------------------------+
class CMinicontratoIndice : public CStrategy {

   private:
      int maCurtaHandle;
      int maLongaHandle;

   public:
      //--- Atributos
      double lucroGarantido;
         
      //--- Métodos
      virtual int init(void);
      virtual void release(void);
      virtual int sinalNegociacao(void);
      virtual int sinalConfirmacao(int sinalNegociacao);
      virtual int sinalSaidaNegociacao(int chamadaSaida);  
      
      int onTickBarTimer(void) {
         return(1); // Nova barra
      }    

};

int CMinicontratoIndice::init(void) {
   
   maCurtaHandle = iMA(_Symbol, _Period, 20, 0, MODE_EMA, PRICE_CLOSE);
   maLongaHandle = iMA(_Symbol, _Period, 50, 0, MODE_EMA, PRICE_CLOSE);
   
   //--- Verifica se os indicadores foram criados com sucesso
   if (maCurtaHandle < 0 || maLongaHandle < 0) {
      Alert("Erro ao criar os indicadores! Erro ", GetLastError());
      return(INIT_FAILED);
   }
   
   //--- Retorna o sinal de sucesso
   return(INIT_SUCCEEDED);
   
}

void CMinicontratoIndice::release(void) {
   //--- Libera os indicadores
   IndicatorRelease(maCurtaHandle);
   IndicatorRelease(maLongaHandle);
}

int CMinicontratoIndice::sinalNegociacao(void) {
   
   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   double maCurtaBuffer[], maLongaBuffer[]; // Armazena os valores das médias móveis
   
   //--- Copia o valor dos indicadores para seus respectivos buffers
   if (CopyBuffer(maCurtaHandle, 0, 0, 3, maCurtaBuffer) < 3
         || CopyBuffer(maLongaHandle, 0, 0, 3, maLongaBuffer) < 3) {
      Print("Falha ao copiar dados do indicador para o buffer! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define os buffers como série temporal
   if (!ArraySetAsSeries(maCurtaBuffer, true) || !ArraySetAsSeries(maLongaBuffer, true)) {
      Print("Falha ao definir os buffers como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Verifica a MA das barras para determinar a tendência
   if (maCurtaBuffer[2] < maLongaBuffer[1] && maCurtaBuffer[1] > maLongaBuffer[1]) {
      // Tendência em alta
      sinal = 1;
   } else if (maCurtaBuffer[2] > maLongaBuffer[1] && maCurtaBuffer[1] < maLongaBuffer[1]) {
      // Tendência em baixa
      sinal = -1;
   } else {
      // Sem tendência
      sinal = 0;
   }

   //--- Retorna o sinal de negociação
   return(sinal);
   
}

int CMinicontratoIndice::sinalConfirmacao(int sinalNegociacao) {
   
   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   //--- Compara o sinal de negociação com o valor atual de suporte e resistência
   //--- do indicador NRTR
   
   //--- Tendência está a favor?
   if (sinalNegociacao == 1 && trailingStop.trend() == 1) {
      //--- Confirmado o sinal de compra
      sinal = 1;
   } else if (sinalNegociacao == -1 && trailingStop.trend() == -1) {
      //--- Confirmado o sinal de venda
      sinal = -1;
   }
   
   //--- Retorna o sinal de confirmação
   return(sinal);
   
}

int CMinicontratoIndice::sinalSaidaNegociacao(int chamadaSaida) {

   //--- Obtém o tamanho do tick
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   
   //--- Obtém as informações do último preço da cotação
   MqlTick ultimoPreco;
   if (!SymbolInfoTick(_Symbol, ultimoPreco)) {
      Print("Erro ao obter a última cotação! - Erro ", GetLastError());
      return(-1);
   }
   
   //--- Determina o tamanho do lote
   double lote = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);

   //--- Verifica se a chamada veio do método OnTimer()
   if (chamadaSaida == 9) {
      
      for (int i = PositionsTotal() - 1; i >= 0; i--) {
         if (PositionSelectByTicket(PositionGetTicket(i)) && PositionGetString(POSITION_SYMBOL) == _Symbol) {
            
            double lucro = PositionGetDouble(POSITION_PROFIT);
            double valorAlvo = cAccount
               .obterMargemNecessariaParaNovaPosicao(PositionGetDouble(POSITION_VOLUME), 
                  (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE))
               * 0.2; // 20% da margem disponível para abertura
            
            //--- Nos casos que o valorAlvo for menor que um, usa-se volume * 25;
            if (valorAlvo < 1) {
               valorAlvo = PositionGetDouble(POSITION_VOLUME) * 25;
            }
            
            if (lucro > valorAlvo) {
               
               //--- Se o lucro garantido está sendo definido pela primeira vez, o lucro atual será o lucro garantido
               if (this.lucroGarantido == 0) {
                  this.lucroGarantido = lucro;
               } else {
                  //--- Verifica se o lucro ultrapassou 20% do lucro garantido
                  if ( lucro > (this.lucroGarantido * 1.2) ) {
                     //--- Define o novo lucro garantido
                     this.lucroGarantido = lucro;
                     
                     //--- Abre uma nova posição
                     if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
                        //--- Ajusta o preço nos casos do tick vier com um valor inválido
                        double preco = ultimoPreco.ask;
                        
                        // Diminui o resto da divisão do preço com o tick size para igualar ao
                        // último múltiplo do valor de tick size
                        if (fmod(preco, tickSize) != 0) {
                           preco = preco - fmod(preco, tickSize);
                        }                        
                     
                        cOrder.enviaOrdem(ORDER_TYPE_BUY, TRADE_ACTION_DEAL, preco, lote, 0, 0);
                     } else {
                     
                        //--- Ajusta o preço nos casos do tick vier com um valor inválido
                        double preco = ultimoPreco.bid;
                        
                        // Diminui o resto da divisão do preço com o tick size para igualar ao
                        // último múltiplo do valor de tick size
                        if (fmod(preco, tickSize) != 0) {
                           preco = preco - fmod(preco, tickSize);
                        }
                        
                        cOrder.enviaOrdem(ORDER_TYPE_SELL, TRADE_ACTION_DEAL, preco, lote, 0, 0);
                     }                  
                     
                  } else if (lucro <= (lucroGarantido * 0.8) ) {
                     // Reseta as variáveis
                     this.lucroGarantido = 0;
                  
                     //--- Encerra a posição aberta
                     string mensagem = "Ticket #" 
                        + IntegerToString(PositionGetTicket(i)) 
                        + " do símbolo " + _Symbol + " fechado com o lucro/prejuízo de " 
                        + DoubleToString(PositionGetDouble(POSITION_PROFIT));
                     cOrder.fecharPosicao(PositionGetTicket(i));
                     cUtil.enviarMensagem(PUSH, mensagem);
                  
                  }
               }
               
            } else if (lucro <= -50) {
               //--- Encerra a posição quando o prejuízo alcançar o limite máximo estabelecido
               string mensagem = "Ticket #" 
                  + IntegerToString(PositionGetTicket(i)) 
                  + " do símbolo " + _Symbol + " fechado com o lucro/prejuízo de " 
                  + DoubleToString(PositionGetDouble(POSITION_PROFIT));
               cOrder.fecharPosicao(PositionGetTicket(i));
               cUtil.enviarMensagem(PUSH, mensagem);
            }
         }         
      }
      
   }

   return(-1);
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Classe CTendenciaNRTR - Sinais de negociação do NRTR com         |
//| com confirmação da tendência a partir da posição das barras em   |
//| relação a MA exponencial de 20 períodos.                         |
//+------------------------------------------------------------------+
class CTendenciaNRTR : public CStrategy {

   private:
      int maHandle;

   public:
      //--- Métodos
      virtual int init(void);
      virtual void release(void);
      virtual int sinalNegociacao(void);
      virtual int sinalConfirmacao(int sinalNegociacao);
      virtual int sinalSaidaNegociacao(int chamadaSaida);  
      
      int onTickBarTimer(void) {
         return(1); // Nova barra
      }    

};

int CTendenciaNRTR::init(void) {
   
   maHandle = iMA(_Symbol, _Period, 20, 0, MODE_EMA, PRICE_CLOSE);
   
   //--- Verifica se os indicadores foram criados com sucesso
   if (maHandle < 0) {
      Alert("Erro ao criar os indicadores! Erro ", GetLastError());
      return(INIT_FAILED);
   }
   
   //--- Retorna o sinal de sucesso
   return(INIT_SUCCEEDED);
   
}

void CTendenciaNRTR::release(void) {
   //--- Libera os indicadores
   IndicatorRelease(maHandle);
}

int CTendenciaNRTR::sinalNegociacao(void) {
   
   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   //--- Obtém o sinal de negociação com o valor atual de suporte e resistência
   //--- do indicador NRTR. O indicador já está instanciado pois o mesmo é usado
   //--- para trailing stop
   
   //--- Tendência está a favor?
   if (trailingStop.trend() == 1) {
      //--- Confirmado o sinal de compra
      sinal = 1;
   } else if (trailingStop.trend() == -1) {
      //--- Confirmado o sinal de venda
      sinal = -1;
   }
   
   //--- Retorna o sinal de negociação
   return(sinal);
   
}

int CTendenciaNRTR::sinalConfirmacao(int sinalNegociacao) {
   
   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   double maBuffer[]; // Armazena os valores das médias móveis
   
   //--- Copia o valor do indicador para seu respectivo buffer
   if (CopyBuffer(this.maHandle, 0, 0, 4, maBuffer) < 4) {
      Print("Falha ao copiar dados do indicador para o buffer! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define os buffers como série temporal
   if (!ArraySetAsSeries(maBuffer, true)) {
      Print("Falha ao definir o buffer como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Verifica qual posição da barra anterior em relação a MA curta para poder confirmar o sinal
   if (sinalNegociacao == 1) {
   
      if (maBuffer[1] < iOpen(_Symbol, _Period, 1) && maBuffer[1] < iClose(_Symbol, _Period, 1)
         && maBuffer[1] < iHigh(_Symbol, _Period, 1) && maBuffer[1] < iLow(_Symbol, _Period, 1)
         && maBuffer[2] < iOpen(_Symbol, _Period, 2) && maBuffer[2] < iClose(_Symbol, _Period, 2)
         && maBuffer[2] < iHigh(_Symbol, _Period, 2) && maBuffer[2] < iLow(_Symbol, _Period, 2)) {
         
         sinal = 1;
      
      }
   
   } else if (sinalNegociacao == -1) {

      if (maBuffer[1] > iOpen(_Symbol, _Period, 1) && maBuffer[1] > iClose(_Symbol, _Period, 1)
         && maBuffer[1] > iHigh(_Symbol, _Period, 1) && maBuffer[1] > iLow(_Symbol, _Period, 1)
         && maBuffer[2] > iOpen(_Symbol, _Period, 2) && maBuffer[2] > iClose(_Symbol, _Period, 2)
         && maBuffer[2] > iHigh(_Symbol, _Period, 2) && maBuffer[2] > iLow(_Symbol, _Period, 2)) {
         
         sinal = -1;
      
      }
   
   } else {
      //--- Sinal não confirmado
      sinal = 0;
   }
   
   //--- Retorna o sinal de confirmação
   return(sinal);
   
}

int CTendenciaNRTR::sinalSaidaNegociacao(int chamadaSaida) {

   //--- Verifica se a chamada veio do método OnTimer()
   if (chamadaSaida == 9) {
      //--- Verifica se o ativo atingiu o lucro desejado para poder encerrar a posição
      if (cMoney.atingiuLucroDesejado()) {
         return(0); // Pode encerrar as posições abertas
      }
   }
   
   if (chamadaSaida == 0) {
      //--- Verifica o tamanho do prejuízo para poder encerrar as posições
      for (int i = PositionsTotal() - 1; i >= 0; i--) {
         if (PositionSelectByTicket(PositionGetTicket(i)) && PositionGetString(POSITION_SYMBOL) == _Symbol) {
            double lucro = PositionGetDouble(POSITION_PROFIT);
            if (lucro <= -50) {
               //--- Encerra a posição quando o prejuízo alcançar o limite máximo estabelecido
               return(0); // Pode encerrar as posições abertas
            }
         }
      }
   }

   return(-1);
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Classe CDunnigan - Sinais de negociação do indicador Dunnigan.   |
//+------------------------------------------------------------------+
class CDunnigan : public CStrategy {

   private:
      int dunniganHandle;

   public:
      //--- Métodos
      virtual int init(void);
      virtual void release(void);
      virtual int sinalNegociacao(void);
      virtual int sinalConfirmacao(int sinalNegociacao);
      virtual int sinalSaidaNegociacao(int chamadaSaida);  
      
      int onTickBarTimer(void) {
         return(1); // Nova barra
      }    

};

int CDunnigan::init(void) {
   
   this.dunniganHandle = dunniganHandle = iCustom(_Symbol, _Period, "herculeshssj\\IDunnigan.ex5", 1); // Abertura/Fechamento
   
   //--- Verifica se os indicadores foram criados com sucesso
   if (this.dunniganHandle < 0) {
      Alert("Erro ao criar os indicadores! Erro ", GetLastError());
      return(INIT_FAILED);
   }
   
   //--- Retorna o sinal de sucesso
   return(INIT_SUCCEEDED);
   
}

void CDunnigan::release(void) {
   //--- Libera os indicadores
   IndicatorRelease(this.dunniganHandle);
}

int CDunnigan::sinalNegociacao(void) {
   
   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   double vendaBuffer[], compraBuffer[];
   
   //--- Copia o valor do indicador para seu respectivo buffer
   if (CopyBuffer(this.dunniganHandle, 0, 0, 1, vendaBuffer) < 1
      || CopyBuffer(this.dunniganHandle, 1, 0, 1, compraBuffer) < 1) {
      Print("Falha ao copiar dados do indicador para o buffer! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define os buffers como série temporal
   if (!ArraySetAsSeries(vendaBuffer, true) || !ArraySetAsSeries(compraBuffer, true)) {
      Print("Falha ao definir os buffers como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Verifica os buffers de compra e venda para determinar a tendência da nova barra
   if (compraBuffer[0] > 0 && vendaBuffer[0] == 0) {
      //--- Sinal de compra
      sinal = 1;
   } else if (compraBuffer[0] == 0 && vendaBuffer[0] > 0) {
      //--- Sinal de venda
      sinal = -1;
   }
   
   //--- Retorna o sinal de negociação
   return(sinal);
   
}

int CDunnigan::sinalConfirmacao(int sinalNegociacao) {
   
   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   if (sinalNegociacao == 1) {
      sinal = 1;
   } else if (sinalNegociacao == -1) {
      sinal = -1;
   }
   
   //--- Retorna o sinal de confirmação
   return(sinal);
   
}

int CDunnigan::sinalSaidaNegociacao(int chamadaSaida) {

   //--- Verifica se a chamada veio do método OnTimer()
   if (chamadaSaida == 9) {
      //--- Verifica se o ativo atingiu o lucro desejado para poder encerrar a posição
      if (cMoney.atingiuLucroDesejado()) {
         return(0); // Pode encerrar as posições abertas
      }
   }
   
   if (chamadaSaida == 0) {
      //--- Verifica o tamanho do prejuízo para poder encerrar as posições
      for (int i = PositionsTotal() - 1; i >= 0; i--) {
         if (PositionSelectByTicket(PositionGetTicket(i)) && PositionGetString(POSITION_SYMBOL) == _Symbol) {
            double lucro = PositionGetDouble(POSITION_PROFIT);
            if (lucro <= -50) {
               //--- Encerra a posição quando o prejuízo alcançar o limite máximo estabelecido
               return(0); // Pode encerrar as posições abertas
            }
         }
      }
   }

   return(-1);
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Classe CDunniganNRTR - Sinais de negociação do indicador         |
//| Dunnigan com confirmação através dos sinais do NRTRvolatile.     |
//+------------------------------------------------------------------+
class CDunniganNRTR : public CStrategy {

   private:
      //--- Atributos
      int dunniganHandle;
      int nrtrHandle;
      
   public:
      //--- Métodos
      virtual int init(void);
      virtual void release(void);
      virtual int sinalNegociacao(void);
      virtual int sinalConfirmacao(int sinalNegociacao);
      virtual int sinalSaidaNegociacao(int chamadaSaida);  
      
      int onTickBarTimer(void) {
         return(1); // Nova barra
      }    

};

int CDunniganNRTR::init(void) {
   
   //--- Parâmetro: Abertura/Fechamento
   this.dunniganHandle = iCustom(_Symbol, _Period, "herculeshssj\\IDunnigan", 1);
   
   //--- Parâmetros: período = 12; k = 1
   this.nrtrHandle = iCustom(_Symbol, _Period, "Artigos\\NRTRvolatile", 12, 1);
   
   //--- Verifica se os indicadores foram criados com sucesso
   if (this.dunniganHandle < 0 || this.nrtrHandle < 0) {
      Alert("Erro ao criar os indicadores! Erro ", GetLastError());
      return(INIT_FAILED);
   }
   
   //--- Retorna o sinal de sucesso
   return(INIT_SUCCEEDED);
   
}

void CDunniganNRTR::release(void) {
   //--- Libera os indicadores
   IndicatorRelease(this.dunniganHandle);
   IndicatorRelease(this.nrtrHandle);
}

int CDunniganNRTR::sinalNegociacao(void) {
   
   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   double vendaBuffer[], compraBuffer[];
   
   //--- Copia o valor do indicador para seu respectivo buffer
   if (CopyBuffer(this.dunniganHandle, 0, 0, 1, vendaBuffer) < 1
      || CopyBuffer(this.dunniganHandle, 1, 0, 1, compraBuffer) < 1) {
      Print("Falha ao copiar dados do indicador para o buffer! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define os buffers como série temporal
   if (!ArraySetAsSeries(vendaBuffer, true) || !ArraySetAsSeries(compraBuffer, true)) {
      Print("Falha ao definir os buffers como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Verifica os buffers de compra e venda para determinar a tendência da nova barra
   if (compraBuffer[0] > 0 && vendaBuffer[0] == 0) {
      //--- Sinal de compra
      sinal = 1;
   } else if (compraBuffer[0] == 0 && vendaBuffer[0] > 0) {
      //--- Sinal de venda
      sinal = -1;
   }
   
   //--- Retorna o sinal de negociação
   return(sinal);
   
}

int CDunniganNRTR::sinalConfirmacao(int sinalNegociacao) {
   
   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   double upBuffer[], downBuffer[], signalUpBuffer[], signalDownBuffer[];
   
   //--- Copia o valor do indicador para seu respectivo buffer
   if (CopyBuffer(this.nrtrHandle, 2, 0, 1, upBuffer) < 1
      || CopyBuffer(this.nrtrHandle, 3, 0, 1, downBuffer) < 1
      || CopyBuffer(this.nrtrHandle, 0, 0, 1, signalUpBuffer) < 1
      || CopyBuffer(this.nrtrHandle, 1, 0, 1, signalDownBuffer) < 1) {
      Print("Falha ao copiar dados do indicador para o buffer! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define os buffers como série temporal
   if (!ArraySetAsSeries(upBuffer, true) || !ArraySetAsSeries(downBuffer, true)
      || !ArraySetAsSeries(signalUpBuffer, true) || !ArraySetAsSeries(signalDownBuffer, true)) {
      Print("Falha ao definir os buffers como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   if (sinalNegociacao == 1 && (upBuffer[0] > 0 || signalUpBuffer[0] > 0)) {
      //--- Tendência em alta
      sinal = 1;
   } else if (sinalNegociacao == -1 && (downBuffer[0] > 0 || signalDownBuffer[0] > 0)) {
      //--- Tendência em baixa
      sinal = -1;
   } else {
      //--- Tendência não definida
      sinal = 0;
   }
   
   //--- Retorna o sinal de confirmação
   return(sinal);
   
}

int CDunniganNRTR::sinalSaidaNegociacao(int chamadaSaida) {

   //--- Verifica se a chamada veio do método OnTimer()
   if (chamadaSaida == 9) {
   
      //--- Verifica se o ativo atingiu o lucro desejado para poder encerrar a posição
      if (cMoney.atingiuLucroDesejado()) {
         return(0); // Pode encerrar as posições abertas
      }
   }
   
   if (chamadaSaida == 0) {
      //--- Verifica o tamanho do prejuízo para poder encerrar as posições
      for (int i = PositionsTotal() - 1; i >= 0; i--) {
         if (PositionSelectByTicket(PositionGetTicket(i)) && PositionGetString(POSITION_SYMBOL) == _Symbol) {
            double lucro = PositionGetDouble(POSITION_PROFIT);
            if (lucro <= -50) {
               //--- Encerra a posição quando o prejuízo alcançar o limite máximo estabelecido
               return(0); // Pode encerrar as posições abertas
            }
         }
      }
   }

   return(-1);
}

//+------------------------------------------------------------------+

/* Desde ponto em diante ficam as declarações das classes das estratégias
   declaradas neste arquivo MQH
*/

//--- Declaração de classes
CBMFBovespaForex cBMFBovespaForex;
CForexXAU cForexXAU;
CMinicontratoIndice cMiniContratoIndice;
CTendenciaNRTR cTendenciaNRTR;
CDunnigan cDunnigan;
CDunniganNRTR cDunniganNRTR;

//+------------------------------------------------------------------+
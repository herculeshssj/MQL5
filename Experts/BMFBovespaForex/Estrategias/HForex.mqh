//+------------------------------------------------------------------+
//|                                                       HForex.mqh |
//|                            Copyright ® 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property description "Arquivo MQH que contém as estratégias para negociação no mercado Forex."

//--- Inclusão de arquivos
#include "..\\HStrategy.mqh"

//+------------------------------------------------------------------+
//| Classe CBMFBovespaForex - Sinais de negociação baseado no        |
//| cruzamento de MAs de 5 e 20 período. Os sinais de negociação são |
//| confirmados pelo NRTR, evitando assim abertura de novas posições |
//| contrários a tendência.                                          |
//+------------------------------------------------------------------+
class CBMFBovespaForex : public CStrategy {

   private:
      int maAgilHandle;
      int maCurtaHandle;

   public:
      //--- Métodos
      virtual int init(void);
      virtual void release(void);
      virtual int sinalNegociacao(void);
      virtual int sinalConfirmacao(int sinalNegociacao);
      virtual double obterTakeProfit(ENUM_ORDER_TYPE tipoOrdem, double preco);
      virtual double obterStopLoss(ENUM_ORDER_TYPE tipoOrdem, double preco);
};

int CBMFBovespaForex::init(void) {

   this.maAgilHandle = iMA(_Symbol, _Period, 5, 0, MODE_EMA, PRICE_CLOSE);
   this.maCurtaHandle = iMA(_Symbol, _Period, 20, 0, MODE_EMA, PRICE_CLOSE);
   
   //--- Verifica se os indicadores foram criados com sucesso
   if (this.maAgilHandle == INVALID_HANDLE || this.maCurtaHandle == INVALID_HANDLE) {
      Alert("Erro ao criar os indicadores! Erro ", GetLastError());
      return(INIT_FAILED);
   }
   
   //--- Retorna o sinal de sucesso
   return(INIT_SUCCEEDED);
   
}

void CBMFBovespaForex::release(void) {
   //--- Libera os indicadores
   IndicatorRelease(this.maAgilHandle);
   IndicatorRelease(this.maCurtaHandle);
}

int CBMFBovespaForex::sinalNegociacao(void) {

   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   double maAgilBuffer[], maCurtaBuffer[]; // Armazena os valores das médias móveis
   
   //--- Copia o valor dos indicadores para seus respectivos buffers
   if (CopyBuffer(this.maAgilHandle, 0, 0, 3, maAgilBuffer) < 3
         || CopyBuffer(this.maCurtaHandle, 0, 0, 3, maCurtaBuffer) < 3) {
      Print("Falha ao copiar dados do indicador para o buffer! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define os buffers como série temporal
   if (!ArraySetAsSeries(maAgilBuffer, true) || !ArraySetAsSeries(maCurtaBuffer, true)) {
      Print("Falha ao definir os buffers como série temporal! Erro ", GetLastError());
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
   
   //--- Retorna o sinal de confirmação
   return(sinal);
   
}

double CBMFBovespaForex::obterStopLoss(ENUM_ORDER_TYPE tipoOrdem, double preco) {
   //--- Por padrão o valor do stop loss é de 100 pips
   if (tipoOrdem == ORDER_TYPE_BUY) {
      //--- Define o take profit para as ordens de compra
      return(preco - (300 * _Point));
   } else {
      //--- Define o take profit para as ordens de venda
      return(preco + (300 * _Point));
   }
   
   return(0);
}

double CBMFBovespaForex::obterTakeProfit(ENUM_ORDER_TYPE tipoOrdem, double preco) {

   if (tipoOrdem == ORDER_TYPE_BUY) {
      //--- Define o take profit para as ordens de compra
      return(preco + (300 * _Point));
   } else {
      //--- Define o take profit para as ordens de venda
      return(preco - (300 * _Point));
   }

   return(0);
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Classe ForexAMA - Sinais de negociação baseado no Adaptive       |
//| Moving Average (AMA) usando as configurações padrão do indicador,|
//| e com confirmação baseado na tendência NRTR.                     |
//+------------------------------------------------------------------+
class CForexAMA : public CStrategy {

   private:
      int amaHandle;

   public:
      //--- Métodos
      virtual int init(void);
      virtual void release(void);
      virtual int sinalNegociacao(void);
      virtual int sinalConfirmacao(int sinalNegociacao);
      virtual double obterTakeProfit(ENUM_ORDER_TYPE tipoOrdem, double preco);
      virtual double obterStopLoss(ENUM_ORDER_TYPE tipoOrdem, double preco);      
};

int CForexAMA::init(void) {

   this.amaHandle = iAMA(_Symbol, _Period, 9, 2, 30, 0, PRICE_CLOSE);
   
   //--- Verifica se os indicadores foram criados com sucesso
   if (this.amaHandle == INVALID_HANDLE) {
      Alert("Erro ao criar o indicador! Erro ", GetLastError());
      return(INIT_FAILED);
   }
   
   //--- Retorna o sinal de sucesso
   return(INIT_SUCCEEDED);
   
}

void CForexAMA::release(void) {
   //--- Libera os indicadores
   IndicatorRelease(this.amaHandle);
}

int CForexAMA::sinalNegociacao(void) {

   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   double amaBuffer[]; // Armazena os valores do indicador AMA
   
   //--- Copia o valor do indicador para seu respectivo buffer
   if (CopyBuffer(this.amaHandle, 0, 0, 4, amaBuffer) < 4) {
      Print("Falha ao copiar os dados do indicador para o buffer! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define os buffers como série temporal
   if (!ArraySetAsSeries(amaBuffer, true)) {
      Print("Falha ao definir o buffer como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Verifica os dados do indicador para determinar o sinal de negociação
   if (amaBuffer[3] < amaBuffer[2] && amaBuffer[2] < amaBuffer[1]) {
      sinal = 1;
   } else if (amaBuffer[3] > amaBuffer[2] && amaBuffer[2] > amaBuffer[1]) {
      sinal = -1;
   } else {
      sinal = 0;
   }
   
   //--- Retorna o sinal de negociação
   return(sinal);
   
}

int CForexAMA::sinalConfirmacao(int sinalNegociacao) {
   
   /* O sinal de confirmação original foi substituído pelo NRTR */
   
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

double CForexAMA::obterStopLoss(ENUM_ORDER_TYPE tipoOrdem, double preco) {
   //--- Por padrão o valor do stop loss é de 100 pips
   if (tipoOrdem == ORDER_TYPE_BUY) {
      //--- Define o take profit para as ordens de compra
      return(preco - (300 * _Point));
   } else {
      //--- Define o take profit para as ordens de venda
      return(preco + (300 * _Point));
   }
   
   return(0);
}

double CForexAMA::obterTakeProfit(ENUM_ORDER_TYPE tipoOrdem, double preco) {

   if (tipoOrdem == ORDER_TYPE_BUY) {
      //--- Define o take profit para as ordens de compra
      return(preco + (300 * _Point));
   } else {
      //--- Define o take profit para as ordens de venda
      return(preco - (300 * _Point));
   }

   return(0);
}

//+------------------------------------------------------------------+

/* Desde ponto em diante ficam as declarações das classes das estratégias
   declaradas neste arquivo MQH
*/

//--- Declaração de classes
CBMFBovespaForex cBMFBovespaForex;
CForexAMA cForexAMA;

//+------------------------------------------------------------------+
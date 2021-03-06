//+------------------------------------------------------------------+
//|                                                    HStrategy.mqh |
//|                       Copyright ® 2019-2020, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019-2020, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property description "Arquivo MQH que contém as definições para as estratégias de negociação nos mercados BM&FBovespa e Forex."

//--- Inclusão de arquivos
#include "HTrailingStop.mqh"

//--- Declaração de classes
CNRTRStop trailingStop; // Classe para stop móvel usando os sinais do indicador NRTR

//+------------------------------------------------------------------+
//| Interface IStrategy - interface que define os principais métodos |
//| de uma estratégia para negociação.                               |
//+------------------------------------------------------------------+
interface IStrategy {
   
   //--- Método que obtém os sinais para abrir novas posições de compra/venda
   //--- -1 - Sinal de venda
   //--- 0 - Sem sinal, não abre uma posição
   //--- 1 - Sinal de compra
   int sinalNegociacao(void);
   
   //--- Método que obtém sinais para confirmar a abertura novas posições de compra/venda
   //--- -1 - Confirma o sinal de venda
   //--- 0 - Sem sinal, não confirma a abertura da posição
   //--- 1 - Confirma o sinal de compra
   int sinalConfirmacao(int sinalNegociacao);
   
   //--- Método que obtém um sinal para efetuar a saída das posições abertas
   //--- 0 - Confirma a saída da posição
   //--- -1 - manter a posição
   //--- O método recebe uma chamada de saída, informando qual método fez a chamada para 
   //--- verificar o fechamento das posições abertas.
   //--- 0 - novo tick
   //--- 1 - nova barra
   //--- 9 - novo ciclo no timer
   int sinalSaidaNegociacao(int chamadaSaida);
   
   //--- Método que envia uma mensagem para o usuário. Esta mensagem pode ser disparada
   //--- quando ocorrer os seguinte eventos:
   //--- 0 - novo tick
   //--- 1 - nova barra
   //--- 9 - novo ciclo no timer
   //--- A variável 'sinalChamada' é reponsável por identificar o evento que disparou a 
   //--- notificação ao usuário.
   void notificarUsuario(int sinalChamada);
   
   //--- Método que retorna o valor para o stop loss de acordo com os critérios
   //--- da estratégia
   double obterStopLoss(ENUM_ORDER_TYPE tipoOrdem, double preco);
   
   //--- Método que retorna o valor para o take profit de acordo com os critérios
   //--- da estratégia
   double obterTakeProfit(ENUM_ORDER_TYPE tipoOrdem, double preco);
   
   //--- Método que efetua a abertura de novas posições e/ou fechamento das posições
   //--- existentes de acordo com a estratégia definida. Este método é útil para poder
   //--- realizar aberturas de ordens limit e stop, as ordens padrão do EA são a mercado
   void realizarNegociacao();
};

//+------------------------------------------------------------------+
//| Classe CStrategy - classe abstrata que reúne as definições gerais|
//| para as demais classes de estratégia.                            |
//+------------------------------------------------------------------+
class CStrategy : public IStrategy {

   public:
      //--- Inicialização das variáveis privadas e dos indicadores
      virtual int init(void);
      
      //--- Desalocação das variáveis privadas e dos indicadores
      virtual void release(void);
      
      //--- Informa que a estratégia opera após a chegada de um novo tick, ou após
      //--- uma nova barra, ou após a contagem do timer
      //--- 0 - novo tick
      //--- 1 - nova barra
      //--- 9 - timer
      virtual int onTickBarTimer(void) {
         //--- Por padrão retorna 1
         return(1);
      }
      
      virtual int sinalConfirmacao(int sinalNegociacao) {
         //--- O sinal é passado direto por padrão, uma vez que todas as condições 
         //--- de entrada na negociação foram previamente atendidas.
         int sinal = sinalNegociacao;
         
         //--- Retorna o sinal de confirmação
         return(sinal);
      }
      
      virtual int sinalSaidaNegociacao(int chamadaSaida) {
         //--- Por padrão retorna o valor -1, indicando que a posição continuará
         //--- aberta.
         return(-1);
      }
      
      virtual void notificarUsuario(int sinalChamada) {
         //--- Por padrão imprime uma mensagem no console
         cUtil.enviarMensagem(CONSOLE, "Uma notificação foi enviada ao usuário.");
      }
      
      virtual double obterStopLoss(ENUM_ORDER_TYPE tipoOrdem, double preco) {
         //--- Por padrão o valor do stop loss é de 100 pips
         if (tipoOrdem == ORDER_TYPE_BUY) {
            //--- Define o take profit para as ordens de compra
            return(preco - (100 * _Point));
         } else {
            //--- Define o take profit para as ordens de venda
            return(preco + (100 * _Point));
         }
         
         return(0);
      }
      
      virtual double obterTakeProfit(ENUM_ORDER_TYPE tipoOrdem, double preco) {
         //--- Por padrão o valor do take profit é de 100 pips
         if (tipoOrdem == ORDER_TYPE_BUY) {
            //--- Define o take profit para as ordens de compra
            return(preco + (100 * _Point));
         } else {
            //--- Define o take profit para as ordens de venda
            return(preco - (100 * _Point));
         }
         
         return(0);
      }
      
      virtual void realizarNegociacao() {
         //--- Por padrão o método não tem nenhum código.
      }
};

//+------------------------------------------------------------------+
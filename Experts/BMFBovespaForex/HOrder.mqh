//+------------------------------------------------------------------+
//|                                                       HOrder.mqh |
//|                            Copyright ® 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property description "Classe com métodos utilitários para negociação com robôs."

//--- Inclusão de arquivos
#include "HMoney.mqh"

//--- Declaração de classes
CMoney cMoney; // Classe com métodos utilitários para gerenciamento financeiro da conta

//+------------------------------------------------------------------+
//| Classe COrder - responsável por realizar envio de ordens.        |
//+------------------------------------------------------------------+
class COrder {
      
   public:
      void COrder() {};            // Construtor
      void ~COrder() {};           // Construtor
      ENUM_ORDER_TYPE_FILLING obterTipoPreenchimentoOrdem();
      bool possuiMargemParaAbrirNovaPosicao(double tamanhoContrato, string simbolo, ENUM_POSITION_TYPE tipoPosicao);
};

//+------------------------------------------------------------------+
//| Retorna o tipo de preenchimento de ordem permitida pelo símbolo  |
//| (ativo) selecionado.                                             |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING COrder::obterTipoPreenchimentoOrdem(void) {

   switch( (int)SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE)) {
      case SYMBOL_FILLING_FOK: return ORDER_FILLING_FOK;
      case SYMBOL_FILLING_IOC: return ORDER_FILLING_IOC;
      default: return ORDER_FILLING_RETURN;
   }
}

//+------------------------------------------------------------------+
//| Verifica se existe margem disponível para abertura de novas      |
//| posições para o símbolo selecionado. Retorna true caso tenha     |
//| margem disponível para efetuar a abertura com o tamanho de       |
//| contrato selecionado.                                            |
//+------------------------------------------------------------------+
bool COrder::possuiMargemParaAbrirNovaPosicao(double tamanhoContrato, string simbolo, ENUM_POSITION_TYPE tipoPosicao) {

   if (cAccount.obterMargemLivre() > cAccount.obterMargemNecessariaParaNovaPosicao(tamanhoContrato, tipoPosicao)) {
      return(true);
   }
   
   return(false);

}
//+------------------------------------------------------------------+
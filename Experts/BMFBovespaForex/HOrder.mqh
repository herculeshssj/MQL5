//+------------------------------------------------------------------+
//|                                                       HOrder.mqh |
//|                            Copyright ® 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property description "Classe com métodos utilitários para negociação com robôs."

//--- Enumerações
enum ENUM_TIPO_PREENCHIMENTO_ORDEM {
   TIPO_TUDO_NADA = ORDER_FILLING_FOK, // Tudo/Nada
   TIPO_TUDO_PARCIAL = ORDER_FILLING_IOC, // Tudo/Parcialmente
   TIPO_RETORNAR = ORDER_FILLING_RETURN // Retornar
};

//+------------------------------------------------------------------+
//| Classe COrder - responsável por realizar envio de ordens.        |
//+------------------------------------------------------------------+
class COrder {
      
   public:
      void COrder() {};            // Construtor
      void ~COrder() {};           // Construtor
      
};
//+------------------------------------------------------------------+
//|                                             IBMFBovespaForex.mq5 |
//|                            Copyright ® 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property version   "1.00"

//--- Configurações gerais do indicador
#property indicator_chart_window

//--- Configurações de plotagem


//--- Parâmetros de entrada


//--- Buffers do indicador


//+------------------------------------------------------------------+
//| Inicialização do indicador                                       |
//+------------------------------------------------------------------+
int OnInit() {

   //--- Mapeamento dos buffers do indicador
   
   
   //--- Indicador criado com sucesso
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Função que realiza os cálculos do indicador                      |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {

   //--- Entre com o código aqui
   
   
   //--- Retorna o valor para prev_calculated para a próxima chamada
   return(rates_total);
}
//+------------------------------------------------------------------+
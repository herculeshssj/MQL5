//+------------------------------------------------------------------+
//|                                                    IDunnigan.mq5 |
//|                            Copyright ® 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property version   "1.02"
#property description "Indicador Dunnigan"
#property description "Metodologia: sinais de compra são confirmados se a alta anterior for menor que a alta atual e se a mínima anterior for menor que a mínima atual. Os sinais de venda se confirma quando a alta anterior é maior que a alta atual e a mínima anterior for maior que a mínima atual."
#property description "Changelog:"
#property description "v1.00 - Implementação do indicador."
#property description "v1.01 - Inversão dos arrays de buffer para trabalhar com EADunniganNRTRIniciante."
#property description "v1.02 - Inclusão de arrays de buffer com último preço de compra e venda."

#property indicator_chart_window

#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1  "Venda"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3

#property indicator_label2  "Compra"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  3

double VendaBuffer[];
double CompraBuffer[];
double ultimoPrecoVenda[1];
double ultimoPrecoCompra[1];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   //--- indicator buffers mapping
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   IndicatorSetString(INDICATOR_SHORTNAME, "DunniganIndicator");
   
   SetIndexBuffer(0, VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1, CompraBuffer,INDICATOR_DATA);
   SetIndexBuffer(2, ultimoPrecoVenda, INDICATOR_DATA);
   SetIndexBuffer(3, ultimoPrecoCompra, INDICATOR_DATA);

   PlotIndexSetInteger(0,PLOT_ARROW,230);
   PlotIndexSetInteger(1,PLOT_ARROW,228);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
                
   for (int i = 1; i < rates_total; i++) {
   
      // Caso a mínima e a máxima anteriores sejam menores que a mínima e máxima
      // atual, registrar o sinal de venda
      if (low[i] < low[i -1] && high[i] < high[i - 1]) {
         VendaBuffer[i] = high[i];
         ultimoPrecoVenda[0] = high[i];
      } else {
         VendaBuffer[i] = 0;
      }
      
      // Caso a mínima e a máxima anteriores sejam maiores que a mínima e máxima
      // atual, registrar o sinal de compra
      if (low[i] > low[i - 1] && high[i] > high[i - 1]) {
         CompraBuffer[i] = low[i];
         ultimoPrecoCompra[0] = low[i];
      } else {
         CompraBuffer[i] = 0;
      }
   
   }

   //--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                    IDunnigan.mq5 |
//|                            Copyright ® 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|Changelog:                                                        |
//|v1.00 - Implementação do indicador.                               |
//|v1.01 - Inversão dos arrays de buffer para trabalhar com          |
//|        EADunniganNRTRIniciante.                                  |
//|v1.02 - Inclusão de arrays de buffer com último preço de compra e |
//|        venda.                                                    |
//|v1.03 - Removido os arrays de buffer com último preço de compra e |
//|        venda. A busca do último preço deve ser feita direto de   |
//|        VendaBuffer e CompraBuffer.                               |
//|v1.04 - Alterado os sinais de compra e venda para utilizar os     | 
//|        preços de abertura e fechamento.                          |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property version   "1.05"
#property description "Indicador Dunnigan"
#property description "Sinais de compra são confirmados se a alta anterior for menor que a alta atual e se a mínima anterior for menor que a mínima atual. Os sinais de venda se confirma quando a alta anterior é maior que a alta atual e a mínima anterior for maior que a mínima atual. O método de cálculo permite usar os valores de abertura/fechamento no lugar da máxima/mínima."
#property description "Novidades:"
#property description "v1.05 - Criação de parâmetro para escolha do método de cálculo do indicador: abertura/fechamento ou máxima/mínima."

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

enum ENUM_METODO_CALCULO {
   HIGH_LOW = 0, // Máxima/Mínima
   OPEN_CLOSE = 1 // Abertura/Fechamento
};

input ENUM_METODO_CALCULO metodoCalculo = HIGH_LOW; // Método de cálculo

double VendaBuffer[];
double CompraBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   //--- indicator buffers mapping
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   IndicatorSetString(INDICATOR_SHORTNAME, "DunniganIndicator");
   
   SetIndexBuffer(0, VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1, CompraBuffer,INDICATOR_DATA);

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
                
   //-- Verifica o método de cálculo do indicador
   if (metodoCalculo == HIGH_LOW) {
      
      //-- Cálculo baseado nas máximas e mínimas
      
      for (int i = 1; i < rates_total; i++) {
   
         // Caso a mínima e a máxima anteriores sejam menores que a mínima e máxima
         // atual, registrar o sinal de venda
         if (low[i] < low[i -1] && high[i] < high[i - 1]) {
            VendaBuffer[i] = high[i];
         } else {
            VendaBuffer[i] = 0;
         }
         
         // Caso a mínima e a máxima anteriores sejam maiores que a mínima e máxima
         // atual, registrar o sinal de compra
         if (low[i] > low[i - 1] && high[i] > high[i - 1]) {
            CompraBuffer[i] = low[i];
         } else {
            CompraBuffer[i] = 0;
         }
   
      }
         
   } else {
   
      //-- Cálculo baseado na abertura e fechamento
      
      for (int i = 1; i < rates_total; i++) {
   
         VendaBuffer[i] = calculaPrecoVenda(open[i], open[i - 1], close[i], close[i - 1], high[i]);
         CompraBuffer[i] = calculaPrecoCompra(open[i], open[i - 1], close[i], close[i - 1], low[i]);
   
      }
   }
   
   //--- return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Método para determinar o preço de venda                          |
//+------------------------------------------------------------------+
double calculaPrecoVenda(const double aberturaAtual,
                         const double aberturaAnterior,
                         const double fechamentoAtual,
                         const double fechamentoAnterior,
                         const double altaAtual) {
   
   //-- Declaração das variáveis auxiliares
   double candleAtualAbertura = 0;
   double candleAtualFechamento = 0;
   double candleAnteriorAbertura = 0;
   double candleAnteriorFechamento = 0;
   
   //-- Determina qual a posição do candle para poder inverter
   if (aberturaAtual >= fechamentoAtual) {
      // Mantém os valores do candle
      candleAtualAbertura = aberturaAtual;
      candleAtualFechamento = fechamentoAtual;
   } else {
      // Salva os valores invertido
      candleAtualAbertura = fechamentoAtual;
      candleAtualFechamento = aberturaAtual;
   }
   
   if (aberturaAnterior >= fechamentoAnterior) {
      // Mantém os valores do candle
      candleAnteriorAbertura = aberturaAnterior;
      candleAnteriorFechamento = fechamentoAnterior;
   } else {
      // Salva os valores invertido
      candleAnteriorAbertura = fechamentoAnterior;
      candleAnteriorFechamento = aberturaAnterior;
   }
   
   //-- Verifica se o candle atual é menor que o candle anterior
   //-- para disparar o sinal de venda
   if (candleAtualAbertura < candleAnteriorAbertura 
      && candleAtualFechamento < candleAnteriorFechamento) {
      return(altaAtual);
   }
   
   return(0);
}

//+------------------------------------------------------------------+
//| Método para determinar o preço de compra                         |
//+------------------------------------------------------------------+
double calculaPrecoCompra(const double aberturaAtual,
                          const double aberturaAnterior,
                          const double fechamentoAtual,
                          const double fechamentoAnterior,
                          const double baixaAtual) {
   
   //-- Declaração das variáveis auxiliares
   double candleAtualAbertura = 0;
   double candleAtualFechamento = 0;
   double candleAnteriorAbertura = 0;
   double candleAnteriorFechamento = 0;
   
   //-- Determina qual a posição do candle para poder inverter
   if (aberturaAtual >= fechamentoAtual) {
      // Mantém os valores do candle
      candleAtualAbertura = aberturaAtual;
      candleAtualFechamento = fechamentoAtual;
   } else {
      // Salva os valores invertido
      candleAtualAbertura = fechamentoAtual;
      candleAtualFechamento = aberturaAtual;
   }
   
   if (aberturaAnterior >= fechamentoAnterior) {
      // Mantém os valores do candle
      candleAnteriorAbertura = aberturaAnterior;
      candleAnteriorFechamento = fechamentoAnterior;
   } else {
      // Salva os valores invertido
      candleAnteriorAbertura = fechamentoAnterior;
      candleAnteriorFechamento = aberturaAnterior;
   }
   
   //-- Verifica se o candle atual é menor que o candle anterior
   //-- para disparar o sinal de venda
   if (candleAtualAbertura > candleAnteriorAbertura 
      && candleAtualFechamento > candleAnteriorFechamento) {
      return(baixaAtual);
   }
   
   return(0);
}
//+------------------------------------------------------------------+
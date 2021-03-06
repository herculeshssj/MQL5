//+------------------------------------------------------------------+
//|                                  ExemploIndicadorCustomizado.mq5 |
//|                              Copyright 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property version   "1.00"
#property indicator_chart_window 
#property indicator_buffers 1 
#property indicator_plots   1 
//---- plotar Linha 
#property indicator_label1  "Line" 
#property indicator_type1   DRAW_LINE 
#property indicator_color1  clrDarkBlue 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1 
//--- buffers do indicador 
double         LineBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   //--- mapeamento de buffers do indicador 
   SetIndexBuffer(0,LineBuffer,INDICATOR_DATA);
//---
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
                const int &spread[])
  {
//---
   
//--- Obtenção do número de barras disponíveis para o ativo corrente e período do gráfico 
   int bars=Bars(Symbol(),0); 
   Print("Bars = ",bars,", rates_total = ",rates_total,",  prev_calculated = ",prev_calculated); 
   Print("time[0] = ",time[0]," time[rates_total-1] = ",time[rates_total-1]); 
//--- valor retorno de prev_calculated para a próxima chamada 
   return(rates_total); 

  }
//+------------------------------------------------------------------+

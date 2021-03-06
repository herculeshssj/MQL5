//+------------------------------------------------------------------+
//|                                                     DataHora.mq5 |
//|                              Copyright 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   datetime NY=D'2015.01.01 00:00';     // Data Hora de começo do ano 2015 
   datetime d1=D'1980.07.19 12:30:27';  // Ano Mês Dia Horas Minutos Segundos 
   datetime d2=D'19.07.1980 12:30:27';  // Igual a D'1980.07.19 12:30:27'; 
   datetime d3=D'19.07.1980 12';        // Igual a D'1980.07.19 12:00:00' 
   datetime d4=D'01.01.2004';           // Igual a D'01.01.2004 00:00:00' 
   datetime compilation_date=__DATE__;             // Data de Compilação 
   datetime compilation_date_time=__DATETIME__;    // Data e Hora de Compilação 
   datetime compilation_time=__DATETIME__-__DATE__;// Hora de Compilação 
   //--- Exemplos de declarações após o qual avisos do compilador serão retornados 
   datetime warning1=D'12:30:27';       // Igual a D'[data de compilação] 12:30:27' 
   datetime warning2=D'';               // Igual a __DATETIME__
   
   Print(NY);
   Print(d1);
   Print(d2);
   Print(d3);
   Print(d4);
   Print("Data da compilação: " + compilation_date);
   Print("Data/Hora da compilação: " + compilation_date_time);
   Print("Hora da compilação: " + compilation_time);
   Print("Data incompleta 1: " + warning1);
   Print("Data incompleta 2: " + warning2);
  }
//+------------------------------------------------------------------+

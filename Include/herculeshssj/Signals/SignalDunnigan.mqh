//+------------------------------------------------------------------+
//|                                               SignalDunnigan.mqh |
//|                            Copyright ® 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property version   "1.00"

//--- Include
#include "..\..\Expert\ExpertSignal.mqh" // classe CExpertSignal

// wizard description start
//+-------------------------------------------------------------------+
//| Sinal de negociação que utiliza o indicador Dunnigan              |
//| Title=Signals of indicator 'Dunnigan'                             |
//| Type=SignalAdvanced                                               |
//| Name=Dunnigan                                                     |
//| ShortName=Dunnigan                                                |
//| Class=SignalDunnigan                                              |
//+-------------------------------------------------------------------+
// wizard description end
//+-------------------------------------------------------------------+
//| Class SignalDunnigan.                                             |
//| Purpose: Class of generator of trade signals based on             |
//|          the 'Dunnigan' indicator.                                |
//| Is derived from the CExpertSignal class.                          |
//+-------------------------------------------------------------------+
class SignalDunnigan : public CExpertSignal
  {
protected:
   CiCustom dunniganIndicator; // object indicator
   
   //--- Methods of getting data
   double UpSignal(int index) {
      return(dunniganIndicator.GetData(1, index));
   }
   double DnSignal(int index) {
      return(dunniganIndicator.GetData(0, index));
   }

public:
   SignalDunnigan();
   ~SignalDunnigan();
   
   bool ValidationSettings();
   bool InitIndicators(CIndicators *indicators);
   bool InitDunnigan(CIndicators *indicators); 
   int LongCondition(void);
   int ShortCondition(void);
   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalDunnigan::SignalDunnigan()
  {
      //--- Initialization of protected data
      m_used_series = USE_SERIES_OPEN + USE_SERIES_HIGH + USE_SERIES_LOW + USE_SERIES_CLOSE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SignalDunnigan::~SignalDunnigan()
  {
  }
  
//+------------------------------------------------------------------+
//| O método verifica os parâmetros de entrada                       |
//+------------------------------------------------------------------+
bool SignalDunnigan:: ValidationSettings()
  {
      // Chamamos o método da classe base
      if (!CExpertSignal::ValidationSettings()) {
         return(false);
      }
      
      return(true);
  }
    
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool SignalDunnigan::InitIndicators(CIndicators *indicators) {
   //--- Check pointer
   if (indicators == NULL) {
      return(false);
   }
   
   // Initialization of indicators and timeseries of additional filters
   if (!CExpertSignal::InitIndicators(indicators)) {
      return(false);
   }
   
   //--- Create and initialize Dunnigan indicator
   if (!InitDunnigan(indicators)) {
      return(false);
   }
   
   return(true);
}

//+------------------------------------------------------------------+
//| Create NRTR indicators.                                          |
//+------------------------------------------------------------------+  
bool SignalDunnigan::InitDunnigan(CIndicators *indicators) {
   //--- Check pointer
   if (indicators == NULL) {
      return(false);
   }
   
   //--- Add object to collection
   if (!indicators.Add(GetPointer(dunniganIndicator))) {
      Print(__FUNCTION__ + ": error adding object!");
      return(false);
   }
   
   //--- Criação de parâmetros do indicador
   MqlParam parameters[2];
   
   parameters[0].type = TYPE_STRING;
   parameters[0].string_value = "herculeshssj\\IDunnigan.ex5";
   parameters[1].type = TYPE_INT;
   parameters[1].integer_value = 0; // High/Low
   
   //--- Initialize object
   if (!dunniganIndicator.Create(m_symbol.Name(), m_period, IND_CUSTOM, 2, parameters)) {
      Print(__FUNCTION__ + ": error initializing object!");
      return(false);
   }
   
   //--- OK
   return(true);
}

//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int SignalDunnigan::LongCondition(void) {
   int idx = StartIndex();
   if (UpSignal(idx)) {
      return 100;
   } else {
      return 0;
   }
}
   
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int SignalDunnigan::ShortCondition(void) {
   int idx = StartIndex();
   if (DnSignal(idx)) {
      return 100;
   } else {
      return 0;
   }
}
//+------------------------------------------------------------------+
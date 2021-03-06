//+------------------------------------------------------------------+
//|                                                      CPerson.mq5 |
//|                              Copyright 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property version   "1.00"

//+------------------------------------------------------------------+ 
//| Uma classe para armazenar o nome de um caractere                 | 
//+------------------------------------------------------------------+ 
class CPerson 
  { 
   string            m_first_name;     // Primeiro nome 
   string            m_second_name;    // Segundo nome 
public: 
   //--- Um construtor default vazio 
                     CPerson() 
                     {
                        Print(__FUNCTION__);
                       }; 
   //--- Um construtor paramétrico 
                     CPerson(string full_name); 
   //--- Um construtor com uma lista de inicialização 
                     CPerson(string surname,string name): m_second_name(surname), m_first_name(name) {}; 
   void PrintName()
     {
       PrintFormat("Name=%s Surname=%s",m_first_name,m_second_name);
     }; 
  };
  
 
//+------------------------------------------------------------------+ 
//|                                                                  | 
//+------------------------------------------------------------------+ 
CPerson::CPerson(string full_name) 
  { 
   int pos=StringFind(full_name," "); 
   if(pos>=0) 
     { 
      m_first_name=StringSubstr(full_name,0,pos); 
      m_second_name=StringSubstr(full_name,pos+1); 
     } 
  } 

//+------------------------------------------------------------------+ 
//| A classe base                                                    | 
//+------------------------------------------------------------------+ 
class CFoo 
  { 
   string            m_name; 
public: 
   //--- Um construtor com uma lista de inicialização 
                     CFoo(string name) : m_name(name) { Print(m_name);} 
  }; 
//+------------------------------------------------------------------+ 
//| Uma classe derivada a partir de CFoo                             | 
//+------------------------------------------------------------------+ 
class CBar : CFoo 
  { 
   CFoo              m_member;      // Um membro de classe é um objeto do pai 
public: 
   //--- O construtor default na lista de inicialização chama o construtor do pai 
                     CBar(): m_member(_Symbol), CFoo("CBAR") {Print(__FUNCTION__);} 
  }; 


//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   //--- Obtém o erro "default constructor is not defined" 
   CPerson people[5]; 
   CPerson Tom="Tom Sawyer";                       // Tom Sawyer 
   CPerson Huck("Huckleberry","Finn");             // Huckleberry Finn 
   CPerson *Pooh = new CPerson("Winnie","Pooh");  // Winnie the Pooh 
   //--- Valores de sáida 
   Tom.PrintName(); 
   Huck.PrintName(); 
   Pooh.PrintName(); 
    
   //--- Apaga um objeto criado dinamicamente 
   delete Pooh; 

   CBar bar; 

  }
//+------------------------------------------------------------------+

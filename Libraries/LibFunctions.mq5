//+------------------------------------------------------------------+
//|                                                 LibFunctions.mq5 |
//|                                                   Sergey Greecie |
//|                                               sergey1294@list.ru |
//+------------------------------------------------------------------+
#property library
#property copyright "Sergey Greecie"
#property link      "sergey1294@list.ru"
#property version   "1.00"
//+---------------------------------------------------------------------------------------------------+
//| Function for creation of the Label text object                                                    |
//|    Parameters:                                                                                    |                                                          
//|    nm - name of the object                                                                        |                                               
//|    tx - text                                                                                      |
//|    cn - corner of the chart for binding of the graphical object                                   |
//|         CORNER_LEFT_UPPER - center of coordinates at the upper left corner of the chart           |
//|         CORNER_LEFT_LOWER - center of coordinates at the lower left corner of the chart           |
//|         CORNER_RIGHT_LOWER - center of coordinates at the lower right corner of the chart         |
//|         CORNER_RIGHT_UPPER - center of coordinates at the upper right corner of the chart         |
//|    cr - position of the binding point of the graphical object                                     |
//|         ANCHOR_LEFT_UPPER - anchor point at the upper left corner                                 |
//|         ANCHOR_LEFT - anchor point at the left center                                             |
//|         ANCHOR_LEFT_LOWER - anchor point at the lower left corner                                 |
//|         ANCHOR_LOWER - anchor point at the bottom center                                          |
//|         ANCHOR_RIGHT_LOWER - anchor point at the lower right corner                               |
//|         ANCHOR_RIGHT - anchor point at the right center                                           |
//|         ANCHOR_RIGHT_UPPER - anchor point at the upper right corner                               |
//|         ANCHOR_UPPER - anchor point at the upper center                                           |
//|         ANCHOR_CENTER - anchor point at the very center of the object                             |
//|    xd - X coordinate in pixels                                                                    |                                           
//|    yd - Y coordinate in pixels                                                                    |
//|    fn - font name                                                                                 |                    
//|    fs - font size in pixels                                                                       | 
//|    yg - slope angle of text in degrees. negative value for clockwise direction and                |
//|         positive for the counter clockwise direction                                              |                               
//|    ct - text color                                                                                |
//+---------------------------------------------------------------------------------------------------+
void SetLabel(string nm,string tx,ENUM_BASE_CORNER cn,ENUM_ANCHOR_POINT cr,int xd,int yd,string fn,int fs,double yg,color ct)export
  {
   if(fs<1)fs=1;
   if(ObjectFind(0,nm)<0)ObjectCreate(0,nm,OBJ_LABEL,0,0,0);  //--- create the Label object
   ObjectSetString (0,nm,OBJPROP_TEXT,tx);                    //--- set text for the Label object 
   ObjectSetInteger(0,nm,OBJPROP_CORNER,cn);                  //--- set binding to an angle of the chart              
   ObjectSetInteger(0,nm,OBJPROP_ANCHOR,cr);                  //--- set position of the anchor point of the graphical object
   ObjectSetInteger(0,nm,OBJPROP_XDISTANCE,xd);               //--- set X coordinate
   ObjectSetInteger(0,nm,OBJPROP_YDISTANCE,yd);               //--- set Y coordinate
   ObjectSetString (0,nm,OBJPROP_FONT,fn);                    //--- set font of the inscription
   ObjectSetInteger(0,nm,OBJPROP_FONTSIZE,fs);                //--- set font size    
   ObjectSetDouble (0,nm,OBJPROP_ANGLE,yg);                   //--- set slope angle
   ObjectSetInteger(0,nm,OBJPROP_COLOR,ct);                   //--- set text color
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);           //--- disable selection of the object using a mouse   
  }
//+-----------------------------------------------------------------------------+
//| function for determining the arrow type by the code of the Wingdings font   |
//+-----------------------------------------------------------------------------+
string arrow(int sig)export
  {
   switch(sig)
     {
      case  0: return(CharToString(251));
      case  1: return(CharToString(233));
      case -1: return(CharToString(234));
     }
   return((string)0);
  }
//+------------------------------------------------------------------+
//| function for determining the color of arrow                      |
//+------------------------------------------------------------------+
color Colorarrow(int sig)export
  {
   switch(sig)
     {
      case -1: return(Red);
      case  0:  return(MediumAquamarine);
      case  1:  return(Blue);
     }
   return(0);
  }
//+------------------------------------------------------------------+

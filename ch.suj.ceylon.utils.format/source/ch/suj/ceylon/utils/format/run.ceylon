"Run the module `ch.suj.ceylon.utils.format`."
shared void run() {
    
    Float x = 10.1255;
    Float y = 1220.55;
    
    Float z = x + y;
    
    numberFormatHelper.printFormatted("Summe: \n%10.4f\n%10.4f \n----------\n%10.4f", x, y, z);
}
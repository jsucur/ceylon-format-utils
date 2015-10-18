"Run the module `ch.suj.ceylon.utils.format`."
shared void run() {
    
    // example 1: floats
    print("\nExample 1:\n----------");
    value x = 1220.55;
    value y = 10.1255;
    value z = 321.256488;
    
    numberFormatHelper.printFormatted("%10.4f\n%10.4f\n%10.4f", x, y, z);
    
    
    // example 2: floats embedded in text
    print("\n\nExample 2:\n----------");
    
    numberFormatHelper.printFormatted("Result: %.2f + %.2f = %.2f", x, y, (x+y));
    
    
    // example 3: integers
    print("\n\nExample 3:\n----------");
    value a = 5550;
    value b = 12880;
    value c = 72;
    value d = 3822;
    
    numberFormatHelper.printFormatted("%6d\n%6d\n%6d\n%6d", a, b, c, d);
    
    // example 4: integers as floats
    print("\n\nExample 4:\n----------");
    
    numberFormatHelper.printFormatted("%10.2f\n%10.2f\n%10.2f\n%10.2f", a, b, c, d);
}
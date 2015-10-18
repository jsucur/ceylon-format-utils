import ceylon.collection {
	LinkedList
}

shared object numberFormatHelper {
	
	"This function imbeds the delivered arguments into delivered text-String and prints it to the standard output of the virtual machine process."
	shared void printFormatted(
		"string to print out including one or more format-strings"
		String text,
		"one or more arguments"
		Float|Integer* args) {
		
		variable Integer i = 0;
		/* List for tupel with content-string, format-string and argument (example: ['The sum of ', '%.2f', 250.25]) */
		value list = LinkedList<[String, String, Integer|Float]>();
		
		/* List for arguments */
		value numbers = LinkedList<Float|Integer>();
		
		for (arg in args) {
			numbers.add(arg);
		}
		
		variable [String, String, String] tupel = numberFormatHelper.extract(text);
		
		while (!tupel[2].empty) {
			value n = numbers.get(i++);
			
			assert (n exists);
			
			if (is Integer n) {
				list.add([tupel[0], tupel[1], n]);
				tupel = numberFormatHelper.extract(tupel[2]);
			} else if (is Float n) {
				list.add([tupel[0], tupel[1], n]);
				tupel = numberFormatHelper.extract(tupel[2]);
			}
		}
		
		value n = numbers.get(i++);
		
		assert (n exists);
		
		if (is Integer n) {
			list.add([tupel[0], tupel[1], n]);
			tupel = numberFormatHelper.extract(tupel[2]);
		} else if (is Float n) {
			list.add([tupel[0], tupel[1], n]);
			tupel = numberFormatHelper.extract(tupel[2]);
		}
		
		for (t in list) {
			process.write(t[0]);
			numberFormatHelper.writeFormatted(t[1], t[2]);
		}
	}
	
	"This function imbeds the delivered arguments into delivered text-String and returns it back"
	shared String format(
		"string to print out including one or more format-strings"
		String text,
		"one or more arguments"
		Float|Integer* args) {
		
		variable Integer i = 0;
		/* List for tupel with content-string, format-string and argument (example: ['The sum of ', '%.2f', 250.25]) */
		value list = LinkedList<[String, String, Integer|Float]>();
		
		/* List for arguments */
		value numbers = LinkedList<Float|Integer>();
		
		for (arg in args) {
			numbers.add(arg);
		}
		
		variable [String, String, String] tupel = numberFormatHelper.extract(text);
		
		while (!tupel[2].empty) {
			value n = numbers.get(i++);
			
			assert (n exists);
			
			if (is Integer n) {
				list.add([tupel[0], tupel[1], n]);
				tupel = numberFormatHelper.extract(tupel[2]);
			} else if (is Float n) {
				list.add([tupel[0], tupel[1], n]);
				tupel = numberFormatHelper.extract(tupel[2]);
			}
		}
		
		value n = numbers.get(i++);
		
		assert (n exists);
		
		if (is Integer n) {
			list.add([tupel[0], tupel[1], n]);
			tupel = numberFormatHelper.extract(tupel[2]);
		} else if (is Float n) {
			list.add([tupel[0], tupel[1], n]);
			tupel = numberFormatHelper.extract(tupel[2]);
		}
		
		variable String str = "";
		
		for (t in list) {
			str = str.plus(t[0]).plus(formatSingleNumber(t[1], t[2]));
		}
		
		return str;
	}
	
	
	"This function gets a string and returns a tupel with three strings: the content 
	             before format-string, format-string and the remainder of the string (after the 
	             format-string), if exists. 
	             
	             Example: the 'inputString' is 'The sum of %.2f and %.2f is %.2f'
	             
	             The function returns the folowing tupel: ['The sum of ', '%.2f', ' and %.2f is %.2f']"
	[String, String, String] extract(String inputString) {
		
		variable String strContent = "";
		variable String strPattern = "";
		variable String rightPartOfInputString = inputString;
		
		value patternStartSign = '%';
		
		if (inputString.contains(patternStartSign)) {
			// format pattern exists
			Integer? patternStartPosition = inputString.firstOccurrence(patternStartSign);
			
			if (exists patternStartPosition) {
				
				strContent = inputString.spanTo(patternStartPosition - 1);
				
				// the remain of the string from the patternStartPosition
				String strRemain = inputString.spanFrom(patternStartPosition);
				
				if (!strRemain.empty) {
					
					variable Integer? patternEndPosition;
					variable Integer? patternEndPositionForInt = strRemain.firstOccurrence('d');
					variable Integer? patternEndPositionForFloat = strRemain.firstOccurrence('f');
					
					if (exists endPosInt = patternEndPositionForInt, exists endPosFloat = patternEndPositionForFloat) {
						if (endPosInt < endPosFloat) {
							patternEndPosition = patternEndPositionForInt;
						} else {
							patternEndPosition = patternEndPositionForFloat;
						}
					} else if (exists endPosInt = patternEndPositionForInt) {
						patternEndPosition = patternEndPositionForInt;
					} else {
						patternEndPosition = patternEndPositionForFloat;
					}
					
					if (!patternEndPosition exists) {
						patternEndPosition = strRemain.firstOccurrence('f');
					}
					
					if (patternEndPosition exists) {
						Integer? endPosition = patternEndPosition;
						if (exists endPosition) {
							strPattern = strRemain.spanTo(endPosition);
							rightPartOfInputString = inputString.spanFrom(patternStartPosition + endPosition + 1);
						}
					} else {
						strPattern = "";
					}
				}
			}
		}
		
		return [strContent, strPattern, rightPartOfInputString];
	}
	
	"Returns the deliviered number formated"
	String formatSingleNumber(
		"format-string (for example %8.2f, or %.2 or %6d)"
		String pattern,
		"numeric value"
		Integer|Float number) {
		assert (pattern.startsWith("%"));
		assert (pattern.endsWith("f") || pattern.endsWith("d"));
		
		variable String numberFormated = "";
		
		if (pattern.endsWith("f")) {
			if (is Float number) {
				numberFormated = formatFloat(pattern, number);
			} else if (is Integer number) {
				Float temp = number + 0.0;
				numberFormated = formatFloat(pattern, temp);
			}
		} else {
			
			if (is Float number) {
				Integer temp = number.integer;
				numberFormated = formatInteger(pattern, temp);
			} else if (is Integer number) {
				numberFormated = formatInteger(pattern, number);
			}
		}
		
		return numberFormated;
	}
	
	String formatFloat(String pattern, Float number) {
		
		assert (pattern.startsWith("%"));
		assert (pattern.endsWith("f"));
		
		variable String numberFormated = "";
		
		variable Integer? width = 0;
		variable Integer? numberOfDecimals = 0;
		
		variable String? rest = null;
		
		Integer? pointPosInPattern = pattern.firstOccurrence('.');
		
		/* retrieve the width and the number of decimals from the format string */
		if (exists pointPosInPattern) {
			
			String widthAsString = pattern.span(1, pointPosInPattern - 1);
			String numberOfDecimalsAsString = pattern.span(pointPosInPattern + 1, pattern.size - 2);
			
			if (!widthAsString.empty) {
				width = parseInteger(widthAsString);
			}
			
			if (!numberOfDecimalsAsString.empty) {
				numberOfDecimals = parseInteger(numberOfDecimalsAsString);
			}
		}
		
		variable String strIntValue = "";
		variable String strMantisse = "";
		
		String numberAsString = number.string;
		Integer? pointPosInNumber = numberAsString.firstOccurrence('.');
		
		if (exists pointPosInNumber) {
			strIntValue = numberAsString.span(0, pointPosInNumber - 1);
			strMantisse = numberAsString.span(pointPosInNumber + 1, numberAsString.size - 1);
			
			if (exists mag = strMantisse.firstIndexWhere(Character.letter)) {
				rest = strMantisse[mag...];
				
				if (exists it = rest) {
					String? strExponent = it[1...];
					
					if (exists strExponent) {
						value valueExponent = parseInteger(strExponent);
						
						if (exists valueExponent) {
							if (valueExponent >= 0) {
								strIntValue = strIntValue.plus(strMantisse[... valueExponent - 1]);
								strMantisse = strMantisse[valueExponent...];
								strMantisse = strMantisse[... mag - 1];
							} else {
								strMantisse = strIntValue.plus(strMantisse);
								strMantisse = strMantisse[...mag];
								strIntValue = "0";
								
								value temp = -valueExponent;
								
								for (i in 0..temp) {
									strMantisse = "0".plus(strMantisse);
								}
							}
						}
					}
				}
			}
		} else {
			strIntValue = numberAsString;
			strMantisse = "0";
		}
		
		variable String strDecimal = "";
		
		if (exists n = numberOfDecimals) {
			
			if (strMantisse.size > n) {
				strDecimal = strMantisse.span(0, n - 1);
			} else if (strMantisse.size < n) {
				
				strDecimal = strMantisse;
				
				for (i in (1..(n - (strMantisse.size)))) {
					strDecimal = strDecimal.plus("0");
				}
			} else {
				strDecimal = strMantisse;
			}
		}
		
		numberFormated = strIntValue.plus(".").plus(strDecimal);
		
		if (exists w = width) {
			
			if (w > numberFormated.size) {
				
				for (i in (1..(w - numberFormated.size))) {
					numberFormated = " ".plus(numberFormated);
				}
			}
		}
		
		return numberFormated;
	}
	
	String formatInteger(String pattern, Integer number) {
		
		assert (pattern.startsWith("%"));
		assert (pattern.endsWith("d"));
		
		variable String numberFormated = "";
		
		variable Integer? width = 0;
		
		String widthAsString = pattern.span(1, pattern.size - 2);
		
		if (!widthAsString.empty) {
			width = parseInteger(widthAsString);
		}
		
		numberFormated = number.string;
		
		if (exists w = width) {
			
			if (w > numberFormated.size) {
				
				for (i in (1..(w - numberFormated.size))) {
					numberFormated = " ".plus(numberFormated);
				}
			}
		}
		
		return numberFormated;
	}
	
	void writeFormatted(String pattern, Float|Integer number) {
		
		assert (pattern.startsWith("%"));
		assert (pattern.endsWith("d") || pattern.endsWith("f"));
		
		if (pattern.endsWith("f")) {
			if (is Float number) {
				process.write(formatFloat(pattern, number));
			} else if (is Integer number) {
				Float temp = number + 0.0;
				process.write(formatFloat(pattern, temp));
			}
		} else {
			if (is Float number) {
				Integer temp = number.integer;
				process.write(formatInteger(pattern, temp));
			} else if (is Integer number) {
				process.write(formatInteger(pattern, number));
			}
		}
	}
}

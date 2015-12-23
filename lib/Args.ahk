Args(paramList) {
	count:=0, options:={}	
	paramList := RegExReplace(paramList, "(?:([^\s])-|(\s+)-(\s+))", "$1$2<dash>$3")
	paramList := RegExReplace(paramList, "(?:([^\s])/|(\s+)/(\s+))", "$1$2<slash>$3")
	regex = (?<=[-|/])([a-zA-Z0-9]*)[ |:|=|"|']*([\w|.|@|?|#|$|`%|=|*|,|<|>|^|{|}|\[|\]|;|(|)|_|&|+| |:|!|~|\\]*)["| |']*(.*)	
	while (paramList) {
		count++
		RegExMatch(paramList, regex, data)
		value:=RegExReplace(RegExReplace(data2 , "<dash>", "-"), "<slash>", "/")
		options[data1] := value ? value : 1
		paramList := data3
	}
	ErrorLevel:=count
	return options
}
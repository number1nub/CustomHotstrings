class Xml
{
	__New(param*) {
		root:=param.1, file:=param.2?param.2:root ".xml"
		temp:=ComObjCreate("MSXML2.DOMDocument"), temp.setProperty("SelectionLanguage","XPath")
		this.xml:=temp, this.fileExists:=false
		if (FileExist(file)) {
			FileRead, info, %file%
			if (!info) {
				this.xml := this.create(temp, root)
				FileDelete, %file%
			}
			else
				this.fileExists:=true, temp.loadxml(info), this.xml:=temp
		}
		else
			this.xml := this.create(temp, root)
		this.file := file
	}
	
	__Get(x:="") {
		return this.xml.xml
	}
	
	Add(path, att:="", text:="", dup:=0, list:="") {
		p:="/",dup1:=this.ssn("//" path)?1:0,next:=this.ssn("//" path),last:=SubStr(path,InStr(path,"/",0,0)+1)
		if (!next.xml) {
			next := this.ssn("//*")
			Loop, Parse, path, /
				last:=A_LoopField, p.="/" last, next:=this.ssn(p)?this.ssn(p):next.appendchild(this.xml.createElement(last))
		}
		if (dup && dup1)
			next := next.parentnode.appendchild(this.xml.createElement(last))
		for a, b in att
			next.SetAttribute(a, b)
		for a, b in StrSplit(list, ",")
			next.SetAttribute(b, att[b])
		if (text)
			next.text := text
		return next
	}
	
	Create(doc, root) {
		return doc.AppendChild(this.xml.createElement(root)).parentnode
	}
	
	EA(path) {
		list:=[]
		if (nodes:=path.nodename)
			nodes := path.SelectNodes("@*")
		else if (path.text)
			nodes := this.sn("//*[text()='" path.text "']/@*")
		else if (!IsObject(path))
			nodes := this.sn(path "/@*")
		else
			for a, b in path
				nodes := this.sn("//*[@" a "='" b "']/@*")
		while, (n:=nodes.item(A_Index-1))
			list[n.nodename] := n.text
		return list
	}
	
	FF(info*) {
		doc := info.1.NodeName ? info.1 : this.xml
		if (info.1.NodeName)
			node:=info.2, find:=info.3
		else
			node:=info.1, find:=info.2
		if (InStr(find, "'"))
			return doc.selectSingleNode(node "[.=concat('" RegExReplace(find,"'","'," Chr(34) "'" Chr(34) ",'") "')]/..")
		else
			return doc.selectSingleNode(node "[.='" find "']/..")
	}
	
	Find(info) {
		if (info.att.1 && info.text) {
			MsgBox 4144,, You can only search by either the attribute or the text, not both
			return
		}
		search := info.path ? "//" info.path : "//*"
		for a, b in info.att
			search .= "[@" a "='" b "']"
		if (info.text)
			search .= "[text()='" info.text "']"
		return this.ssn(search)
	}
	
	Get(path, default:="") {
		return ((ptxt:=this.ssn(path).text) ? ptxt : default)
	}
	
	Lang(info) {
		info:=!info?"XPath":"XSLPattern", this.xml.temp.setProperty("SelectionLanguage", info)
	}
	
	Remove(rem) {
		if (!IsObject(rem))
			rem := this.ssn(rem)
		rem.parentNode.removeChild(rem)
	}
	
	Save(x*) {
		if (x.1=1)
			this.Transform()
		filename := this.file ? this.file : x.1.1
		SplitPath, filename,, fDir
		if (!FileExist(fDir))
			FileCreateDir, %fDir%
		file:=fileopen(filename, "rw", "Utf-8"), file.seek(0), file.write(this[]), file.length(file.position)
	}
	
	Search(node, find) {
		while, ff:=found.Item[A_Index-1]
			if (ff.text = find)
				return ff
	}
	
	SN(node) {
		return this.xml.SelectNodes(node)
	}
	
	SSN(node) {
		return this.xml.SelectSingleNode(node)
	}
	
	Transform() {
		static
		if (!IsObject(xsl)) {
			xsl := ComObjCreate("MSXML2.DOMDocument")
			style=
			(
			<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
			<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
			<xsl:template match="@*|node()">
				<xsl:copy>
					<xsl:apply-templates select="@*|node()"/>
					<xsl:for-each select="@*">
						<xsl:text>
						</xsl:text>
					</xsl:for-each>
				</xsl:copy>
			</xsl:template>
			</xsl:stylesheet>
			)
			xsl.loadXML(style), style:=null
		}
		this.xml.transformNodeToObject(xsl, this.xml)
	}
	
	Under(under, node:="", att:="", text:="", list:="") {
		if (!node) {
			node:=under.node, att:=under.att, list:=under.list, under:=under.under
		}
		new := under.appendchild(this.xml.createElement(node))
		for a, b in att
			new.SetAttribute(a, b)
		for a, b in StrSplit(list, ",")
			new.SetAttribute(b, att[b])
		if (text)
			new.text := text
		return new
	}
	
	Unique(info) {
		if (info.check && info.text)
			return
		if (info.under) {
			if (info.check)
				find := info.under.selectSingleNode("*[@" info.check "='" info.att[info.check] "']")
			if (info.Text)
				find := this.ssn(info.under,"*[text()='" info.text "']")
			if (!find)
				find := this.under(info.under,info.path,info.att)
			for a, b in info.att
				find.SetAttribute(a, b)
		}
		else {
			if (info.check)
				find := this.ssn("//" info.path "[@" info.check "='" info.att[info.check] "']")
			else if (info.text)
				find := this.ssn("//" info.path "[text()='" info.text "']")
			if (!find)
				find := this.add({path:info.path,att:info.att,dup:1})
			for a, b in info.att
				find.SetAttribute(a,b)
		}
		if (info.text)
			find.text := info.text
		return find
	}
}
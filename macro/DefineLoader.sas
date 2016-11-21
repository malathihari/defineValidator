%macro DefineLoader(xmlPath = &define./define.xml, mapPath = &xmlmap./define.map);

	filename DEFINE  "&xmlPath.";
	filename SXLEMAP "&mapPath.";
	libname  DEFINE  xmlv2 xmlmap = SXLEMAP access = readonly;
	
	/***** XPath: /ODM/Study/MetaDataVersion/ItemGroupDef *****/
	data ItemGroupDef; set define.ItemGroupDef; run;
	/* data Description; set define.Description; run; */
	/* data TranslatedText; set define.TranslatedText; run; */
	data ItemRef1; set define.ItemRef1; run;
	/* data leaf; set define.leaf; run; */
	/* data Alias; set define.Alias; run; */
	
	/***** XPath: /ODM/Study/MetaDataVersion/ItemDef *****/
	data ItemDef; set define.ItemDef; run;
	/* data Description1; set define.Description1; run; */
	/* data TranslatedText1; set define.TranslatedText1; run; */
	data CodeListRef; set define.CodeListRef; run;
	/* data Origin; set define.Origin; run; */
	/* data DocumentRef2; set define.DocumentRef2; run; */
	/* data PDFPageRef; set define.PDFPageRef; run; */
	/* data ValueListRef; set define.ValueListRef; run; */
	
	/***** XPath: /ODM/Study/MetaDataVersion/CodeList *****/
	data CodeList; set define.CodeList; run;
	data EnumeratedItem; set define.EnumeratedItem; run;
	data Alias1; set define.Alias1; run;
	data Alias2; set define.Alias2; run;
	data CodeListItem; set define.CodeListItem; run;
	data Decode; set define.Decode; run;
	data TranslatedText2; set define.TranslatedText2; run;
	data Alias3; set define.Alias3; run;
	/* data ExternalCodeList; set define.ExternalCodeList; run; */
		
	proc sql noprint feedback nowarnrecurs;
		/* Create CodeList Table */
		create table _CodeList as
		select
			  m.CodeList_ORDINAL as codeListNum
			, m.OID			     as codeListOID
			, m.Name			 as codeListName
			, s.Name			 as codeListCode
		from CodeList m
		left join Alias2 s
		on m.CodeList_ORDINAL = s.CodeList_ORDINAL
		;
		
		/* Create EnumeratedItem Table */
		create table _EnumeratedItem as
		select
			  m.*
			, s1.EnumeratedItem_ORDINAL as itemNum
			, s1.CodedValue
			, s1.OrderNumber
			, s1.ExtendedValue
			, s1.Rank
			, s2.Name				    as code
		from _CodeList m
		left join EnumeratedItem s1
		on m.codeListNum = s1.CodeList_ORDINAL
		left join Alias1 s2
		on s1.EnumeratedItem_ORDINAL = s2.EnumeratedItem_ORDINAL
		having not missing(CodedValue)
		;
	
		/* Create CodeListItem Table */
		create table _CodeListItem as
		select
			  m.*
			, s1.CodeListItem_ORDINAL as itemNum
			, s1.CodedValue
			, s1.OrderNumber
			, s1.ExtendedValue
			, s1.Rank
			, s2.Name				  as code
			, s4.TranslatedText2	  as translatedText
		from _CodeList m
		left join CodeListItem s1
		on m.codeListNum = s1.CodeList_ORDINAL
		left join Alias3 s2
		on s1.CodeListItem_ORDINAL = s2.CodeListItem_ORDINAL
		left join Decode s3
		on s1.CodeListItem_ORDINAL = s3.CodeListItem_ORDINAL
		left join TranslatedText2 s4
		on s3.Decode_ORDINAL = s4.Decode_ORDINAL
		having not missing(CodedValue)
		;
	quit;

	libname  DEFINE  clear;
	filename SXLEMAP clear;
	filename DEFINE  clear;
	
%mend;
